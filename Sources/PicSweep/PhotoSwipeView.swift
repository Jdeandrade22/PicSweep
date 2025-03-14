//
//  PhotoSwipeView.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos

class PhotoLibraryManager: ObservableObject {
    @Published var photos: [PlatformImage] = []
    @Published var photoAssets: [PHAsset] = []
    @Published var totalPhotos: Int = 0
    @Published var processedPhotos: Int = 0
    @Published var currentPhoto: PlatformImage?

    func removeCurrentPhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
        photoAssets.remove(at: index)
        updateCurrentPhoto(at: index)
    }
    
    func updateCurrentPhoto(at index: Int) {
        guard index < photos.count else {
            currentPhoto = nil
            return
        }
        currentPhoto = photos[index]
    }

    func fetchPhotos() {
        DispatchQueue.main.async {
            self.photos.removeAll()
            self.photoAssets.removeAll()
            self.processedPhotos = 0
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                var tempAssets: [PHAsset] = []
                var tempImages: [PlatformImage] = []
                
                fetchResult.enumerateObjects { asset, _, _ in
                    tempAssets.append(asset)
                }
                
                DispatchQueue.main.async {
                    self.totalPhotos = tempAssets.count
                }
                
                tempAssets.shuffle()
                
                for asset in tempAssets {
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 300, height: 300)
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                        if let image = image {
                            DispatchQueue.main.async {
                                self.photos.append(image)
                                self.photoAssets.append(asset)
                                self.processedPhotos += 1
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PhotoSwipeView: View {
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @State private var currentIndex = 0
    @State private var translation: CGSize = .zero
    @State private var showDeleteConfirmation = false
    @State private var showKeepConfirmation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let currentPhoto = photoLibraryManager.currentPhoto {
                    Image(platformImage: currentPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: translation.width, y: 0)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    translation = value.translation
                                }
                                .onEnded { value in
                                    handleSwipe(with: value.translation, in: geometry.size)
                                }
                        )
                } else {
                    Text("No photos available")
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("Delete Photo?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteCurrentPhoto()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Keep Photo?", isPresented: $showKeepConfirmation) {
            Button("Keep", role: .none) {
                keepCurrentPhoto()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            photoLibraryManager.fetchPhotos()
        }
    }
    
    private func handleSwipe(with translation: CGSize, in size: CGSize) {
        let threshold = size.width * 0.5
        
        if translation.width < -threshold {
            showDeleteConfirmation = true
        } else if translation.width > threshold {
            showKeepConfirmation = true
        }
        
        withAnimation {
            self.translation = .zero
        }
    }
    
    private func deleteCurrentPhoto() {
        photoLibraryManager.removeCurrentPhoto(at: currentIndex)
        moveToNextPhoto()
    }
    
    private func keepCurrentPhoto() {
        moveToNextPhoto()
    }
    
    private func moveToNextPhoto() {
        if currentIndex < photoLibraryManager.photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        photoLibraryManager.updateCurrentPhoto(at: currentIndex)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if os(iOS)
        self.init(uiImage: platformImage)
        #else
        self.init(nsImage: platformImage)
        #endif
    }
}

// Enhanced PhotoInfoView with more details
struct PhotoInfoView: View {
    let asset: PHAsset
    @State private var locationString: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let date = asset.creationDate {
                Text("Date: \(date.formatted(date: .long, time: .shortened))")
                    .font(.caption)
            }
            
            if asset.location != nil {
                Text("Location: \(locationString)")
                    .font(.caption)
            }
            
            Text("Size: \(formatFileSize(asset.pixelWidth * asset.pixelHeight * 4))")
                .font(.caption)
            
            if asset.isFavorite {
                Text("⭐️ Favorite")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
        .onAppear {
            if let location = asset.location {
                formatLocation(location)
            }
        }
    }
    
    private func formatLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        locationString = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    DispatchQueue.main.async {
                        locationString = city
                    }
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
//

