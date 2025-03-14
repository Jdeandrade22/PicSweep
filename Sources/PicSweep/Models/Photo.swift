import Foundation

public struct Photo: Identifiable, Codable {
    public let id: UUID
    public let url: URL
    public let createdAt: Date
    public var metadata: [String: String]
    
    public init(id: UUID = UUID(), url: URL, createdAt: Date = Date(), metadata: [String: String] = [:]) {
        self.id = id
        self.url = url
        self.createdAt = createdAt
        self.metadata = metadata
    }
} 