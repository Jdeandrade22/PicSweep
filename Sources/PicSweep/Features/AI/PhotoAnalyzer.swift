import Foundation
#if canImport(Vision)
import Vision
#endif

struct PhotoAnalysis: Codable {
    var faces: [Face]
    var scenes: [Scene]
    var objects: [Object]
    var text: String
}

struct Face: Codable {
    var bounds: CGRect
    var confidence: Float
}

struct Scene: Codable {
    var identifier: String
    var confidence: Float
}

struct Object: Codable {
    var identifier: String
    var confidence: Float
    var bounds: CGRect
}

class PhotoAnalyzer: ObservableObject {
    func analyzePhoto(_ image: PlatformImage) async throws -> PhotoAnalysis {
        #if os(macOS)
        return PhotoAnalysis(faces: [], scenes: [], objects: [], text: "")
        #else
        async let faces = try detectFaces(in: image)
        async let scenes = try detectScenes(in: image)
        async let objects = try detectObjects(in: image)
        async let text = try recognizeText(in: image)
        
        return try await PhotoAnalysis(
            faces: faces,
            scenes: scenes,
            objects: objects,
            text: text
        )
        #endif
    }
    
    #if !os(macOS)
    private func detectFaces(in image: PlatformImage) async throws -> [Face] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PhotoAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        return request.results?.map { observation in
            Face(bounds: observation.boundingBox, confidence: observation.confidence)
        } ?? []
    }
    
    private func detectScenes(in image: PlatformImage) async throws -> [Scene] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PhotoAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        return request.results?.map { observation in
            Scene(identifier: observation.identifier, confidence: observation.confidence)
        } ?? []
    }
    
    private func detectObjects(in image: PlatformImage) async throws -> [Object] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PhotoAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        let request = VNDetectRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        return request.results?.map { observation in
            Object(identifier: "rectangle", confidence: observation.confidence, bounds: observation.boundingBox)
        } ?? []
    }
    
    private func recognizeText(in image: PlatformImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PhotoAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage"])
        }
        
        let request = VNRecognizeTextRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        return request.results?.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n") ?? ""
    }
    #endif
} 