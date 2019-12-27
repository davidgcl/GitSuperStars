import Foundation

public struct Settings {

    public struct Services {

        public struct Git {

            /// Only the first 1000 search results are available"
            /// https://developer.github.com/v3/search/
            static public let maxSearchLimit = 1000

            /// To avoid the frequency limitation "Rate Limiting", with the maximum results MAX_SEARCH_LIMIT (1000),
            /// and 30 requests per minute for basic authentication, to view all results in one minute
            /// scrolling rapidly, pagination must contain at least cei (1000/30) = 34 items per page.
            /// For guarantee, the number of items per page is being pre-set at 34 * 2 = 68
            /// ref: https://developer.github.com/v3/search/#rate-limit

            /// In case of use without authentication in Github, the limit "Rate Limiting" is limited to 10 requests per minute
            /// In this case it is safer the pagination is defined in 100 items per page, thus for the maximum of 1000 items
            /// rolled in less than a minute, we will have the requisitions within the limit.

            /// Do not exceed 100, as there is a limitation of results per query in this value
            /// ref: https://developer.github.com/v3/#pagination
            static public let itemsPerPage = 100

        }
    }

    internal struct Credentials {

        /// Authorized requests increase from 10 to 30 requests per minute, as it is a demonstration only,
        /// this implementation was sufficient, this is a token with authorization limited only to searches of repositories
        /// public, can be revoked at any time in the development console of Git.
        /// ref: https://developer.github.com/v3/search/#rate-limit

        /// Note: When uploading to Github, this token is detected and automatically revoked for security reasons
        /// a new one need to be generated to better use the app without the xRatingLimit restrictions
        /// The token has the format like below:
        /// ex: static let GIT_BASIC_AUTH_TOKEN = "token 1456e5d24271d91dc25c482e0f8fc01a3c1eb025"

        /// To generate one for your project, go to https://github.com/settings/tokens
        static let gitBasicAuthToken = ""
    }

}
