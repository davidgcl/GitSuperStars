import Foundation

public struct GitRepositoryQueryResult: Codable {
    public let totalCount: Int
    public var items: [GitRepositoryItem]

}

public extension GitRepositoryQueryResult {
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}
