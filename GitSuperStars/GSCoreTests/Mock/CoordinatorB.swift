//
//  File.swift
//  GSCoreTests
//
//  Created by David Lima on 23/12/19.
//  Copyright © 2019 David Lima. All rights reserved.
//

import UIKit
import GSCore

class CoordinatorB: Coordinator {
    
    override func start() {
        let viewController = UIViewController()
        rootViewController = viewController
        
        presenter?.pushViewController(viewController, animated: false)
    }
}
