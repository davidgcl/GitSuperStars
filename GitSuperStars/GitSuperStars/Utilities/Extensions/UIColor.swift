import UIKit

/// ref: https://medium.com/ios-os-x-development/a-smart-way-to-manage-colours-schemes-for-ios-applications-development-923ef976be55
extension UIColor {

    convenience init(hexString: String) {

        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner          = Scanner(string: hexString as String)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let colorComponentR = Int(color >> 16) & mask
        let colorComponentG = Int(color >> 8) & mask
        let colorComponentB = Int(color) & mask

        let red   = CGFloat(colorComponentR) / 255.0
        let green = CGFloat(colorComponentG) / 255.0
        let blue  = CGFloat(colorComponentB) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
