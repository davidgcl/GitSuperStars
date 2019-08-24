import Foundation
@testable import GitSuperStars

class StubRepository: Repository {

    private var stubbedResult: Result<GitRepositoryQueryResult>
    private var stubbedDelay: Double
    
    init(with result: Result<GitRepositoryQueryResult>, delay: Double = 0.0 ) {
        self.stubbedResult = result
        self.stubbedDelay = delay
    }
    
    func setStubbedResult(_ result: Result<GitRepositoryQueryResult> ) {
        self.stubbedResult = result
    }
    
    func setStubbedResultDelay(_ delay: Double ) {
        self.stubbedDelay = delay
    }
    
    func getSwiftRepositories(page:Int, perPage:Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void) {
        if stubbedDelay > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + stubbedDelay) { [weak self] in
                guard let self = self else { return }
                completion(self.stubbedResult)
            }
        } else {
            completion(stubbedResult)
        }
    }
}
