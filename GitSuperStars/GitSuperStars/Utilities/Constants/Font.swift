import UIKit

enum Font {
    case roboto_regular
    case roboto_light
    case roboto_medium
    case roboto_bold
}

extension Font {
    
    func value(size:CGFloat) -> UIFont {
        switch self {
        case .roboto_regular: return UIFont(name: "Roboto-Regular", size: size)!
        case .roboto_light: return UIFont(name: "Roboto-Light", size: size)!
        case .roboto_medium: return UIFont(name: "Roboto-Medium", size: size)!
        case .roboto_bold: return UIFont(name: "Roboto-Bold", size: size)!
        }
    }
}
