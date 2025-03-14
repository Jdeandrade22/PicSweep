import Foundation
import PlatformTypes

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct Photo: Identifiable, Codable {
    public let id: UUID
    public let url: URL
    public let createdAt: Date
    public var metadata: [String: String]
    public var platformImage: PlatformImage?
    
    public init(id: UUID = UUID(),
         url: URL,
         createdAt: Date = Date(),
         metadata: [String: String] = [:],
         platformImage: PlatformImage? = nil) {
        self.id = id
        self.url = url
        self.createdAt = createdAt
        self.metadata = metadata
        self.platformImage = platformImage
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case createdAt
        case metadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        url = try container.decode(URL.self, forKey: .url)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        metadata = try container.decode([String: String].self, forKey: .metadata)
        platformImage = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(metadata, forKey: .metadata)
    }
}

#if os(iOS)
public typealias PlatformImage = UIImage
#elseif os(macOS)
public typealias PlatformImage = NSImage
#endif 