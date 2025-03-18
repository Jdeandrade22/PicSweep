import XCTest
import SwiftUI
import Photos
@testable import PicSweep

final class PicSweepTests: XCTestCase {
    var photoLibraryManager: PhotoLibraryManager!
    
    override func setUpWithError() throws {
        photoLibraryManager = PhotoLibraryManager()
    }

    override func tearDownWithError() throws {
        photoLibraryManager = nil
    }

    func testPhotoLibraryManagerInitialization() throws {
        XCTAssertNotNil(photoLibraryManager)
        XCTAssertEqual(photoLibraryManager.currentIndex, 0)
        XCTAssertTrue(photoLibraryManager.photos.isEmpty)
        XCTAssertTrue(photoLibraryManager.photoAssets.isEmpty)
        XCTAssertEqual(photoLibraryManager.deletedCount, 0)
        XCTAssertEqual(photoLibraryManager.savedCount, 0)
        XCTAssertFalse(photoLibraryManager.canUndo)
    }

    func testPhotoManagement() {
        let testImage = createTestImage()
        let testAsset = createTestPHAsset()
        
        // Add photo
        photoLibraryManager.photos.append(testImage)
        photoLibraryManager.photoAssets.append(testAsset)
        photoLibraryManager.updateCurrentPhoto(at: 0)
        
        XCTAssertEqual(photoLibraryManager.photos.count, 1)
        XCTAssertEqual(photoLibraryManager.photoAssets.count, 1)
        XCTAssertNotNil(photoLibraryManager.currentPhoto)
        
        // Remove photo
        photoLibraryManager.removeCurrentPhoto(at: 0)
        XCTAssertTrue(photoLibraryManager.photos.isEmpty)
        XCTAssertTrue(photoLibraryManager.photoAssets.isEmpty)
        XCTAssertNil(photoLibraryManager.currentPhoto)
        XCTAssertEqual(photoLibraryManager.deletedCount, 1)
    }
    
    func testUndoFunctionality() {
        let testImage = createTestImage()
        let testAsset = createTestPHAsset()
        
        // Add photo
        photoLibraryManager.photos.append(testImage)
        photoLibraryManager.photoAssets.append(testAsset)
        photoLibraryManager.updateCurrentPhoto(at: 0)
        
        // Delete photo
        photoLibraryManager.removeCurrentPhoto(at: 0)
        XCTAssertEqual(photoLibraryManager.deletedCount, 1)
        XCTAssertTrue(photoLibraryManager.canUndo)
        
        // Undo delete
        photoLibraryManager.undoLastAction()
        XCTAssertEqual(photoLibraryManager.deletedCount, 0)
        XCTAssertFalse(photoLibraryManager.canUndo)
        XCTAssertEqual(photoLibraryManager.currentIndex, 0)
        XCTAssertNotNil(photoLibraryManager.currentPhoto)
        
        // Keep photo
        photoLibraryManager.keepCurrentPhoto(at: 0)
        XCTAssertEqual(photoLibraryManager.savedCount, 1)
        XCTAssertTrue(photoLibraryManager.canUndo)
        
        // Undo keep
        photoLibraryManager.undoLastAction()
        XCTAssertEqual(photoLibraryManager.savedCount, 0)
        XCTAssertFalse(photoLibraryManager.canUndo)
        XCTAssertEqual(photoLibraryManager.currentIndex, 0)
        XCTAssertNotNil(photoLibraryManager.currentPhoto)
    }
    
    func testMoveToNextPhoto() {
        let testImage1 = createTestImage()
        let testImage2 = createTestImage()
        let testAsset1 = createTestPHAsset()
        let testAsset2 = createTestPHAsset()
        
        // Add photos
        photoLibraryManager.photos.append(testImage1)
        photoLibraryManager.photos.append(testImage2)
        photoLibraryManager.photoAssets.append(testAsset1)
        photoLibraryManager.photoAssets.append(testAsset2)
        photoLibraryManager.updateCurrentPhoto(at: 0)
        
        // Move to next photo
        photoLibraryManager.moveToNextPhoto()
        XCTAssertEqual(photoLibraryManager.currentIndex, 1)
        XCTAssertEqual(photoLibraryManager.currentPhoto, testImage2)
        
        // Move to first photo when at end
        photoLibraryManager.moveToNextPhoto()
        XCTAssertEqual(photoLibraryManager.currentIndex, 0)
        XCTAssertEqual(photoLibraryManager.currentPhoto, testImage1)
    }
}

// Helper function to create a test PHAsset
extension XCTestCase {
    func createTestPHAsset() -> PHAsset {
        let fetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        if let asset = fetchResult.firstObject {
            return asset
        }
        // If no real asset is available, create a mock
        return PHAsset()
    }
} 