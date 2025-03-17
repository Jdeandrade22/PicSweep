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

    func testThemeConfiguration() {
        let themeColors: [Color] = [
            Theme.primary,
            Theme.secondary,
            Theme.background,
            Theme.cardBackground,
            Theme.text,
            Theme.secondaryText,
            Theme.deleteColor,
            Theme.keepColor
        ]
        
        for color in themeColors {
            XCTAssertNotNil(color)
        }
    }
    
    func testPhotoManagement() {
        let photo = createTestPhoto()
        
        photoManager.addPhoto(photo)
        XCTAssertEqual(photoManager.photos.count, 1)
        XCTAssertEqual(photoManager.photos.first?.id, photo.id)
        
        photoManager.removePhoto(photo)
        XCTAssertTrue(photoManager.photos.isEmpty)
    }
} 