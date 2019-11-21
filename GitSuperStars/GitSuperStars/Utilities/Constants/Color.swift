import UIKit

enum Color {

    case colorPrimary
    case colorPrimaryDark
    case colorPrimaryDarker
    case colorPrimaryLight
    case colorPrimaryLighter

    case colorAccent
    case colorAccentDark
    case colorAccentDarker
    case colorAccentLight
    case colorAccentLighter

    case colorGrey
    case colorGreyDark
    case colorGreyDarker
    case colorGreyLight
    case colorGreyLighter

    case colorWhite
    case colorBlack
    case colorRed

    case colorDebug

    case custom(hexString: String, alpha: Double)

    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

extension Color {

    var value: UIColor {
        var instanceColor = UIColor.clear

        switch self {
        case .colorPrimary: instanceColor = UIColor(hexString: "#77C0EF")
        case .colorPrimaryDark: instanceColor = UIColor(hexString: "#52AAE2")
        case .colorPrimaryDarker: instanceColor = UIColor(hexString: "#3090CE")
        case .colorPrimaryLight: instanceColor = UIColor(hexString: "#A3D6F8")
        case .colorPrimaryLighter: instanceColor = UIColor(hexString: "#DBF0FE")

        case .colorAccent: instanceColor = UIColor(hexString: "#FFC377")
        case .colorAccentDark: instanceColor = UIColor(hexString: "#FFB252")
        case .colorAccentDarker: instanceColor = UIColor(hexString: "#FFA32F")
        case .colorAccentLight: instanceColor = UIColor(hexString: "#FFD6A3")
        case .colorAccentLighter: instanceColor = UIColor(hexString: "#FFEFDA")

        case .colorGrey: instanceColor = UIColor(hexString: "#C2C2C2")
        case .colorGreyDark: instanceColor = UIColor(hexString: "#818181")
        case .colorGreyDarker: instanceColor = UIColor(hexString: "#3C3C3C")
        case .colorGreyLight: instanceColor = UIColor(hexString: "#F0F0F0")
        case .colorGreyLighter: instanceColor = UIColor(hexString: "#FAFAFA")

        case .colorWhite: instanceColor = UIColor(hexString: "#FFFFFF")
        case .colorBlack: instanceColor = UIColor(hexString: "#000000")

        case .colorRed: instanceColor = UIColor(hexString: "#E57373")

        case .colorDebug: instanceColor = UIColor(hexString: "#00FF00").withAlphaComponent(CGFloat(0.25))

        case .custom(let hexValue, let opacity): instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }

        return instanceColor
    }
}
