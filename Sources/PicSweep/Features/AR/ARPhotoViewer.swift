#if !DISABLE_ARKIT
import SwiftUI
import ARKit
import RealityKit

class ARPhotoViewer: ObservableObject {
    @Published var isARActive = false
    @Published var currentPhoto: Photo?
    private var arView: ARView?
    
    func startARSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        arView = ARView(frame: .zero)
        arView?.session.run(configuration)
        isARActive = true
    }
    
    func stopARSession() {
        arView?.session.pause()
        isARActive = false
    }
    
    func placePhotoInSpace(_ photo: Photo) {
        guard let arView = arView,
              let image = UIImage(contentsOfFile: photo.url.path) else { return }
        
        let anchor = AnchorEntity(plane: .horizontal)
        let photoEntity = createPhotoEntity(from: image)
        anchor.addChild(photoEntity)
        
        arView.scene.addAnchor(anchor)
        currentPhoto = photo
    }
    
    private func createPhotoEntity(from image: UIImage) -> Entity {
        let mesh = MeshResource.generatePlane(width: 1, depth: 1)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add image texture
        if let cgImage = image.cgImage {
            let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .diffuse))
            entity.model?.materials = [UnlitMaterial(color: .white, texture: texture)]
        }
        
        return entity
    }
}

struct ARPhotoView: UIViewRepresentable {
    let viewer: ARPhotoViewer
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewer.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
#else
// Stub implementation for macOS
import SwiftUI

class ARPhotoViewer: ObservableObject {
    @Published var isARActive = false
    @Published var currentPhoto: Photo?
    
    func startARSession() {
        // No-op on macOS
    }
    
    func stopARSession() {
        // No-op on macOS
    }
    
    func placePhotoInSpace(_ photo: Photo) {
        // No-op on macOS
    }
}

struct ARPhotoView: View {
    let viewer: ARPhotoViewer
    
    var body: some View {
        Text("AR features not available on macOS")
            .foregroundColor(.secondary)
    }
}
#endif 