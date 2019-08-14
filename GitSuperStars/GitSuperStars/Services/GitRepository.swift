import Foundation
import Moya

class GitRepository: Repository {
    
    /// For HTTP debug, use:
    /// private var gitProvider = MoyaProvider<GitService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    private var gitProvider = MoyaProvider<GitService>()
    
    /// Git repositories search rate limiting params
    private var prevXRateLimitRemainingResult:Int = 0
    private var prevXRateLimitResetResult:Int = 0
    private var prevRateLimitingReachedStatus: Bool = false
    
    func getSwiftRepositories(page:Int, perPage:Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void) {
        
        let xRatingLimit = calculateXRateLimiting()
        if xRatingLimit.isLimitReached {
            
            /// TODO: Skip the error and implement a delayed call to repeat this request before the xRateLimitRemaining time.
            let errorMessage = String.localizedStringWithFormat(LocalizedString.x_rating_limit_error.value, xRatingLimit.secondsRemainingToReset)
            completion(.error(RepositoryError(with: errorMessage)))
            
            return
        }
        
        gitProvider.request(.getSwiftRepositories(page: page, perPage: perPage)) { [unowned self] result in
            
            //if let strongSelf = self {
                switch result {
                case let .success(response):
                    do {
                        try _ = response.filterSuccessfulStatusCodes()
                        
                        /// Retrieve Rate Limit Information
                        if let headers = response.response?.allHeaderFields as NSDictionary? as! [String:String]?,
                            let xRateLimitRemaining = Int(headers["X-RateLimit-Remaining"]!),
                            let xRateLimitReset = Int(headers["X-RateLimit-Reset"]!) {
                            
                            self.prevXRateLimitRemainingResult = xRateLimitRemaining
                            self.prevXRateLimitResetResult = xRateLimitReset
                        }
                        
                        let gitRepositoryQueryResult = try JSONDecoder().decode(GitRepositoryQueryResult.self, from: response.data)
                        
                        completion(.success(gitRepositoryQueryResult))
                        
                    }
                    catch {
                        completion(.error(RepositoryError(with: LocalizedString.failed_to_proccess_the_results_error.value)))
                    }
                    
                case .failure(_):
                    completion(.error(RepositoryError(with: LocalizedString.api_request_error.value)))
                }
            //}
        }
        
    }
    
    private func calculateXRateLimiting() -> (isLimitReached:Bool, secondsRemainingToReset:Int, statusChanged:Bool) {
        
        let xRateLimitResetDate = Date(milliseconds: prevXRateLimitResetResult * 1000)
        let nowDate = Date()
        let msRemainingToReset = max(0, xRateLimitResetDate.millisecondsSince1970 - nowDate.millisecondsSince1970)
        let isLimitReached = prevXRateLimitRemainingResult == 0 && msRemainingToReset > 0
        let statusChanged = isLimitReached != prevRateLimitingReachedStatus
        prevRateLimitingReachedStatus = isLimitReached
        
        print("     RateLimitRemaining: \(prevXRateLimitRemainingResult), resetTimeLeft:\(msRemainingToReset/1000)s isLimitReached:\(isLimitReached)")
        
        return (isLimitReached, msRemainingToReset/1000, statusChanged)
    }
}
