import Foundation
import UIKit

public protocol CoordinatorDelegate:class {
    func didFinish(coordinator:Coordinator) -> Void
}

open class Coordinator {
    
    // MARK: - Properties

    enum InsertLevel {
        case ROOT
        case APPEND
    }
    
    public var childCoordinators: [Coordinator] = []
    public weak var coordinatorDelegate:CoordinatorDelegate?
    public let navigationController: UINavigationController
    
    /// Mantém uma referência da VC base deste coordinator que deve estar contida no navigation controller
    /// Sua referência é necessária caso queira que seja considerada como root na navegação
    public var navigationRootViewController: UIViewController?
    
    /// Mantém uma referência do VC configurado em uma TabBar, esta não fica presente no navigation controller
    /// Sua referência é necessária caso esta view esteja em uma TabView para que ao solicitar este setor
    /// saibamos que ela estará contina no navigation root view controller.
    public var tabRootViewController: UIViewController?
    
    /// Referência da VC que será adicionada na root
    private(set) var rootViewController: UIViewController?
    
    // MARK: - Lifecycle

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    open func start() {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }
    
    open func finish() {
        self.coordinatorDelegate?.didFinish(coordinator:self)
    }
    
    // MARK: - Public

    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        } else {
            print("Couldn't remove coordinator: \(coordinator). It's not a child coordinator.")
        }
    }
    
    func removeAllChildCoordinatorsWith<T>(type: T.Type) {
        childCoordinators = childCoordinators.filter { $0 is T  == false }
    }
    
    func removeAllChildCoordinators() {
        childCoordinators.removeAll()
    }
    
    // MARK: - Helper

    func replaceScreen(viewController: UIViewController, insertLevel: InsertLevel, animated: Bool) {
        switch insertLevel {
        case .ROOT:
            
            // Se a view controller desejada está na stack, remove os items acima
            if let _ = navigationController.viewControllers.firstIndex(of: viewController) {
                navigationController.popToViewController(viewController, animated: animated)
                return
            }
            
            // Se houver declarada uma rootViewController, adicionamos a partir desta
            if let navigationRootViewController = navigationRootViewController, let _ = navigationController.viewControllers.firstIndex(of: navigationRootViewController) {
                navigationController.popToViewController(navigationRootViewController, animated: animated)
                
                // Se o target for a tabViewController, ignora pois ela já estará sendo apresentada na rootViewController
                // Contudo, será preciso considerar talvez a mudança de aba para apresentar a tab com a vc desejada
                // Iteraremos entre as ViewControllers da TabBar e caso encontremos a vc target, nós selecionaremos esta aba
                if viewController == tabRootViewController {
                    if let tabVC = navigationRootViewController as? UITabBarController, let vcs = tabVC.viewControllers {
                        for i in 0..<vcs.count {
                            if vcs[i] == viewController {
                                tabVC.selectedIndex = i
                                return
                            }
                        }
                    }
                }
                
                // Caso contrário continua a adição acima da root.
                else {
                    navigationController.pushViewController(viewController, animated: animated)
                }
                
                return
            }
            
            // Caso contrário, simplesmente adicionamos a viewController desejada no root absoluta
            navigationController.setViewControllers([viewController], animated: animated)
            
            break
        case .APPEND:
            navigationController.pushViewController(viewController, animated: animated)
            break
        }
    }
}

extension Coordinator: Equatable {
    
    public static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs === rhs
    }
    
}
