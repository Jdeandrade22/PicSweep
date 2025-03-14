import XCTest
import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif
@testable import PicSweep

extension XCTestCase {
    func createTestImage() -> PlatformImage {
        #if os(iOS)
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        #else
        let size = CGSize(width: 100, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.red.set()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
        #endif
    }
    
    func createTestPhoto() -> Photo {
        return Photo(
            id: UUID(),
            platformImage: createTestImage(),
            metadata: PhotoMetadata(
                creationDate: Date(),
                location: nil,
                size: 1024,
                isFavorite: false
            )
        )
    }
} 