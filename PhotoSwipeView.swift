//
//  PhotoSwipeView.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos

class PhotoLibraryManager: ObservableObject {
    @Published var photos: [UIImage] = []
    @Published var photoAssets: [PHAsset] = [] // To keep track of the assets

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                fetchResult.enumerateObjects { asset, _, _ in
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300) // Adjust as needed
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                        if let image = image {
                            DispatchQueue.main.async {
                                self.photos.append(image)
                                self.photoAssets.append(asset) 
                            }
                        }
                    }
                }
            }
        }
    }
}

// PhotoSwipeView: Displays photos and allows swiping
struct PhotoSwipeView: View {
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            if !photoLibraryManager.photos.isEmpty {
                Image(uiImage: photoLibraryManager.photos[currentIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    // Save logic (e.g., mark as saved)
                                    nextPhoto()
                                } else if value.translation.width < -100 {
                                    // Delete logic
                                    deletePhoto()
                                    nextPhoto()
                                }
                            }
                    )
            } else {
                Text("No photos available")
            }
        }
        .onAppear {
            photoLibraryManager.fetchPhotos()
        }
    }
    
    private func nextPhoto() {
        // Ensure there are photos to display before modifying the index
        guard !photoLibraryManager.photos.isEmpty else { return }
        
        // Update the currentIndex safely
        if currentIndex < photoLibraryManager.photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // Loop back to the first photo if needed
        }
    }
    
    private func deletePhoto() {
        // Ensure there's a photo to delete
        guard !photoLibraryManager.photoAssets.isEmpty else { return }
        
        // Get the current photo's asset
        let assetToDelete = photoLibraryManager.photoAssets[currentIndex]
        
        // Perform the deletion
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    // Remove the photo from the UI list
                    photoLibraryManager.photos.remove(at: currentIndex)
                    photoLibraryManager.photoAssets.remove(at: currentIndex)
                    
                    // Adjust the currentIndex if necessary to prevent "Index out of range"
                    if currentIndex >= photoLibraryManager.photos.count {
                        currentIndex = photoLibraryManager.photos.count - 1
                    }
                    
                    // If no photos are left, reset to the first photo (or handle empty state)
                    if photoLibraryManager.photos.isEmpty {
                        currentIndex = 0
                    }
                    
                    print("Photo deleted")
                }
            } else {
                print("Error deleting photo: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
//
