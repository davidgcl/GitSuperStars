import Foundation

public enum Result<T> {
    case success(T)
    case error(Error)
}

public class RepositoryError: NSObject, LocalizedError {

    private var _localizedDescription: String

    public init(with localizedDescription: String) {
        _localizedDescription = localizedDescription
    }

    override public var description: String {
        return _localizedDescription
    }

    public var errorDescription: String? {
        return _localizedDescription
    }
}

public protocol Repository: class {

    /// Returns the most rated Swift repositories, fetched on the GitHub repository.
    ///
    /// The request is not authenticated, so we are dealing with a very limited request limit
    /// More information about this on: [GitHub Rate Limit](https://developer.github.com/v3/rate_limit/)
    ///
    /// - Parameters:
    ///   - page: The page used for pagination, first page starts on `1`.
    ///   - perPage: The amount of items per page to be requested.
    ///   - completion: The completion closure, returns a Result<GitRepositoryQueryResult>
    func getSwiftRepositories(page: Int, perPage: Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void)
}
