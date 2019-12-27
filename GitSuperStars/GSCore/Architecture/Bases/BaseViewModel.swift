//
//  BaseViewModel.swift
//  GitSuperStars
//
//  Created by David Lima on 05/11/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import Foundation

public protocol BaseViewModelProtocol: class {

}

open class BaseViewModel: NSObject, BaseViewModelProtocol {

    deinit {
        print("deinit: \(self.description)")
    }
}
