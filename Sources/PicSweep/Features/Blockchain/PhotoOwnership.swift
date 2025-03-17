import Foundation

struct OwnershipRecord: Codable {
    let photoId: String
    let ownerHash: String
    let timestamp: Date
}

class PhotoOwnership: ObservableObject {
    func generateOwnershipHash(for photo: Photo) throws -> String {
        // Simple hash generation for demo purposes
        let data = "\(photo.id.uuidString)_\(photo.createdAt.timeIntervalSince1970)".data(using: .utf8)!
        return data.base64EncodedString()
    }
    
    func verifyOwnership(photo: Photo, hash: String) throws -> Bool {
        let generatedHash = try generateOwnershipHash(for: photo)
        return generatedHash == hash
    }
    
    func createOwnershipRecord(for photo: Photo) throws -> OwnershipRecord {
        let hash = try generateOwnershipHash(for: photo)
        return OwnershipRecord(
            photoId: photo.id.uuidString,
            ownerHash: hash,
            timestamp: Date()
        )
    }
    
    func verifyRecord(_ record: OwnershipRecord, photoManager: PhotoManager) throws -> Bool {
        guard let photo = photoManager.getPhoto(id: UUID(uuidString: record.photoId)) else {
            return false
        }
        
        return try verifyOwnership(photo: photo, hash: record.ownerHash)
    }
} 