import Foundation

public extension Date {
    var millisecondsSince1970: Double {
        return (self.timeIntervalSince1970 * 1000.0).rounded()
    }

    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
