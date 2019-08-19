import Foundation

enum LocalizedString {
    
    case error
    case failed_to_proccess_the_results_error
    case api_request_error
    case unexpected_error
    case unexpected_network_error
    case pull_to_refresh
    case x_rating_limit_error
    case stars
    case star
    case ok
    
}

extension LocalizedString {
    
    var value: String {
        return NSLocalizedString(String(describing: self), comment: "")
    }
    
    func valueWith(params: [String]) -> String {
        var text = self.value
        var count:Int = 1
        for param in params {
            text = text.replacingOccurrences(of: "$\(count)", with: param)
            count = count + 1
        }
        return text
    }
}
