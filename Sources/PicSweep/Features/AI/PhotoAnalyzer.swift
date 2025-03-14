import Foundation
import Vision
import CoreML

class PhotoAnalyzer {
    static let shared = PhotoAnalyzer()
    private let logger = Logger(subsystem: "com.picsweep", category: "PhotoAnalyzer")
    
    private init() {}
    
    func analyzePhoto(_ image: UIImage) async throws -> PhotoAnalysis {
        var analysis = PhotoAnalysis()
        
        // Face detection
        if let faces = try? await detectFaces(in: image) {
            analysis.faces = faces
        }
        
        // Scene detection
        if let scenes = try? await detectScenes(in: image) {
            analysis.scenes = scenes
        }
        
        // Object detection
        if let objects = try? await detectObjects(in: image) {
            analysis.objects = objects
        }
        
        // Text recognition
        if let text = try? await recognizeText(in: image) {
            analysis.text = text
        }
        
        return analysis
    }
    
    private func detectFaces(in image: UIImage) async throws -> [Face] {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try handler.perform([request])
        
        return request.results?.map { result in
            Face(bounds: result.boundingBox, confidence: result.confidence)
        } ?? []
    }
    
    private func detectScenes(in image: UIImage) async throws -> [Scene] {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try handler.perform([request])
        
        return request.results?.map { result in
            Scene(identifier: result.identifier, confidence: result.confidence)
        } ?? []
    }
    
    private func detectObjects(in image: UIImage) async throws -> [Object] {
        let request = VNDetectObjectsRequest()
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try handler.perform([request])
        
        return request.results?.map { result in
            Object(bounds: result.boundingBox, label: result.labels.first?.identifier ?? "", confidence: result.confidence)
        } ?? []
    }
    
    private func recognizeText(in image: UIImage) async throws -> String {
        let request = VNRecognizeTextRequest()
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try handler.perform([request])
        
        return request.results?.map { $0.topCandidates(1).first?.string ?? "" }.joined(separator: " ") ?? ""
    }
}

struct PhotoAnalysis {
    var faces: [Face] = []
    var scenes: [Scene] = []
    var objects: [Object] = []
    var text: String = ""
}

struct Face {
    let bounds: CGRect
    let confidence: Float
}

struct Scene {
    let identifier: String
    let confidence: Float
}

struct Object {
    let bounds: CGRect
    let label: String
    let confidence: Float
} 