import UIKit

public enum Font {
    case robotoRegular
    case robotoLight
    case robotoMedium
    case robotoBold
}

public extension Font {

    func value(size: CGFloat) -> UIFont {
        switch self {
        case .robotoRegular: return UIFont(name: "Roboto-Regular", size: size)!
        case .robotoLight: return UIFont(name: "Roboto-Light", size: size)!
        case .robotoMedium: return UIFont(name: "Roboto-Medium", size: size)!
        case .robotoBold: return UIFont(name: "Roboto-Bold", size: size)!
        }
    }
    
    var fileName: String {
        switch self {
        case .robotoRegular: return "Roboto-Regular.ttf"
        case .robotoLight: return "Roboto-Light.ttf"
        case .robotoMedium: return "Roboto-Medium.ttf"
        case .robotoBold: return "Roboto-Bold.ttf"
        }
    }
}

public extension Font {

    static func registerFonts() {
        
        let fontFileNames = [
            Font.robotoRegular.fileName,
            Font.robotoLight.fileName,
            Font.robotoMedium.fileName,
            Font.robotoBold.fileName
        ]
        
        guard let bundle = Bundle(identifier: "net.seuaplicativo.GSCore") else {
            print("UIFont+:  Failed to register font - bundle not found.")
            return
        }
        
        fontFileNames.forEach { fontFileName in
            
            guard let pathForResourceString = bundle.path(forResource: fontFileName, ofType: nil) else {
                print("UIFont+:  Failed to register font - path for resource not found.")
                return
            }

            guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
                print("UIFont+:  Failed to register font - font data could not be loaded.")
                return
            }

            guard let dataProvider = CGDataProvider(data: fontData) else {
                print("UIFont+:  Failed to register font - data provider could not be loaded.")
                return
            }

            guard let font = CGFont(dataProvider) else {
                print("UIFont+:  Failed to register font - font could not be loaded.")
                return
            }

            var errorRef: Unmanaged<CFError>? = nil
            if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
                print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
        }
    }
}
