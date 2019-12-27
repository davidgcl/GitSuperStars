//
//  BaseView.swift
//  GitSuperStars
//
//  Created by David Lima on 05/11/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import UIKit

public protocol BaseViewProtocol: class {
    func setupView()
    func setupConstraints()
}

open class BaseView: UIView, BaseViewProtocol {

    private var wasSetupConstraintsCalledOnce = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        print("deinit: \(self.description)")
    }

    private func commonInit() {
        setupView()
    }

    override open func layoutSubviews() {
        if wasSetupConstraintsCalledOnce == false {
            wasSetupConstraintsCalledOnce = true
            setupConstraints()
        }
        super.layoutSubviews()
    }

    open func setupView() {}
    open func setupConstraints() {}
}
