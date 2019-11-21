import Foundation

class URLSessionRepository: Repository {

    private let gitSearchRepositoryEndPoint = "https://api.github.com/search/repositories"

    /// The previous requested git API search rate limiting remaining
    private var prevXRateLimitRemainingResult: Int = 0

    /// The previous requested git API search rate limiting time remaining to reset
    private var prevXRateLimitResetResult: Int = 0

    /// The previous requested git API search rate limiting time reached status
    private var prevRateLimitingReachedStatus: Bool = false

    /// Requests the swift repositories from GitHub API
    func getSwiftRepositories(page: Int, perPage: Int, completion: @escaping (Result<GitRepositoryQueryResult>) -> Void) {

        // Returns an error if the Rate Limiting is reached
        let xRatingLimit = calculateXRateLimiting()
        guard !xRatingLimit.isLimitReached else {
            let errorMessage = String.localizedStringWithFormat(LocalizedString.xRatingLimitRrror.value, xRatingLimit.secondsRemainingToReset)
            completion(.error(RepositoryError(with: errorMessage)))
            return
        }

        let url = gitSearchRepositoryEndPointURLWithQueryParameters(page: page, perPage: perPage)

        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(RepositoryError(with: error.localizedDescription)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.error(RepositoryError(with: LocalizedString.unexpectedNetworkError.value)))
                }
                return
            }

            // Read the GitHub Header Rate Limiting information
            if let response = response as? HTTPURLResponse,
                let headers = response.allHeaderFields as? [String: String],
                let xRateLimitRemainingStr = headers["X-RateLimit-Remaining"],
                let xRateLimitRemaining = Int(xRateLimitRemainingStr),
                let xRateLimitResetStr = headers["X-RateLimit-Reset"],
                let xRateLimitReset = Int(xRateLimitResetStr) {
                    self.prevXRateLimitRemainingResult = xRateLimitRemaining
                    self.prevXRateLimitResetResult = xRateLimitReset
            }

            do {
               let queryResult = try JSONDecoder().decode(GitRepositoryQueryResult.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(queryResult))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.error(RepositoryError(with: error.localizedDescription)))
                }
            }
        }.resume()
    }

    // MARK: - Helpers

    /// Returns the calculated GitHub API Rate Limiting values based on the current stored values of
    /// `prevXRateLimitResetResult`, `prevXRateLimitRemainingResult` and `prevRateLimitingReachedStatus`
    ///
    /// - Returns:
    ///   - isLimitReached: `true` if the GitHub Rate Limiting requests was reached.
    ///   - secondsRemainingToReset: Seconds remaining to the GitHub Rate Limiting be reseted.
    private func calculateXRateLimiting() -> (isLimitReached: Bool, secondsRemainingToReset: Int) {
        let xRateLimitResetDate = Date(milliseconds: prevXRateLimitResetResult * 1000)
        let nowDate = Date()
        let msRemainingToReset = max(0, xRateLimitResetDate.millisecondsSince1970 - nowDate.millisecondsSince1970)
        let isLimitReached = prevXRateLimitRemainingResult == 0 && msRemainingToReset > 0
        prevRateLimitingReachedStatus = isLimitReached
        print("     RateLimitRemaining: \(prevXRateLimitRemainingResult), resetTimeLeft:\(msRemainingToReset/1000)s isLimitReached:\(isLimitReached)")
        return (isLimitReached: isLimitReached, secondsRemainingToReset: msRemainingToReset/1000)
    }

    /// The URL of the endpoint for searching in git repository, query by language `Swift`,
    /// sorted by `stars` and containing the the query parameters for pagination.
    /// - Parameters:
    ///   - page: The page used for pagination, first page starts on `1`.
    ///   - perPage: The amount of items per page to be requested.
    private func gitSearchRepositoryEndPointURLWithQueryParameters(page: Int, perPage: Int) -> URL {
        let formatedQueryString = "\(gitSearchRepositoryEndPoint)?q=language:swift&sort=stars&page=\(page)&per_page=\(perPage)"
        return URL(string: formatedQueryString)!
    }
}
