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
    
    func getSwiftRepositories(page:Int, perPage:Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void)
    
}
