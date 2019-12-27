import UIKit
import GSCore
import GSHome
import GSDetails

class AppCoordinator: Coordinator {
    
    private let window: UIWindow?
    private let repository: Repository

    public init(window: UIWindow) {
        self.window = window
        self.repository = URLSessionRepository()
        super.init()
    }
    
    override func start() {
        let rootViewController = buildHomeVC()
        self.rootViewController = rootViewController
                
        let presenter = UINavigationController(rootViewController: rootViewController)
        self.presenter = presenter
        
        presenter.isNavigationBarHidden = false
        window?.rootViewController = presenter
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Helpers
    private func buildHomeVC() -> HomeViewController<HomeView, HomeViewModel> {
        let homeVC = HomeViewController(viewModel: HomeViewModel(repository: repository))
        homeVC.delegate = self
        homeVC.delegateBase = self
        return homeVC
    }

    private func buildDetailsCoordinator() -> DetailsCoordinator {
        let coordinator = DetailsCoordinator(presenter)
        coordinator.delegate = self
        return coordinator
    }
}

extension AppCoordinator: HomeViewControllerDelegate {

    func homeDidTap(item: GitRepositoryItem) {
        let coordinator = buildDetailsCoordinator()
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: DetailsViewControllerDelegate {

}

extension AppCoordinator: BaseViewControllerDelegate {

    func didFinish(viewController: UIViewController) {
        print("detected the de initialization of \(String(describing: viewController.self))")
    }
}

extension AppCoordinator: CoordinatorDelegate {
    
    func didFinish(coordinator: CoordinatorProtocol) {
        print("detected the de initialization of coordinator \(String(describing: coordinator.self))")
        removeChildCoordinator(coordinator)
    }
}
