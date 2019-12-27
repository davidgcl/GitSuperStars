//
//  DetailsViewController.swift
//  
//
//  Created by David Lima on 05/11/19.
//

import UIKit
import GSCore

public protocol DetailsViewControllerDelegate: class {
    
}

public class DetailsViewController<T: DetailsView, J: DetailsViewModel>: BaseViewController<T, J> {

    public weak var delegate: DetailsViewControllerDelegate?

    override public func loadView() {
        self.view = DetailsView(frame: UIScreen.main.bounds)
    }
}
