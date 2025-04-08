//
//  PhotoManager.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos
import Foundation

public class PhotoManager: ObservableObject {
    @Published private(set) var photos: [Photo] = []
    @Published var currentPhoto: PlatformImage?
    @Published var currentIndex: Int = 0
    
    private let imageManager = PHImageManager.default()

    func loadPhotos() {
        PhotoManager.fetchPhotos { assets in
            let shuffledAssets = PhotoManager.shufflePhotos(assets)
            DispatchQueue.main.async {
                // Convert PHAssets to our Photo model
                self.photos = shuffledAssets.compactMap { asset in
                    guard let localIdentifier = UUID(uuidString: asset.localIdentifier) else { return nil }
                    return Photo(
                        id: localIdentifier,
                        url: URL(string: "photos://\(asset.localIdentifier)")!,
                        createdAt: asset.creationDate ?? Date(),
                        metadata: ["assetIdentifier": asset.localIdentifier]
                    )
                }
                self.currentIndex = 0
                self.loadCurrentPhoto()
            }
        }
    }

    func loadCurrentPhoto() {
        guard currentIndex < photos.count else { return }
        let photo = photos[currentIndex]
        guard let assetId = photo.metadata["assetIdentifier"],
              let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            return
        }
        
        PhotoManager.getImage(from: asset) { image in
            DispatchQueue.main.async {
                self.currentPhoto = image
            }
        }
    }

    func nextPhoto() {
        if currentIndex < photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        loadCurrentPhoto()
    }

    func previousPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = photos.count - 1
        }
        loadCurrentPhoto()
    }

    static func fetchPhotos(completion: @escaping ([PHAsset]) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 50

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []

        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        DispatchQueue.main.async {
            completion(assets)
        }
    }

    static func shufflePhotos(_ photos: [PHAsset]) -> [PHAsset] {
        return photos.shuffled()
    }

    static func getImage(from asset: PHAsset, completion: @escaping (PlatformImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, info in
            if let error = info?[PHImageErrorKey] as? Error {
                print("Error loading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let image = image else {
                print("Failed to load image")
                completion(nil)
                return
            }
            
            #if os(iOS)
            // Convert to sRGB color space to avoid color profile issues
            if let cgImage = image.cgImage {
                let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
                let context = CIContext(options: nil)
                let ciImage = CIImage(cgImage: cgImage)
                if let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: colorSpace) {
                    let processedImage = UIImage(cgImage: outputCGImage)
                    completion(processedImage)
                    return
                }
            }
            completion(image)
            #else
            if let image = image {
                let nsImage = NSImage(size: targetSize)
                nsImage.addRepresentation(NSBitmapImageRep(cgImage: image.cgImage!))
                completion(nsImage)
            } else {
                completion(nil)
            }
            #endif
        }
    }

    func getPhoto(id: UUID?) -> Photo? {
        guard let id = id else { return nil }
        return photos.first { $0.id == id }
    }
    
    func addPhoto(_ photo: Photo) {
        photos.append(photo)
    }
    
    func removePhoto(_ photo: Photo) {
        photos.removeAll { $0.id == photo.id }
    }
    
    func updatePhoto(_ photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
        }
    }
}
