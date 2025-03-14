import XCTest
import SwiftUI
@testable import PicSweep

final class PicSweepTests: XCTestCase {
    var photoManager: PhotoManager!
    
    override func setUpWithError() throws {
        photoManager = PhotoManager()
    }

    override func tearDownWithError() throws {
        photoManager = nil
    }

    func testPhotoManagerInitialization() throws {
        XCTAssertNotNil(photoManager)
        XCTAssertEqual(photoManager.currentIndex, 0)
        XCTAssertTrue(photoManager.photos.isEmpty)
    }

    func testThemeColors() {
        XCTAssertNotNil(Theme.primary)
        XCTAssertNotNil(Theme.secondary)
        XCTAssertNotNil(Theme.background)
        XCTAssertNotNil(Theme.cardBackground)
        XCTAssertNotNil(Theme.text)
        XCTAssertNotNil(Theme.secondaryText)
        XCTAssertNotNil(Theme.deleteColor)
        XCTAssertNotNil(Theme.keepColor)
    }
    
    func testPhotoAddAndRemove() {
        let photo = createTestPhoto()
        
        // Test adding photo
        photoManager.addPhoto(photo)
        XCTAssertEqual(photoManager.photos.count, 1)
        XCTAssertEqual(photoManager.photos.first?.id, photo.id)
        
        // Test removing photo
        photoManager.removePhoto(photo)
        XCTAssertTrue(photoManager.photos.isEmpty)
    }
} 