import Foundation

struct GitRepositoryQueryResult: Codable {
    
    let totalCount: Int
    var items: [GitRepositoryItem]
    
}

extension GitRepositoryQueryResult {
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}
