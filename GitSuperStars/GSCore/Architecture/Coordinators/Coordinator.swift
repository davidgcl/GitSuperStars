//
//  Coordinator.swift
//  GSCore
//
//  Created by David Lima on 23/12/19.
//  Copyright © 2019 David Lima. All rights reserved.
//

import UIKit

public enum PresentationMode {
    case present
    case push
}

public protocol CoordinatorDelegate: class {
    func didFinish(coordinator: CoordinatorProtocol)
}

public protocol CoordinatorProtocol {
    var presenter: UINavigationController? { get }
    var delegate: CoordinatorDelegate? { get }
    var rootViewController: UIViewController? { get }
    var childCoordinators: [CoordinatorProtocol] { get }

    func start()
    func finish()
    
    mutating func addChildCoordinator(_ coordinator: CoordinatorProtocol)
    mutating func removeChildCoordinator(_ coordinator: CoordinatorProtocol)
    mutating func removeAllChildCoordinatorsWith<T>(type: T.Type)
    mutating func removeAllChildCoordinators()

    func present(viewController: UIViewController, type: PresentationMode)
    func navigateTo(viewController: UIViewController, type: PresentationMode)
    
    func isEqualTo(_ other: CoordinatorProtocol) -> Bool
    //func asEquatable() -> EquatableCoordinator
}

extension CoordinatorProtocol where Self: Equatable {
    
    public func isEqualTo(_ other: CoordinatorProtocol) -> Bool {
        guard let otherCoordinator = other as? Self else { return false }
        return self == otherCoordinator
    }
    
//    public func asEquatable() -> EquatableCoordinator {
//        return EquatableCoordinator(self)
//    }
}

open class Coordinator: CoordinatorProtocol, Equatable {

    public weak var presenter: UINavigationController?
    public weak var delegate: CoordinatorDelegate?
    public weak var rootViewController: UIViewController?
    public var childCoordinators: [CoordinatorProtocol] = []
    
    public init(_ presenter: UINavigationController? = nil) {
        self.presenter = presenter
    }
    
    deinit {
        print("deinit: \(String(describing: self))")
    }
    
    open func start() {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }
    
    open func finish() {
        self.delegate?.didFinish(coordinator: self)
    }
    
    public func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }
    
    public func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
        if let index = childCoordinators.firstIndex(where: { element -> Bool in
            return element.isEqualTo(coordinator)
        }) {
            childCoordinators.remove(at: index)
        } else {
            print("Couldn't remove coordinator: \(coordinator). It's not a child coordinator.")
        }
    }
    
    public func removeAllChildCoordinatorsWith<T>(type: T.Type) {
        childCoordinators = childCoordinators.filter { $0 is T  == false }
    }
    
    public func removeAllChildCoordinators() {
        childCoordinators.removeAll()
    }
    
    public func present(viewController: UIViewController, type: PresentationMode = .push) {
        switch type {
        case .present:
            if let presented = presenter?.presentedViewController {
                presented.dismiss(animated: true) { [weak self] in
                    self?.presenter?.present(viewController, animated: true, completion: nil)
                }
            } else {
                presenter?.present(viewController, animated: true, completion: nil)
            }
        case .push:
            presenter?.pushViewController(viewController, animated: true)
        }
    }

    public func navigateTo(viewController: UIViewController, type: PresentationMode = .push) {

        if presenter?.viewControllers.firstIndex(of: viewController) != nil {
            presenter?.popToViewController(viewController, animated: true)
            return
        }

        if let tabBarController = rootViewController as? UITabBarController,
            let tabBarControllers = tabBarController.viewControllers,
            let index = tabBarControllers.firstIndex(of: viewController) {
                tabBarController.selectedIndex = index
            return
        }

        present(viewController: viewController, type: type)
    }
    
    public static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs === rhs
    }
}

//public class EquatableCoordinator: CoordinatorProtocol, Equatable {
//
//    private var coordinator: CoordinatorProtocol
//
//    init(_ coordinator: CoordinatorProtocol) {
//        self.coordinator = coordinator
//    }
//
//    public func start() {
//        coordinator.start()
//    }
//
//    public func finish() {
//        coordinator.finish()
//    }
//
//    public var presenter: UINavigationController? {
//        return coordinator.presenter
//    }
//
//    public var delegate: CoordinatorDelegate? {
//        return coordinator.delegate
//    }
//
//    public var rootViewController: UIViewController? {
//        return coordinator.rootViewController
//    }
//
//    public var childCoordinators: [CoordinatorProtocol] {
//        return coordinator.childCoordinators
//    }
//
//    public func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
//        self.coordinator.addChildCoordinator(coordinator)
//    }
//
//    public func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
//        self.coordinator.removeChildCoordinator(coordinator)
//    }
//
//    public func removeAllChildCoordinatorsWith<T>(type: T.Type) {
//        coordinator.removeAllChildCoordinatorsWith(type: type)
//    }
//
//    public func removeAllChildCoordinators() {
//        coordinator.removeAllChildCoordinators()
//    }
//
//    public func present(viewController: UIViewController, type: PresentationMode) {
//        coordinator.present(viewController: viewController, type: type)
//    }
//
//    public func navigateTo(viewController: UIViewController, type: PresentationMode = .push) {
//        coordinator.navigateTo(viewController: viewController, type: type)
//    }
//
//    public func isEqualTo(_ other: CoordinatorProtocol) -> Bool {
//        coordinator.isEqualTo(other)
//    }
//
//    public func asEquatable() -> EquatableCoordinator {
//        return coordinator.asEquatable()
//    }
//
//    public static func ==(lhs: EquatableCoordinator, rhs: EquatableCoordinator) -> Bool {
////        return lhs.coordinator.isEqualTo(rhs.coordinator)
//        return lhs === rhs
//    }
//}
