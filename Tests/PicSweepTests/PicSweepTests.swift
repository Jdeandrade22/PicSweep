import XCTest
import UIKit
@testable import PicSweep

final class PicSweepTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertTrue(true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testImageCreation() throws {
        let image = createTestImage()
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size.width, 100)
        XCTAssertEqual(image.size.height, 100)
    }
    
    func testPhotoCreation() throws {
        let photo = createTestPhoto()
        XCTAssertNotNil(photo)
        XCTAssertNotNil(photo.id)
        XCTAssertNotNil(photo.metadata)
        XCTAssertNotNil(photo.analysis)
    }
} 