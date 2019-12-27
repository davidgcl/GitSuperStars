//
//  BaseViewController.swift
//  GitSuperStars
//
//  Created by David Lima on 05/11/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import UIKit
import RxSwift

public protocol BaseViewControllerDelegate: class {
    func didFinish(viewController: UIViewController)
}

public protocol BaseViewControllerProtocol: class {
    associatedtype ViewType: BaseViewProtocol
    associatedtype ViewModelType: BaseViewModelProtocol

    var baseView: ViewType? { get }
    var viewModel: ViewModelType? { get set }
    var disposeBag: DisposeBag { get }
    var delegateBase: BaseViewControllerDelegate? { get set }

    func setupView()
    func setupBinds()
    func addViewModelListeners()
    func addUIListeners()
    func removeUIListeners()
    func removeViewModelListeners()
}

open class BaseViewController<T: BaseViewProtocol, J: BaseViewModelProtocol>: UIViewController, BaseViewControllerProtocol {

    public typealias ViewType = T
    public typealias ViewModelType = J

    public var baseView: ViewType? {
        return view as? ViewType
    }

    public var viewModel: ViewModelType?
    public var disposeBag: DisposeBag = DisposeBag()
    public var delegateBase: BaseViewControllerDelegate?

    public init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        delegateBase?.didFinish(viewController: self)
        print("deinit: \(self.description)")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override open func loadView() {
        fatalError("loadView() has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewModelListeners()
        addUIListeners()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        removeUIListeners()
        removeViewModelListeners()
    }

    open func setupView() {}
    open func setupBinds() {}

    open func addViewModelListeners() {}
    open func addUIListeners() {}

    open func removeUIListeners() {}
    open func removeViewModelListeners() {}
}
