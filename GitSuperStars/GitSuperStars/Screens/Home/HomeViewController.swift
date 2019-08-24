import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let viewModelDataProvider: HomeViewDataProvider
    private let disposeBag = DisposeBag()

    private var homeView: HomeView {
        return self.view as! HomeView
    }
    
    // MARK: - Lifecycle
    
    init(viewModel:HomeViewModel) {
        self.viewModel = viewModel
        self.viewModelDataProvider = HomeViewDataProvider(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationController()
        
        let _ = viewModel.fetchFirstSetOfData()
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
    
    override func loadView() {
        self.view = HomeView(frame: UIScreen.main.bounds)
    }
    
    // MARK: - Helper functions
    
    private func setupNavigationController() {
        navigationItem.titleView = homeView.navigationItemLogo
        navigationController?.navigationBar.backgroundColor = Color.colorWhite.value
    }
    
    private func setupTableView() {
        homeView.tableView.delegate = self
        homeView.tableView.dataSource = viewModelDataProvider
        homeView.tableView.register(GitRepositoryItemTableViewCell.self, forCellReuseIdentifier: String(describing: GitRepositoryItemTableViewCell.self))
    }
    
    private func endRefreshing() {
        if homeView.refreshControl.isRefreshing == true {
            homeView.refreshControl.endRefreshing()
        }
    }
    
    private func addUIListeners() {
        homeView.refreshControl.addTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func removeUIListeners() {
        homeView.refreshControl.removeTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func addViewModelListeners() {
        viewModel.state
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (newState) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch newState {
                case .none: break
                case .fetching:
                    if self.homeView.refreshControl.isRefreshing != true {
                        self.homeView.tableView.tableFooterView = self.homeView.fetchingProgressView
                    } else {
                        self.homeView.tableView.tableFooterView = nil
                    }
                    
                case .fetchSuccess:
                    self.homeView.tableView.tableFooterView = nil
                    self.homeView.tableView.reloadData()
                    self.endRefreshing()
                    
                case .fetchError(let localizedDescription):
                    self.homeView.tableView.tableFooterView = nil
                    self.extShowAlert(title: LocalizedString.error.value, message: localizedDescription, completion: .none)
                    self.endRefreshing()
                }
                
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func removeViewModelListeners() {
        
    }
    
    // MARK: - Event Handling
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if !viewModel.fetchFirstSetOfData() {
            endRefreshing()
        }
    }
    
}

// MARK: - TableView Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.repository_view_cell_height.value
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.repository_view_cell_height.value
        } else {
            return 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let startPreloadingOffsetHeightMultiplyer = CGFloat(5.0)
        
        if offsetY > contentHeight - scrollView.frame.height * startPreloadingOffsetHeightMultiplyer {
            _ = viewModel.fetchNextSetOfData()
        }
    }
}
