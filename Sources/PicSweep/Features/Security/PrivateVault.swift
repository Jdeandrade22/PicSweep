import Foundation
import LocalAuthentication
import CryptoKit
import Logging

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class PrivateVault: ObservableObject {
    static let shared = PrivateVault()
    private let logger = Logger(label: "com.picsweep.PrivateVault")
    private let keychain = KeychainWrapper.standard
    private let key: SymmetricKey
    
    init() {
        // Generate a random key for encryption
        key = SymmetricKey(size: .bits256)
    }
    
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            logger.error("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Access your private photos") { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func encryptPhoto(_ photo: Photo) throws -> Data {
        #if os(iOS)
        guard let imageData = photo.image?.jpegData(compressionQuality: 0.8) else {
            throw VaultError.invalidImageData
        }
        #else
        guard let cgImage = photo.image?.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let imageRep = NSBitmapImageRep(cgImage: cgImage),
              let imageData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw VaultError.invalidImageData
        }
        #endif
        
        let sealedBox = try AES.GCM.seal(imageData, using: key)
        return sealedBox.combined ?? Data()
    }
    
    func decryptPhoto(data: Data) throws -> PlatformImage {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        #if os(iOS)
        guard let image = UIImage(data: decryptedData) else {
            throw VaultError.decryptionFailed
        }
        #else
        guard let image = NSImage(data: decryptedData) else {
            throw VaultError.decryptionFailed
        }
        #endif
        return image
    }
    
    func blurFaces(in image: PlatformImage, faces: [Face]) -> PlatformImage {
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            for face in faces {
                let faceRect = CGRect(
                    x: face.bounds.minX * image.size.width,
                    y: face.bounds.minY * image.size.height,
                    width: face.bounds.width * image.size.width,
                    height: face.bounds.height * image.size.height
                )
                
                let blurEffect = UIBlurEffect(style: .regular)
                let blurView = UIVisualEffectView(effect: blurEffect)
                blurView.frame = faceRect
                blurView.layer.cornerRadius = faceRect.width / 2
                blurView.clipsToBounds = true
                
                blurView.layer.render(in: context.cgContext)
            }
        }
        #else
        // On macOS, we'll use CIFilter for blurring
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return image
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        
        let outputImage = NSImage(size: image.size)
        outputImage.lockFocus()
        
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        for face in faces {
            let faceRect = CGRect(
                x: face.bounds.minX * image.size.width,
                y: face.bounds.minY * image.size.height,
                width: face.bounds.width * image.size.width,
                height: face.bounds.height * image.size.height
            )
            
            blurFilter.setValue(ciImage.cropped(to: faceRect), forKey: kCIInputImageKey)
            blurFilter.setValue(10.0, forKey: kCIInputRadiusKey)
            
            if let blurredFace = blurFilter.outputImage {
                let context = CIContext()
                if let cgBlurredFace = context.createCGImage(blurredFace, from: blurredFace.extent) {
                    let nsBlurredFace = NSImage(cgImage: cgBlurredFace, size: faceRect.size)
                    nsBlurredFace.draw(in: faceRect)
                }
            }
        }
        
        outputImage.unlockFocus()
        return outputImage
        #endif
    }
    
    func watermarkPhoto(_ image: PlatformImage, text: String) -> PlatformImage {
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            
            let string = NSString(string: text)
            string.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        }
        #else
        let newImage = NSImage(size: image.size)
        newImage.lockFocus()
        
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 36),
            .foregroundColor: NSColor.white.withAlphaComponent(0.8)
        ]
        
        let string = NSString(string: text)
        string.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        
        newImage.unlockFocus()
        return newImage
        #endif
    }
}

enum VaultError: Error {
    case keyNotFound
    case invalidImageData
    case authenticationFailed
    case encryptionFailed
    case decryptionFailed
} 