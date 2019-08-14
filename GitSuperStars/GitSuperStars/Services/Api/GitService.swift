import Moya

enum GitService {
    case getSwiftRepositories(page:Int, perPage:Int)
    case getUser(login:String)
}

extension GitService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .getSwiftRepositories(_, _):
            return "/search/repositories"
        case .getUser(let login):
            return "/users/\(login)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSwiftRepositories(_, _):
            return .get
        case .getUser(_):
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getSwiftRepositories(_, _):
            return "{}".data(using: .utf8)!
        case .getUser(_):
            return "{}".data(using: .utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .getSwiftRepositories(let page, let perPage):
            return .requestParameters(parameters: ["q":"language:swift", "sort":"stars", "page":page, "per_page":perPage], encoding: URLEncoding.queryString)
        case .getUser(_):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        
        if (Settings.Credentials.GIT_BASIC_AUTH_TOKEN != "") {
            return [ "Authorization": Settings.Credentials.GIT_BASIC_AUTH_TOKEN ]
        } else {
            return [:]
        }
        
    }
}
