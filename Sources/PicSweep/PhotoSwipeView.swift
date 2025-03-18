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
    @Published var deletedCount: Int = 0
    @Published var savedCount: Int = 0
    @Published var lastAction: (type: ActionType, photo: PlatformImage, asset: PHAsset, index: Int)?
    @Published var canUndo: Bool = false
    @Published var currentIndex: Int = 0
    
    enum ActionType {
        case delete
        case save
    }

    func removeCurrentPhoto(at index: Int) {
        guard index < photos.count else { return }
        let deletedPhoto = photos[index]
        let deletedAsset = photoAssets[index]
        photos.remove(at: index)
        photoAssets.remove(at: index)
        deletedCount += 1
        lastAction = (.delete, deletedPhoto, deletedAsset, index)
        canUndo = true
        updateCurrentPhoto(at: index)
    }
    
    func keepCurrentPhoto(at index: Int) {
        savedCount += 1
        let currentPhoto = photos[index]
        let currentAsset = photoAssets[index]
        lastAction = (.save, currentPhoto, currentAsset, index)
        canUndo = true
    }
    
    func undoLastAction() {
        guard let lastAction = lastAction else { return }
        
        switch lastAction.type {
        case .delete:
            photos.insert(lastAction.photo, at: lastAction.index)
            photoAssets.insert(lastAction.asset, at: lastAction.index)
            deletedCount -= 1
            currentIndex = lastAction.index
            updateCurrentPhoto(at: lastAction.index)
            
        case .save:
            savedCount -= 1
            currentIndex = lastAction.index
            updateCurrentPhoto(at: lastAction.index)
        }
        
        self.lastAction = nil
        canUndo = false
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
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                if newStatus == .authorized {
                    self?.fetchPhotosFromLibrary()
                }
            }
        } else if status == .authorized {
            fetchPhotosFromLibrary()
        }
    }
    
    private func fetchPhotosFromLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var tempAssets: [PHAsset] = []
        
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
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self?.photos.append(image)
                        self?.photoAssets.append(asset)
                        self?.processedPhotos += 1
                        
                        if self?.processedPhotos == 1 {
                            self?.currentPhoto = image
                        }
                    }
                }
            }
        }
    }

    func moveToNextPhoto() {
        if currentIndex < photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        updateCurrentPhoto(at: currentIndex)
    }
}

struct PhotoSwipeView: View {
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @State private var translation: CGSize = .zero
    @State private var keepAnimation = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    if let currentPhoto = photoLibraryManager.currentPhoto {
                        Image(platformImage: currentPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(x: translation.width, y: 0)
                            .rotationEffect(.degrees(Double(translation.width / geometry.size.width) * 25))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        translation = value.translation
                                    }
                                    .onEnded { value in
                                        handleSwipe(with: value.translation, in: geometry.size)
                                    }
                            )
                            .overlay(
                                Group {
                                    if translation.width > 0 {
                                        Text("KEEP")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                            .padding()
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(10)
                                            .offset(x: translation.width - 100)
                                    } else if translation.width < 0 {
                                        Text("DELETE")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .padding()
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(10)
                                            .offset(x: translation.width + 100)
                                    }
                                }
                            )
                    } else {
                        Text("No photos available")
                            .foregroundColor(.secondary)
                    }
                }
                .overlay(
                    VStack {
                        HStack {
                            if photoLibraryManager.canUndo {
                                Button(action: {
                                    withAnimation {
                                        photoLibraryManager.undoLastAction()
                                    }
                                }) {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding()
                            }
                            Spacer()
                            Button(action: {
                                showShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                        Spacer()
                    }
                )
            }
            
            // Progress Bar and Counters
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // Delete bar (grows from left)
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: min(CGFloat(photoLibraryManager.deletedCount) / CGFloat(max(photoLibraryManager.deletedCount + photoLibraryManager.savedCount, 1)) * geometry.size.width, geometry.size.width), height: 20)
                        
                        // Keep bar (grows from right)
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: min(CGFloat(photoLibraryManager.savedCount) / CGFloat(max(photoLibraryManager.deletedCount + photoLibraryManager.savedCount, 1)) * geometry.size.width, geometry.size.width), height: 20)
                    }
                    .cornerRadius(10)
                }
                .frame(height: 20)
                .padding(.horizontal)
                
                HStack {
                    Text("Delete: \(photoLibraryManager.deletedCount)")
                        .foregroundColor(.red)
                    Spacer()
                    Text("Keep: \(photoLibraryManager.savedCount)")
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color.black.opacity(0.1))
        }
        .sheet(isPresented: $showShareSheet) {
            if let currentPhoto = photoLibraryManager.currentPhoto {
                ShareSheet(activityItems: [currentPhoto])
            }
        }
        .onAppear {
            photoLibraryManager.fetchPhotos()
        }
    }
    
    private func handleSwipe(with translation: CGSize, in size: CGSize) {
        let threshold = size.width * 0.3
        
        if translation.width < -threshold {
            deleteCurrentPhoto()
        } else if translation.width > threshold {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                keepAnimation = true
                self.translation = CGSize(width: size.width * 2, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                keepCurrentPhoto()
            }
        }
        
        withAnimation {
            self.translation = .zero
            self.keepAnimation = false
        }
    }
    
    private func deleteCurrentPhoto() {
        if photoLibraryManager.currentIndex < photoLibraryManager.photoAssets.count {
            let asset = photoLibraryManager.photoAssets[photoLibraryManager.currentIndex]
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
            }) { success, error in
                if success {
                    DispatchQueue.main.async {
                        photoLibraryManager.removeCurrentPhoto(at: photoLibraryManager.currentIndex)
                        photoLibraryManager.moveToNextPhoto()
                    }
                }
            }
        }
    }
    
    private func keepCurrentPhoto() {
        photoLibraryManager.keepCurrentPhoto(at: photoLibraryManager.currentIndex)
        photoLibraryManager.moveToNextPhoto()
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

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

//

