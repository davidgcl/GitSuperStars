import UIKit

enum Font {
    case robotoRegular
    case robotoLight
    case robotoMedium
    case robotoBold
}

extension Font {

    func value(size: CGFloat) -> UIFont {
        switch self {
        case .robotoRegular: return UIFont(name: "Roboto-Regular", size: size)!
        case .robotoLight: return UIFont(name: "Roboto-Light", size: size)!
        case .robotoMedium: return UIFont(name: "Roboto-Medium", size: size)!
        case .robotoBold: return UIFont(name: "Roboto-Bold", size: size)!
        }
    }
}
