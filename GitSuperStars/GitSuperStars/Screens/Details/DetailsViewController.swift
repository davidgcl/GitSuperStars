//
//  DetailsViewController.swift
//  
//
//  Created by David Lima on 05/11/19.
//

import UIKit
import RxSwift

protocol DetailsViewControllerDelegate: class {
    
}

class DetailsViewController<T: DetailsView, J: DetailsViewModel>: BaseViewController<T, J> {

    weak var delegate: DetailsViewControllerDelegate?

    override func loadView() {
        self.view = DetailsView(frame: UIScreen.main.bounds)
    }
}
