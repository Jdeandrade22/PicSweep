import Foundation
import LocalAuthentication
import CryptoKit

class PrivateVault {
    static let shared = PrivateVault()
    private let logger = Logger(subsystem: "com.picsweep", category: "PrivateVault")
    private let keychain = KeychainWrapper.standard
    
    private init() {}
    
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
    
    func encryptPhoto(_ image: UIImage) throws -> Data {
        let imageData = image.jpegData(compressionQuality: 0.8)!
        let key = SymmetricKey(size: .bits256)
        let sealedBox = try AES.GCM.seal(imageData, using: key)
        
        // Store the key securely
        try keychain.set(key.withUnsafeBytes { Data($0) }, forKey: "vaultKey")
        
        return sealedBox.combined!
    }
    
    func decryptPhoto(_ encryptedData: Data) throws -> UIImage {
        guard let keyData = keychain.data(forKey: "vaultKey"),
              let key = SymmetricKey(data: keyData) else {
            throw VaultError.keyNotFound
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let image = UIImage(data: decryptedData) else {
            throw VaultError.invalidImageData
        }
        
        return image
    }
    
    func blurFaces(in image: UIImage, faces: [Face]) -> UIImage {
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
    }
}

enum VaultError: Error {
    case keyNotFound
    case invalidImageData
    case authenticationFailed
} 