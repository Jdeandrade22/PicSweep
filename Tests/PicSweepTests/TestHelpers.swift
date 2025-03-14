import Foundation
import XCTest

extension XCTestCase {
    func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    func createTestPhoto() -> Photo {
        let metadata = PhotoMetadata(
            size: 1024,
            dimensions: CGSize(width: 100, height: 100),
            location: nil,
            creationDate: Date(),
            modificationDate: Date(),
            camera: "Test Camera",
            lens: "Test Lens",
            exposure: 1.0,
            iso: 100,
            focalLength: 50.0
        )
        
        let analysis = PhotoAnalysis(
            faces: [],
            scenes: [],
            objects: [],
            text: ""
        )
        
        return Photo(
            id: UUID().uuidString,
            url: URL(fileURLWithPath: "/test/photo.jpg"),
            metadata: metadata,
            analysis: analysis,
            tags: ["test"],
            createdAt: Date(),
            modifiedAt: Date(),
            thumbnail: nil
        )
    }
} 