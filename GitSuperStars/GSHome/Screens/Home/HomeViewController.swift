import UIKit
import RxSwift
import GSCore

public protocol HomeViewControllerDelegate: class {
    func homeDidTap(item: GitRepositoryItem)
}

public class HomeViewController<T: HomeView, J: HomeViewModel>: BaseViewController<T, J>, UITableViewDelegate, UITableViewDataSource {

    public weak var delegate: HomeViewControllerDelegate?
    
    private let loadingView: UIView = {
        return LoadingView()
    }()

    private var homeView: HomeView {
        if let homeView = view as? HomeView {
            return homeView
        } else {
            fatalError()
        }
    }

    override public func loadView() {
        self.view = HomeView(frame: UIScreen.main.bounds)
    }

    override public func setupView() {
        setupTableView()
        setupNavigationController()
        _ = viewModel?.fetchFirstSetOfData()
    }

    override public func setupBinds() {}
    override public func addViewModelListeners() {
        viewModel?.state.asObservable().subscribe(onNext: { [weak self] (state) in
            guard let self = self else { return }
            switch state {
            case .none: break
            case .fetching:
                self.homeView.tableView.tableFooterView = self.loadingView
            case .fetchSuccess:
                self.homeView.tableView.tableFooterView = nil
                self.endRefreshing()
            case .fetchError(let localizedDescription):
                self.homeView.tableView.tableFooterView = nil
                self.extShowAlert(title: LocalizedString.error.value, message: localizedDescription, completion: .none)
                self.endRefreshing()
            }
        }).disposed(by: disposeBag)

        viewModel?.repositories.drive(
            homeView.tableView.rx.items(
                cellIdentifier: String(describing: GitRepositoryItemTableViewCell.self),
                cellType: GitRepositoryItemTableViewCell.self)) { [weak self] row, _, cell in
                    if let viewModel = self?.viewModel {
                        cell.bind(gitRepositoryItem: viewModel.gitRepositoryItem(at: row))
                    }
            }.disposed(by: disposeBag)
    }

    override public func addUIListeners() {
        homeView.refreshControl.addTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }

    override public func removeUIListeners() {
        homeView.refreshControl.removeTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }

    override public func removeViewModelListeners() {
        disposeBag = DisposeBag()
    }

    private func setupNavigationController() {
        navigationItem.titleView = homeView.navigationItemLogo
        navigationController?.navigationBar.backgroundColor = Color.colorWhite.value
    }

    private func setupTableView() {
        homeView.tableView.delegate = self
        homeView.tableView.register(
            GitRepositoryItemTableViewCell.self,
            forCellReuseIdentifier: String(describing: GitRepositoryItemTableViewCell.self))
        homeView.tableView.register(LoadingViewCell.self, forCellReuseIdentifier: String(describing: LoadingViewCell.self))
    }

    private func endRefreshing() {
        if homeView.refreshControl.isRefreshing == true {
            homeView.refreshControl.endRefreshing()
        }
    }

    @objc public func handleRefresh(_ refreshControl: UIRefreshControl) {
        if let viewModel = viewModel,
            viewModel.fetchFirstSetOfData() {
            endRefreshing()
        }
    }

    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.repositoryViewCellHeight.value
        } else {
            return Size.loadingViewCellHeight.value
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.repositoryViewCellHeight.value
        } else {
            return Size.loadingViewCellHeight.value
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = viewModel?.gitRepositoryItem(at: indexPath.row) {
            delegate?.homeDidTap(item: item)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let startPreloadingOffsetHeightMultiplyer = CGFloat(5.0)
        if offsetY > contentHeight - scrollView.frame.height * startPreloadingOffsetHeightMultiplyer {
            _ = viewModel?.fetchNextSetOfData()
        }
    }

    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel?.currentCount ?? 0
        } else if section == 1 && viewModel?.isFetchInProgress == true && homeView.refreshControl.isRefreshing != true {
            return 1
        } else {
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GitRepositoryItemTableViewCell.self), for: indexPath) as? GitRepositoryItemTableViewCell {
                if let viewModel = viewModel {
                    cell.bind(gitRepositoryItem: viewModel.gitRepositoryItem(at: indexPath.row))
                }
                cell.selectionStyle = .none
                return cell
            } else {
                fatalError()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingViewCell.self), for: indexPath) as? LoadingViewCell {
                cell.startAnimating()
                return cell
            } else {
                fatalError()
            }
        }
    }
}
