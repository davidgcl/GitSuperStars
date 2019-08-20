import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}

class RepositoryError: NSObject, LocalizedError {
    
    private var _localizedDescription:String
    
    init(with localizedDescription:String) {
        _localizedDescription = localizedDescription
    }
    
    override var description: String {
        get {
            return _localizedDescription
        }
    }
    
    var errorDescription: String? {
        get {
            return _localizedDescription
        }
    }
}

protocol Repository: class {
    
    /// Returns the most rated Swift repositories, fetched on the GitHub repository.
    ///
    /// The request is not authenticated, so we are dealing with a very limited request limit
    /// More information about this on: [GitHub Rate Limit](https://developer.github.com/v3/rate_limit/)
    ///
    /// - Parameters:
    ///   - page: The page used for pagination, first page starts on `1`.
    ///   - perPage: The amount of items per page to be requested.
    ///   - completion: The completion closure, returns a Result<GitRepositoryQueryResult>
    func getSwiftRepositories(page:Int, perPage:Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void)
    
}
