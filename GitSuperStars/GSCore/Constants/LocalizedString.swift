import Foundation

public enum LocalizedString {
    case error
    case failedToProccessTheResultsError
    case apiRequestError
    case unexpectedError
    case unexpectedNetworkError
    case pullToRefresh
    case xRatingLimitRrror
    case stars
    case star
    case confirm
}

public extension LocalizedString {

    var value: String {
        return NSLocalizedString(String(describing: self), comment: "")
    }
    
    func valueWith(params: [String]) -> String {
        var text = self.value
        var count: Int = 1
        for param in params {
            text = text.replacingOccurrences(of: "$\(count)", with: param)
            count += 1
        }
        return text
    }
    
    func valueFor(target: AnyClass) -> String {
        return NSLocalizedString(
            String(describing: self),
            tableName: nil,
            bundle: Bundle(for: target),
            value: "",
            comment: "")
    }
    
    func valueFor(target: AnyClass, params: [String]) -> String {
        var text = self.valueFor(target: target)
        var count: Int = 1
        for param in params {
            text = text.replacingOccurrences(of: "$\(count)", with: param)
            count += 1
        }
        return text
    }
}
