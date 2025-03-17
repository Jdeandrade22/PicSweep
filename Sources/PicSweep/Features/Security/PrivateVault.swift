import Foundation
import LocalAuthentication
import CryptoKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
import CoreImage
#endif

// Simple KeychainWrapper implementation
class KeychainWrapper {
    static let standard = KeychainWrapper()
    private init() {}
    
    func set(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw VaultError.keychainError
        }
    }
    
    func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return (status == errSecSuccess) ? (result as? Data) : nil
    }
}

class PrivateVault: ObservableObject {
    static let shared = PrivateVault()
    private let keychain = KeychainWrapper.standard
    private let key: SymmetricKey
    
    init() {
        // Generate a random key for encryption
        key = SymmetricKey(size: .bits256)
    }
    
    private func encryptData(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw VaultError.encryptionFailed
        }
        return combined
    }
    
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
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
    
    func encryptPhoto(_ image: PlatformImage) throws -> Data {
        #if os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw VaultError.invalidImageData
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let imageData = bitmapRep.representation(using: .jpeg, properties: [:]) else {
            throw VaultError.invalidImageData
        }
        #else
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw VaultError.invalidImageData
        }
        #endif
        
        return try encryptData(imageData)
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
        var imageRect = NSRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
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
    case keychainError
} 