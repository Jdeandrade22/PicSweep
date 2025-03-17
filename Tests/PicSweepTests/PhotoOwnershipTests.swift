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
    
    func testOwnershipHashGenerationAndVerification() throws {
        let hash = try photoOwnership.generateOwnershipHash(for: testPhoto)
        XCTAssertFalse(hash.isEmpty)
        
        let isValid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: hash)
        XCTAssertTrue(isValid)
        
        let invalidHash = "invalid_hash"
        let isInvalid = try photoOwnership.verifyOwnership(photo: testPhoto, hash: invalidHash)
        XCTAssertFalse(isInvalid)
    }
    
    func testOwnershipRecordCreationAndValidation() throws {
        photoManager.addPhoto(testPhoto)
        
        let record = try photoOwnership.createOwnershipRecord(for: testPhoto)
        XCTAssertEqual(record.photoId, testPhoto.id.uuidString)
        XCTAssertFalse(record.ownerHash.isEmpty)
        XCTAssertTrue(record.timestamp <= Date())
        
        let isValid = try photoOwnership.verifyRecord(record, photoManager: photoManager)
        XCTAssertTrue(isValid)
    }
} 