import Foundation
import CloudKit
import Logging

class CloudSync: ObservableObject {
    static let shared = CloudSync()
    private let logger = Logger(label: "com.picsweep.CloudSync")
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    private init() {
        self.database = container.privateCloudDatabase
    }
    
    func syncPhoto(_ photo: Photo) async throws {
        let record = try createRecord(from: photo)
        try await database.save(record)
        logger.info("Successfully synced photo: \(photo.id)")
    }
    
    func fetchPhotos() async throws -> [Photo] {
        let query = CKQuery(recordType: "Photo", predicate: NSPredicate(value: true))
        let result = try await database.records(matching: query)
        return try result.matchResults.compactMap { try createPhoto(from: $0.1) }
    }
    
    func deletePhoto(_ photo: Photo) async throws {
        let recordID = CKRecord.ID(recordName: photo.id.uuidString)
        try await database.deleteRecord(withID: recordID)
        logger.info("Successfully deleted photo: \(photo.id)")
    }
    
    private func createRecord(from photo: Photo) throws -> CKRecord {
        let record = CKRecord(recordType: "Photo")
        record["id"] = photo.id.uuidString
        record["url"] = photo.url
        record["metadata"] = photo.metadata
        record["createdAt"] = photo.createdAt
        return record
    }
    
    private func createPhoto(from record: CKRecord) throws -> Photo {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let url = record["url"] as? URL,
              let metadata = record["metadata"] as? [String: String],
              let createdAt = record["createdAt"] as? Date else {
            throw CloudError.invalidRecord
        }
        
        return Photo(
            id: id,
            url: url,
            createdAt: createdAt,
            metadata: metadata
        )
    }
    
    func uploadPhoto(_ photo: Photo) async throws {
        // Simulated cloud upload
        logger.info("Uploading photo: \(photo.id)")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        logger.info("Upload complete: \(photo.id)")
    }
    
    func downloadPhoto(id: String) async throws -> Photo {
        // Simulated cloud download
        logger.info("Downloading photo: \(id)")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        guard let uuid = UUID(uuidString: id) else {
            throw CloudError.invalidPhotoId
        }
        
        let metadata = PhotoMetadata(
            tags: ["downloaded"],
            location: nil,
            dateCreated: Date()
        )
        
        return Photo(
            id: uuid,
            url: URL(string: "cloud://\(id)")!,
            createdAt: Date(),
            metadata: metadata.asDictionary
        )
    }
}

enum CloudError: Error {
    case invalidRecord
    case syncFailed
    case fetchFailed
    case deleteFailed
    case invalidPhotoId
    case uploadFailed
    case downloadFailed
}

struct PhotoMetadata: Codable {
    let tags: [String]
    let location: String?
    let dateCreated: Date
    
    var asDictionary: [String: String] {
        var dict: [String: String] = [
            "tags": tags.joined(separator: ","),
            "dateCreated": ISO8601DateFormatter().string(from: dateCreated)
        ]
        if let location = location {
            dict["location"] = location
        }
        return dict
    }
} 