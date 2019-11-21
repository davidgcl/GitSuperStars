import UIKit

final class AppCoordinator: BaseCoordinator {

    private let window: UIWindow?
    private let repository: Repository

    public init(window: UIWindow) {
        self.window = window
        self.repository = URLSessionRepository()
        super.init()
    }

    override func start() {
        self.presenter = UINavigationController(rootViewController: buildHomeVC())
        presenter?.isNavigationBarHidden = false
        window?.rootViewController = self.presenter
        window?.makeKeyAndVisible()
    }
}

extension AppCoordinator {

    private func buildHomeVC() -> HomeViewController<HomeView, HomeViewModel> {
        let homeVC = HomeViewController(viewModel: HomeViewModel(repository: repository))
        homeVC.delegate = self
        homeVC.delegateBase = self
        return homeVC
    }

    private func buildDetailsVC() -> DetailsViewController<DetailsView, DetailsViewModel> {
        let detailsVC = DetailsViewController(viewModel: DetailsViewModel())
        detailsVC.delegate = self
        detailsVC.delegateBase = self
        return detailsVC
    }
}

extension AppCoordinator: HomeViewControllerDelegate {

    func homeDidTap(item: GitRepositoryItem) {
        present(viewController: buildDetailsVC(), type: .push)
    }
}

extension AppCoordinator: DetailsViewControllerDelegate {

}

extension AppCoordinator: BaseViewControllerDelegate {

    func didFinish(viewController: UIViewController) {
        print("detected the de initialization of \(String(describing: viewController.self))")
    }
}
