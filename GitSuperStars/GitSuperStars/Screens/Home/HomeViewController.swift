import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()

    private var homeView: HomeView {
        return self.view as! HomeView
    }
    
    // MARK: - Lifecycle
    
    init(viewModel:HomeViewModel) {
        self.viewModel = viewModel
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
        homeView.tableView.dataSource = self
        homeView.tableView.register(GitRepositoryItemTableViewCell.self, forCellReuseIdentifier: String(describing: GitRepositoryItemTableViewCell.self))
        homeView.tableView.register(LoadingViewCell.self, forCellReuseIdentifier: String(describing: LoadingViewCell.self))
    }
    
    private func endRefreshing() {
        if homeView.refreshControl.isRefreshing == true {
            homeView.refreshControl.endRefreshing()
        }
    }
    
    private func updateLoadingIndicator() {
        homeView.tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    private func addUIListeners() {
        homeView.refreshControl.addTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func removeUIListeners() {
        homeView.refreshControl.removeTarget(self, action: #selector(HomeViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func addViewModelListeners() {
        viewModel.state.asObservable().subscribe(onNext: { [weak self] (state) in
            
            guard let self = self else { return }
            
            switch self.viewModel.state.value {
            case .none: break
            case .fetching: break
                
            case .fetchSuccess:
                self.homeView.tableView.reloadData()
                self.endRefreshing()
                
            case .fetchError(let localizedDescription):
                self.extShowAlert(title: LocalizedString.error.value, message: localizedDescription, completion: .none)
                self.endRefreshing()
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
            return Size.loading_view_cell_height.value
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.repository_view_cell_height.value
        } else {
            return Size.loading_view_cell_height.value
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let startPreloadingOffsetHeightMultiplyer = CGFloat(5.0)
        
        if offsetY > contentHeight - scrollView.frame.height * startPreloadingOffsetHeightMultiplyer {
            if viewModel.fetchNextSetOfData() {
                updateLoadingIndicator()
            }
        }
    }
}

// MARK: - ViewModel DataSource

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.currentCount
        } else if section == 1 && viewModel.isFetchInProgress && homeView.refreshControl.isRefreshing != true {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GitRepositoryItemTableViewCell.self), for: indexPath) as! GitRepositoryItemTableViewCell
            cell.bind(gitRepositoryItem: viewModel.gitRepositoryItem(at: indexPath.row))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingViewCell.self), for: indexPath) as! LoadingViewCell
            cell.startAnimating()
            return cell
        }
    }
}
