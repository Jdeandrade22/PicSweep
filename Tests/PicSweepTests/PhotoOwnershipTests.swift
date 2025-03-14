import XCTest
import CryptoKit
@testable import PicSweep

final class PhotoOwnershipTests: XCTestCase {
    var photoOwnership: PhotoOwnership!
    var photoManager: PhotoManager!
    var testPhoto: Photo!
    
    override func setUp() {
        super.setUp()
        photoOwnership = PhotoOwnership()
        photoManager = PhotoManager()
        testPhoto = createTestPhoto()
    }
    
    override func tearDown() {
        photoOwnership = nil
        photoManager = nil
        testPhoto = nil
        super.tearDown()
    }
    
    func testHashGeneration() throws {
        let hash = try photoOwnership.generateOwnershipHash(for: testPhoto)
        XCTAssertFalse(hash.isEmpty)
    }
    
    func testOwnershipVerification() throws {
        let hash = try photoOwnership.generateOwnershipHash(for: testPhoto)
        let isValid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: hash)
        XCTAssertTrue(isValid)
    }
    
    func testOwnershipRecordCreation() throws {
        let record = try photoOwnership.createOwnershipRecord(for: testPhoto)
        XCTAssertEqual(record.photoId, testPhoto.id.uuidString)
        XCTAssertFalse(record.ownerHash.isEmpty)
        XCTAssertTrue(record.timestamp <= Date())
    }
    
    func testOwnershipRecordValidation() throws {
        photoManager.addPhoto(testPhoto)
        
        let record = try photoOwnership.createOwnershipRecord(for: testPhoto)
        let isValid = try photoOwnership.verifyRecord(record, photoManager: photoManager)
        XCTAssertTrue(isValid)
    }
    
    func testInvalidHashVerification() throws {
        let invalidHash = "invalid_hash"
        let isValid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: invalidHash)
        XCTAssertFalse(isValid)
    }
} 