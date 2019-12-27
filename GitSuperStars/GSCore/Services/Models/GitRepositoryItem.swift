import Foundation

public struct GitRepositoryItem: Codable {
    public let id: Double
    public let name: String
    public let stars: Double
    public var owner: Owner
}

public extension GitRepositoryItem {
    struct Owner: Codable {
        public let login: String
        public let avatarUrl: String?

        /// This params is only available calling another end point for the user info passing the login param.
        public var name: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, name, owner
        case stars = "stargazers_count"
    }
}
