import Foundation
@testable import GitSuperStars

class StubRepository: Repository {
    /// The stubbed result
    private let result: Result<GitRepositoryQueryResult>
    init(with result: Result<GitRepositoryQueryResult> ) {
        self.result = result
    }
    func getSwiftRepositories( page: Int, perPage: Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void ) {
        completion(result)
    }
}
