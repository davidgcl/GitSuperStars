import Foundation

struct GitRepositoryItem: Codable {
    let id: Double
    let name: String
    let stars: Double
    var owner: Owner
}

extension GitRepositoryItem {
    struct Owner: Codable {
        let login: String
        let avatarUrl: String?

        /// This params is only available calling another end point for the user info passing the login param.
        var name: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, name, owner
        case stars = "stargazers_count"
    }
}
