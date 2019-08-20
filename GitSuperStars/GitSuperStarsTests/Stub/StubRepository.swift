import Foundation
@testable import GitSuperStars

class StubRepository: Repository {

    /// The stubbed result
    private let result: Result<GitRepositoryQueryResult>
    
    init(with result: Result<GitRepositoryQueryResult> ) {
        self.result = result
    }
    
    func getSwiftRepositories(page:Int, perPage:Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void) {
        completion(result)
    }
}

extension StubRepository {
    
    static func loadMockedGitRepositoryQueryResult() -> GitRepositoryQueryResult {
        let bundle = Bundle(for: HomeViewModelTests.self)
        let url = bundle.url(forResource: "mockedGitHubRepositoriesResponse", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let queryResult = try! JSONDecoder().decode(GitRepositoryQueryResult.self, from: data)
        return queryResult
    }
    
}
