import XCTest
import Vision
@testable import PicSweep

final class PhotoAnalyzerTests: XCTestCase {
    var analyzer: PhotoAnalyzer!
    var image: PlatformImage!
    
    override func setUp() {
        super.setUp()
        analyzer = PhotoAnalyzer()
        image = createTestImage()
    }
    
    override func tearDown() {
        analyzer = nil
        image = nil
        super.tearDown()
    }
    
    func testPhotoAnalysis() async throws {
        let analysis = try await analyzer.analyzePhoto(image)
        
        // Test all analysis components
        XCTAssertNotNil(analysis.faces)
        XCTAssertNotNil(analysis.scenes)
        XCTAssertNotNil(analysis.objects)
        XCTAssertNotNil(analysis.text)
        
        // Test confidence ranges
        for face in analysis.faces {
            XCTAssertGreaterThanOrEqual(face.confidence, 0)
            XCTAssertLessThanOrEqual(face.confidence, 1)
            XCTAssertFalse(face.bounds.isEmpty)
        }
        
        for scene in analysis.scenes {
            XCTAssertFalse(scene.identifier.isEmpty)
            XCTAssertGreaterThanOrEqual(scene.confidence, 0)
            XCTAssertLessThanOrEqual(scene.confidence, 1)
        }
        
        for object in analysis.objects {
            XCTAssertFalse(object.identifier.isEmpty)
            XCTAssertGreaterThanOrEqual(object.confidence, 0)
            XCTAssertLessThanOrEqual(object.confidence, 1)
            XCTAssertFalse(object.bounds.isEmpty)
        }
    }
    
    #if os(macOS)
    func testMacOSLimitation() async throws {
        let analysis = try await analyzer.analyzePhoto(image)
        XCTAssertTrue(analysis.faces.isEmpty)
        XCTAssertTrue(analysis.scenes.isEmpty)
        XCTAssertTrue(analysis.objects.isEmpty)
        XCTAssertTrue(analysis.text.isEmpty)
    }
    #endif
} 