import XCTest
import SwiftUI
#if os(iOS)
import ARKit
@testable import PicSweep

final class ARPhotoViewerTests: XCTestCase {
    var arViewer: ARPhotoViewer!
    
    override func setUp() {
        super.setUp()
        arViewer = ARPhotoViewer()
    }
    
    override func tearDown() {
        arViewer = nil
        super.tearDown()
    }
    
    func testARPhotoViewerInitialization() {
        XCTAssertNotNil(arViewer)
        XCTAssertNotNil(arViewer.arView)
    }
    
    func testARPhotoPlacement() {
        let photo = createTestPhoto()
        XCTAssertNoThrow(try arViewer.placePhoto(photo))
    }
    
    func testARPhotoViewCreation() {
        let photo = createTestPhoto()
        let arPhotoView = ARPhotoView(photo: photo)
        XCTAssertNotNil(arPhotoView)
    }
}
#endif 