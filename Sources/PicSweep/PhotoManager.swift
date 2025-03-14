//
//  PhotoManager.swift
//  PicSweeper
//
//  Created by Jordan on 1/8/25.
//

import SwiftUI
import Photos
import Foundation
import Logging

public class PhotoManager: ObservableObject {
    private let logger = Logger(label: "com.picsweep.PhotoManager")
    @Published private(set) var photos: [Photo] = []
    @Published var currentPhoto: UIImage?
    @Published var currentIndex: Int = 0

    func loadPhotos() {
        PhotoManager.fetchPhotos { assets in
            let shuffledAssets = PhotoManager.shufflePhotos(assets) // Shuffle the photos
            DispatchQueue.main.async {
                self.photos = shuffledAssets
                self.currentIndex = 0 // Reset to the first photo
                self.loadCurrentPhoto()
            }
        }
    }

    func loadCurrentPhoto() {
        guard currentIndex < photos.count else { return }
        let asset = photos[currentIndex]
        PhotoManager.getUIImage(from: asset) { image in
            DispatchQueue.main.async {
                self.currentPhoto = image
            }
        }
    }

    func nextPhoto() {
        if currentIndex < photos.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // Loop back to the first photo
        }
        loadCurrentPhoto()
    }

    func previousPhoto() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = photos.count - 1 // Loop back to the last photo
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
        let shuffled = photos.shuffled()
        print("Shuffled photos:", shuffled)
        return shuffled
    }

    static func getUIImage(from asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300) // Adjust as needed
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
            completion(image)
        }
    }

    func getPhoto(id: UUID?) -> Photo? {
        guard let id = id else { return nil }
        return photos.first { $0.id == id }
    }
    
    func addPhoto(_ photo: Photo) {
        photos.append(photo)
        logger.info("Added photo with ID: \(photo.id)")
    }
    
    func removePhoto(_ photo: Photo) {
        photos.removeAll { $0.id == photo.id }
        logger.info("Removed photo with ID: \(photo.id)")
    }
    
    func updatePhoto(_ photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index] = photo
            logger.info("Updated photo with ID: \(photo.id)")
        }
    }
}
