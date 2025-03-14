import XCTest
@testable import PicSweep

final class PhotoAnalyzerTests: XCTestCase {
    var analyzer: PhotoAnalyzer!
    
    override func setUpWithError() throws {
        analyzer = PhotoAnalyzer.shared
    }
    
    override func tearDownWithError() throws {
        analyzer = nil
    }
    
    func testAnalyzePhoto() async throws {
        let image = createTestImage()
        let analysis = try await analyzer.analyzePhoto(image)
        
        // Basic validation
        XCTAssertNotNil(analysis)
        XCTAssertNotNil(analysis.faces)
        XCTAssertNotNil(analysis.scenes)
        XCTAssertNotNil(analysis.objects)
        XCTAssertNotNil(analysis.text)
    }
    
    func testDetectFaces() async throws {
        let image = createTestImage()
        let faces = try await analyzer.detectFaces(in: image)
        
        // Basic validation
        XCTAssertNotNil(faces)
        XCTAssertTrue(faces is [Face])
    }
    
    func testDetectScenes() async throws {
        let image = createTestImage()
        let scenes = try await analyzer.detectScenes(in: image)
        
        // Basic validation
        XCTAssertNotNil(scenes)
        XCTAssertTrue(scenes is [Scene])
    }
    
    func testDetectObjects() async throws {
        let image = createTestImage()
        let objects = try await analyzer.detectObjects(in: image)
        
        // Basic validation
        XCTAssertNotNil(objects)
        XCTAssertTrue(objects is [Object])
    }
    
    func testRecognizeText() async throws {
        let image = createTestImage()
        let text = try await analyzer.recognizeText(in: image)
        
        // Basic validation
        XCTAssertNotNil(text)
        XCTAssertTrue(text is String)
    }
} 