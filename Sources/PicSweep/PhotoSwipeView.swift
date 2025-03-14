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
    @Published var photoAssets: [PHAsset] = []
    @Published var totalPhotos: Int = 0
    @Published var processedPhotos: Int = 0

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
                var tempImages: [UIImage] = []
                
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
    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            if !photoLibraryManager.photos.isEmpty {
                // Progress bar
                ProgressView(value: Double(photoLibraryManager.processedPhotos), total: Double(photoLibraryManager.totalPhotos))
                    .tint(Theme.primary)
                    .padding()
                
                // Photo count
                Text("\(photoLibraryManager.processedPhotos) of \(photoLibraryManager.totalPhotos) photos")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                
                ZStack {
                    Image(uiImage: photoLibraryManager.photos[currentIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(x: dragOffset)
                        .rotationEffect(.degrees(Double(dragOffset / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    withAnimation(.spring()) {
                                        if value.translation.width > 100 {
                                            nextPhoto()
                                        } else if value.translation.width < -100 {
                                            deletePhoto()
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )
                    
                    // Gesture guide
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(Theme.deleteColor)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(Theme.keepColor)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                    }
                }
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring()) {
                            photoLibraryManager.fetchPhotos()
                            currentIndex = 0
                        }
                    }) {
                        Image(systemName: "shuffle")
                            .font(.title2)
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.bottom)
            } else {
                Text("No photos available")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .onAppear {
            photoLibraryManager.fetchPhotos()
        }
        .alert("Delete Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performDelete()
            }
        } message: {
            Text("Are you sure you want to delete this photo? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func nextPhoto() {
        guard !photoLibraryManager.photos.isEmpty else { return }
        if currentIndex < photoLibraryManager.photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
    }
    
    private func deletePhoto() {
        showDeleteAlert = true
    }
    
    private func performDelete() {
        guard !photoLibraryManager.photoAssets.isEmpty else { return }
        
        let assetToDelete = photoLibraryManager.photoAssets[currentIndex]
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([assetToDelete] as NSFastEnumeration)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.photoLibraryManager.photos.remove(at: self.currentIndex)
                    self.photoLibraryManager.photoAssets.remove(at: self.currentIndex)
                    self.nextPhoto()
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to delete photo"
                    self.showErrorAlert = true
                }
            }
        }
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
            
            if let location = asset.location {
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
