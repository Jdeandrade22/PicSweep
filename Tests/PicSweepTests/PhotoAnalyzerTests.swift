import XCTest
@testable import PicSweep

final class PhotoAnalyzerTests: XCTestCase {
    var analyzer: PhotoAnalyzer!
    
    override func setUpWithError() throws {
        analyzer = PhotoAnalyzer()
    }
    
    override func tearDownWithError() throws {
        analyzer = nil
    }
    
    func testAnalyzePhoto() async throws {
        #if os(iOS)
        let image = createTestImage()
        let analysis = try await analyzer.analyzePhoto(image)
        
        XCTAssertNotNil(analysis)
        XCTAssertNotNil(analysis.faces)
        XCTAssertNotNil(analysis.scenes)
        XCTAssertNotNil(analysis.objects)
        XCTAssertNotNil(analysis.text)
        #else
        // On macOS, photo analysis is limited
        let image = createTestImage()
        let analysis = try await analyzer.analyzePhoto(image)
        
        XCTAssertNotNil(analysis)
        XCTAssertTrue(analysis.faces.isEmpty)
        XCTAssertTrue(analysis.scenes.isEmpty)
        XCTAssertTrue(analysis.objects.isEmpty)
        XCTAssertEqual(analysis.text, "")
        #endif
    }
    
    func testDetectFaces() async throws {
        #if os(iOS)
        let image = createTestImage()
        let faces = try await analyzer.detectFaces(in: image)
        XCTAssertNotNil(faces)
        #else
        // Face detection not supported on macOS
        let image = createTestImage()
        let faces = try await analyzer.detectFaces(in: image)
        XCTAssertTrue(faces.isEmpty)
        #endif
    }
    
    func testDetectScenes() async throws {
        #if os(iOS)
        let image = createTestImage()
        let scenes = try await analyzer.detectScenes(in: image)
        XCTAssertNotNil(scenes)
        #else
        // Scene detection not supported on macOS
        let image = createTestImage()
        let scenes = try await analyzer.detectScenes(in: image)
        XCTAssertTrue(scenes.isEmpty)
        #endif
    }
    
    func testDetectObjects() async throws {
        #if os(iOS)
        let image = createTestImage()
        let objects = try await analyzer.detectObjects(in: image)
        XCTAssertNotNil(objects)
        #else
        // Object detection not supported on macOS
        let image = createTestImage()
        let objects = try await analyzer.detectObjects(in: image)
        XCTAssertTrue(objects.isEmpty)
        #endif
    }
    
    func testRecognizeText() async throws {
        #if os(iOS)
        let image = createTestImage()
        let text = try await analyzer.recognizeText(in: image)
        XCTAssertNotNil(text)
        #else
        // Text recognition not supported on macOS
        let image = createTestImage()
        let text = try await analyzer.recognizeText(in: image)
        XCTAssertEqual(text, "")
        #endif
    }
} 