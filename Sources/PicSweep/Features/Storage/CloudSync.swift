import Foundation
import CloudKit

class CloudSync {
    static let shared = CloudSync()
    private let logger = Logger(subsystem: "com.picsweep", category: "CloudSync")
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
        let recordID = CKRecord.ID(recordName: photo.id)
        try await database.deleteRecord(withID: recordID)
        logger.info("Successfully deleted photo: \(photo.id)")
    }
    
    private func createRecord(from photo: Photo) throws -> CKRecord {
        let record = CKRecord(recordType: "Photo")
        record["id"] = photo.id
        record["url"] = photo.url
        record["metadata"] = try JSONEncoder().encode(photo.metadata)
        record["analysis"] = try JSONEncoder().encode(photo.analysis)
        record["tags"] = photo.tags
        record["createdAt"] = photo.createdAt
        record["modifiedAt"] = photo.modifiedAt
        
        if let thumbnail = photo.thumbnail {
            let asset = CKAsset(fileURL: thumbnail)
            record["thumbnail"] = asset
        }
        
        return record
    }
    
    private func createPhoto(from record: CKRecord) throws -> Photo {
        guard let id = record["id"] as? String,
              let url = record["url"] as? URL,
              let metadataData = record["metadata"] as? Data,
              let analysisData = record["analysis"] as? Data,
              let tags = record["tags"] as? [String],
              let createdAt = record["createdAt"] as? Date,
              let modifiedAt = record["modifiedAt"] as? Date else {
            throw CloudError.invalidRecord
        }
        
        let metadata = try JSONDecoder().decode(PhotoMetadata.self, from: metadataData)
        let analysis = try JSONDecoder().decode(PhotoAnalysis.self, from: analysisData)
        
        return Photo(
            id: id,
            url: url,
            metadata: metadata,
            analysis: analysis,
            tags: tags,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            thumbnail: (record["thumbnail"] as? CKAsset)?.fileURL
        )
    }
}

enum CloudError: Error {
    case invalidRecord
    case syncFailed
    case fetchFailed
    case deleteFailed
}

struct PhotoMetadata: Codable {
    let size: Int64
    let dimensions: CGSize
    let location: CLLocation?
    let creationDate: Date
    let modificationDate: Date
    let camera: String?
    let lens: String?
    let exposure: Double?
    let iso: Int?
    let focalLength: Double?
} 