import Foundation

#if os(iOS)
import UIKit
public typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#endif

extension PlatformImage {
    #if os(macOS)
    var cgImage: CGImage? {
        guard let data = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }
        return bitmap.cgImage
    }
    #endif
} 