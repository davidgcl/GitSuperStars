//
//  Image.swift
//  GSCore
//
//  Created by David Lima on 25/12/19.
//  Copyright © 2019 David Lima. All rights reserved.
//

import UIKit

public enum Image: String {
    case gitSuperStarsLogo = "gitSuperStarsLogo"
    case ownerImagePlaceholder = "ownerImagePlaceholder"
}

public extension Image {
    
    var value: UIImage? {
        return UIImage(named: self.rawValue, in: coreBundle, compatibleWith: nil)
    }
}
