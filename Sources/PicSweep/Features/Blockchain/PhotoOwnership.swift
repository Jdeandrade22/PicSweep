import Foundation
import CryptoKit

class PhotoOwnership {
    static let shared = PhotoOwnership()
    private let logger = Logger(subsystem: "com.picsweep", category: "PhotoOwnership")
    
    private init() {}
    
    func generateOwnershipHash(for photo: Photo) throws -> String {
        let photoData = try JSONEncoder().encode(photo)
        let hash = SHA256.hash(data: photoData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func verifyOwnership(photo: Photo, hash: String) throws -> Bool {
        let generatedHash = try generateOwnershipHash(for: photo)
        return generatedHash == hash
    }
    
    func createOwnershipRecord(for photo: Photo) throws -> OwnershipRecord {
        let hash = try generateOwnershipHash(for: photo)
        let timestamp = Date()
        
        return OwnershipRecord(
            photoId: photo.id,
            hash: hash,
            timestamp: timestamp,
            ownerId: UserDefaults.standard.string(forKey: "userId") ?? UUID().uuidString
        )
    }
    
    func validateOwnershipRecord(_ record: OwnershipRecord) -> Bool {
        // Verify timestamp is not in the future
        guard record.timestamp <= Date() else { return false }
        
        // Verify hash matches photo
        guard let photo = try? PhotoManager.shared.getPhoto(id: record.photoId),
              let isValid = try? verifyOwnership(photo: photo, hash: record.hash) else {
            return false
        }
        
        return isValid
    }
}

struct OwnershipRecord: Codable {
    let photoId: String
    let hash: String
    let timestamp: Date
    let ownerId: String
} 