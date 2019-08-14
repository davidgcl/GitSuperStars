import UIKit

extension UIView {
    
    /// Returns the safe area layout guide if available (ios 11+) otherwise
    /// returns the layout margins guide as default.
    var extSafeArea: UILayoutGuide {
        get {
            if #available(iOS 11.0, *) {
                return self.safeAreaLayoutGuide
            } else {
                return layoutMarginsGuide
            }
        }
    }
    
}
