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
    @Published var totalPhotos: Int = 0
    @Published var processedPhotos: Int = 0
    @Published var categories: [String: [PHAsset]] = [:] // Store categorized photos

    func fetchPhotos() {
        // Clear existing photos before fetching new ones
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
                
                // Create arrays to store assets and images temporarily
                var tempAssets: [PHAsset] = []
                var tempImages: [UIImage] = []
                
                // First, collect all assets
                fetchResult.enumerateObjects { asset, _, _ in
                    tempAssets.append(asset)
                }
                
                // Set total photos count
                DispatchQueue.main.async {
                    self.totalPhotos = tempAssets.count
                }
                
                // Shuffle the assets array
                tempAssets.shuffle()
                
                // Now process the shuffled assets
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

    func categorizePhoto(_ asset: PHAsset, category: String) {
        if categories[category] == nil {
            categories[category] = []
        }
        categories[category]?.append(asset)
    }
}

// PhotoSwipeView: Displays photos and allows swiping
struct PhotoSwipeView: View {
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @State private var currentIndex = 0
    @State private var showPhotoInfo = false
    @State private var isFocusMode = false
    @State private var showCategories = false
    @State private var selectedCategory: String?
    @State private var dragOffset: CGFloat = 0
    @State private var showGestureGuide = true
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private let categories = ["Keep", "Delete", "Family", "Work", "Travel", "Food"]
    
    var body: some View {
        VStack {
            if !photoLibraryManager.photos.isEmpty {
                if !isFocusMode {
                    // Progress bar
                    ProgressView(value: Double(photoLibraryManager.processedPhotos), total: Double(photoLibraryManager.totalPhotos))
                        .padding()
                    
                    // Photo count
                    Text("\(photoLibraryManager.processedPhotos) of \(photoLibraryManager.totalPhotos) photos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
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
                                    withAnimation {
                                        if value.translation.width > 100 {
                                            // Save logic
                                            nextPhoto()
                                        } else if value.translation.width < -100 {
                                            // Delete logic
                                            deletePhoto()
                                            nextPhoto()
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )
                    
                    if showGestureGuide && !isFocusMode {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.black.opacity(0.5))
                        }
                    }
                }
                
                if !isFocusMode {
                    if showPhotoInfo {
                        PhotoInfoView(asset: photoLibraryManager.photoAssets[currentIndex])
                            .transition(.move(edge: .bottom))
                    }
                    
                    // Category buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    photoLibraryManager.categorizePhoto(photoLibraryManager.photoAssets[currentIndex], category: category)
                                    nextPhoto()
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Control buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            withAnimation {
                                isFocusMode.toggle()
                            }
                        }) {
                            Image(systemName: isFocusMode ? "eye.slash.fill" : "eye.fill")
                                .font(.title2)
                        }
                        
                        Button(action: {
                            photoLibraryManager.fetchPhotos()
                            currentIndex = 0
                        }) {
                            Image(systemName: "shuffle")
                                .font(.title2)
                        }
                        
                        Button(action: {
                            withAnimation {
                                showGestureGuide.toggle()
                            }
                        }) {
                            Image(systemName: showGestureGuide ? "hand.raised.fill" : "hand.raised")
                                .font(.title2)
                        }
                    }
                    .padding(.bottom)
                }
            } else {
                Text("No photos available")
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
        showDeleteAlert = true
    }
    
    private func performDelete() {
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
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = error?.localizedDescription ?? "Failed to delete photo"
                    showErrorAlert = true
                }
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
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
