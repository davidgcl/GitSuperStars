//
//  BaseViewController.swift
//  GitSuperStars
//
//  Created by David Lima on 05/11/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import UIKit
import RxSwift

protocol BaseViewControllerDelegate: class {
    func didFinish(viewController: UIViewController)
}

protocol BaseViewControllerProtocol: class {
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

class BaseViewController<T: BaseViewProtocol, J: BaseViewModelProtocol>: UIViewController, BaseViewControllerProtocol {

    typealias ViewType = T
    typealias ViewModelType = J

    var baseView: ViewType? {
        return view as? ViewType
    }

    var viewModel: ViewModelType?
    var disposeBag: DisposeBag = DisposeBag()
    var delegateBase: BaseViewControllerDelegate?

    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        delegateBase?.didFinish(viewController: self)
        print("deinit: \(self.description)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func loadView() {
        fatalError("loadView() has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewModelListeners()
        addUIListeners()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeUIListeners()
        removeViewModelListeners()
    }

    func setupView() {}
    func setupBinds() {}

    func addViewModelListeners() {}
    func addUIListeners() {}

    func removeUIListeners() {}
    func removeViewModelListeners() {}
}
