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
        return try result.matchResults.compactMap { (id, result) -> Photo? in
            switch result {
            case .success(let record):
                return try createPhoto(from: record)
            case .failure(let error):
                logger.error("Failed to fetch record: \(error)")
                return nil
            }
        }
    }
    
    func deletePhoto(_ photo: Photo) async throws {
        let recordID = CKRecord.ID(recordName: photo.id.uuidString)
        try await database.deleteRecord(withID: recordID)
        logger.info("Successfully deleted photo: \(photo.id)")
    }
    
    private func createRecord(from photo: Photo) throws -> CKRecord {
        let record = CKRecord(recordType: "Photo")
        record.setValue(photo.id.uuidString, forKey: "id")
        record.setValue(photo.url.absoluteString, forKey: "urlString")
        
        // Convert metadata to a JSON string to ensure CKRecord compatibility
        let jsonData = try JSONSerialization.data(withJSONObject: photo.metadata)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            record.setValue(jsonString, forKey: "metadata")
        }
        
        record.setValue(photo.createdAt, forKey: "createdAt")
        return record
    }
    
    private func createPhoto(from record: CKRecord) throws -> Photo {
        guard let idString = record.value(forKey: "id") as? String,
              let id = UUID(uuidString: idString),
              let urlString = record.value(forKey: "urlString") as? String,
              let url = URL(string: urlString),
              let metadataString = record.value(forKey: "metadata") as? String,
              let metadataData = metadataString.data(using: .utf8),
              let metadata = try? JSONSerialization.jsonObject(with: metadataData) as? [String: String],
              let createdAt = record.value(forKey: "createdAt") as? Date else {
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