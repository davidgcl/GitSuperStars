import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Enums
    
    enum NavigationTarget {
        case NONE
        case SECTOR_HOME
    }

    // MARK: - Properties
    
    private let window: UIWindow
    private let repository: Repository
    private var currentSector: NavigationTarget = NavigationTarget.NONE
    
    // MARK: - Lifecycle
    
    public init(window: UIWindow) {
        self.window = window
        self.repository = GitRepository()
        super.init(navigationController: UINavigationController(rootViewController: UIViewController()))
    }
    
    override func start() {
        
        navigateTo(target: NavigationTarget.SECTOR_HOME)
        
        navigationController.isNavigationBarHidden = false
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Navigation
    
    private func navigateTo(target: NavigationTarget, with params: Any? = nil) {

        guard target != currentSector else { return }
        
        switch target {
            
        case .NONE:
            break

        case .SECTOR_HOME:
            let vc = HomeViewController(viewModel: HomeViewModel(repository: repository))
            replaceScreen(viewController: vc, insertLevel: .ROOT, animated: true)
            currentSector = target
            break
        }
    }
}
