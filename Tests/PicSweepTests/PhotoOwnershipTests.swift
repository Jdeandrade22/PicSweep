import XCTest
import CryptoKit
@testable import PicSweep

final class PhotoOwnershipTests: XCTestCase {
    var photoOwnership: PhotoOwnership!
    var testPhoto: Photo!
    
    override func setUp() {
        super.setUp()
        photoOwnership = PhotoOwnership.shared
        testPhoto = Photo(id: "test", image: UIImage(), metadata: PhotoMetadata())
    }
    
    override func tearDown() {
        photoOwnership = nil
        testPhoto = nil
        super.tearDown()
    }
    
    func testHashGeneration() throws {
        let hash = try photoOwnership.generateOwnershipHash(for: testPhoto)
        XCTAssertFalse(hash.isEmpty)
        XCTAssertEqual(hash.count, 64) // SHA256 produces 64 hex characters
    }
    
    func testOwnershipVerification() throws {
        let hash = try photoOwnership.generateOwnershipHash(for: testPhoto)
        let isValid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: hash)
        XCTAssertTrue(isValid)
    }
    
    func testOwnershipRecordCreation() throws {
        let record = try photoOwnership.createOwnershipRecord(for: testPhoto)
        XCTAssertEqual(record.photoId, testPhoto.id)
        XCTAssertFalse(record.hash.isEmpty)
        XCTAssertFalse(record.ownerId.isEmpty)
        XCTAssertTrue(record.timestamp <= Date())
    }
    
    func testOwnershipRecordValidation() throws {
        let record = try photoOwnership.createOwnershipRecord(for: testPhoto)
        let isValid = photoOwnership.validateOwnershipRecord(record)
        XCTAssertTrue(isValid)
    }
    
    func testInvalidHashVerification() throws {
        let invalidHash = "invalid_hash"
        let isValid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: invalidHash)
        XCTAssertFalse(isValid)
    }
} 