//
//  BaseView.swift
//  GitSuperStars
//
//  Created by David Lima on 05/11/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import UIKit

protocol BaseViewProtocol: class {
    func setupView()
    func setupConstraints()
}

class BaseView: UIView, BaseViewProtocol {

    private var wasSetupConstraintsCalledOnce = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        print("deinit: \(self.description)")
    }

    private func commonInit() {
        setupView()
    }

    override func layoutSubviews() {
        if wasSetupConstraintsCalledOnce == false {
            wasSetupConstraintsCalledOnce = true
            setupConstraints()
        }
        super.layoutSubviews()
    }

    func setupView() {}
    func setupConstraints() {}
}
