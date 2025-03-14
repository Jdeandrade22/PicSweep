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
        
        // Test faces
        XCTAssertNotNil(analysis.faces)
        if !analysis.faces.isEmpty {
            let face = analysis.faces[0]
            XCTAssertGreaterThanOrEqual(face.confidence, 0)
            XCTAssertLessThanOrEqual(face.confidence, 1)
            XCTAssertFalse(face.bounds.isEmpty)
        }
        
        // Test scenes
        XCTAssertNotNil(analysis.scenes)
        if !analysis.scenes.isEmpty {
            let scene = analysis.scenes[0]
            XCTAssertFalse(scene.identifier.isEmpty)
            XCTAssertGreaterThanOrEqual(scene.confidence, 0)
            XCTAssertLessThanOrEqual(scene.confidence, 1)
        }
        
        // Test objects
        XCTAssertNotNil(analysis.objects)
        if !analysis.objects.isEmpty {
            let object = analysis.objects[0]
            XCTAssertFalse(object.identifier.isEmpty)
            XCTAssertGreaterThanOrEqual(object.confidence, 0)
            XCTAssertLessThanOrEqual(object.confidence, 1)
            XCTAssertFalse(object.bounds.isEmpty)
        }
        
        // Test text recognition
        XCTAssertNotNil(analysis.text)
        // Text might be empty if no text is found in the image
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