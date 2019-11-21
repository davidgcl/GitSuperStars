import Foundation
import UIKit

protocol CoordinatorDelegate: class {
    func didFinish(coordinator: BaseCoordinator)
}

protocol Coordinator {
    var presenter: UINavigationController? { get set }
    var delegate: CoordinatorDelegate? { get set }
    var rootViewController: UIViewController? { get set }

    func addChildCoordinator(_ coordinator: BaseCoordinator)
    func removeChildCoordinator(_ coordinator: BaseCoordinator)
    func removeAllChildCoordinatorsWith<T>(type: T.Type)
    func removeAllChildCoordinators()

    func start()
    func finish()

    func present(viewController: UIViewController, type: PresentationMode)
    func navigateTo(viewController: UIViewController, type: PresentationMode)
}

enum PresentationMode {
    case present
    case push
}

class BaseCoordinator: NSObject, Coordinator {

    var presenter: UINavigationController?
    weak var delegate: CoordinatorDelegate?
    weak var rootViewController: UIViewController?

    private var childCoordinators: [BaseCoordinator] = []

    deinit {
        print("deinit: \(self.description)")
    }

    open func start() {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }

    open func finish() {
        self.delegate?.didFinish(coordinator: self)
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
}

extension BaseCoordinator {

    public func addChildCoordinator(_ coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
    }

    public func removeChildCoordinator(_ coordinator: BaseCoordinator) {
        if let index = childCoordinators.firstIndex(of: coordinator) {
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
}
