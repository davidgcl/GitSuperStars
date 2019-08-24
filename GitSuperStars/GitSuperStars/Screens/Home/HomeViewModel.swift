import Foundation
import RxCocoa
import RxSwift

final class HomeViewModel {
    
    // MARK: - Enums

    enum HomeViewModelState: Equatable {
        case none
        case fetching
        case fetchSuccess
        case fetchError(localizedDescription: String)
    }
    
    // MARK: - Private Properties
    
    /// The injected repository
    private weak var repository: Repository?
    
    /// The total items per page on each request
    private let itemsPerPage: Int
    
    /// The in memory repositories results received from the network
    private var repositories = [GitRepositoryItem]()
    
    /// The current page used in pagination, starting in 1.
    /// Reference: [GitHub Pagination](https://developer.github.com/v3/#pagination)
    private var nextPageToLoad = 1
    
    /// The total amount of pages based on total and itemsPerPage
    private var maxPages = 0
    
    /// The total amount of the items in repository on the server
    private var totalCount = 0
    
    /// The view model internal state
    private let internalState = BehaviorRelay<HomeViewModelState>(value: HomeViewModelState.none)
    
    /// `true` if we have an fetching request in progress
    private var isFetchInProgress: Bool {
        get {
            return internalState.value == HomeViewModelState.fetching
        }
    }
    
    // MARK: - Public Properties
    
    /// The amount of items from the repository current fetched
    var currentCount: Int {
        return repositories.count
    }
    
    // MARK: - Observable Properties
    
    var state: Observable<HomeViewModelState> {
        get {
            return internalState.asObservable()
        }
    }
    
    // MARK: - Lifecycle

    init( repository: Repository, itemsPerPage: Int = Settings.Services.Git.ITEMS_PER_PAGE ) {
        self.repository = repository
        self.itemsPerPage = itemsPerPage
    }
    
    // MARK: - Public Methods
    
    /// Returns a GitRepositoryItem for the presented index.
    ///
    /// - Parameter index: The index for the local array containing the downloaded repository items.
    ///
    /// - Returns: The corresponding GitRepositoryItem for the local array of downloaded repository items or returns `nil` if the index is out of range from the current loaded items.
    func gitRepositoryItem(at index: Int) -> GitRepositoryItem? {
        guard index < currentCount else { return nil }
        return repositories[index]
    }
    
    /// Fetch the next set of data anda append to the current content.
    ///
    /// - Returns: `false` if we has a fetching in progress, or the current page is the last page.
    func fetchNextSetOfData() -> Bool {
        guard !isFetchInProgress, hasNextPage() else {
            return false
        }
        fetchData()
        return true
    }
    
    /// Clears the local data and fetch the first set.
    ///
    /// - Returns: `false` if we has a fetching in progress.
    func fetchFirstSetOfData() -> Bool {
        guard !isFetchInProgress else {
            return false
        }
        resetLocalData()
        fetchData()
        return true
    }
    
    // MARK: - Helper functions
    
    /// Request the repository to fetches new data from the GitHub repository.
    ///
    /// The request, response and error will trigger a change in the `self` observable variable `internalState`.
    private func fetchData() {
        
        print("HomeViewModel::Loading page:\(nextPageToLoad)/\(maxPages) perPage:\(itemsPerPage)  count:\(currentCount)/\(totalCount)")
        
        internalState.accept(.fetching)
        
        repository?.getSwiftRepositories(page: nextPageToLoad, perPage: itemsPerPage) { [unowned self] (result) in
            
            switch result {
            case let .error(error):
                self.internalState.accept(.fetchError(localizedDescription: error.localizedDescription))

            case let .success(gitRepositoryQueryResult):

                // If its the first page, it could be a reloading result request, clear all previous result.
                if (self.nextPageToLoad == 1) {
                    self.repositories.removeAll()
                }
                self.nextPageToLoad += 1

                self.totalCount = min(gitRepositoryQueryResult.totalCount, Settings.Services.Git.MAX_SEARCH_LIMIT)
                self.maxPages = Int(ceil(Double(self.totalCount) / Double(self.itemsPerPage)))
                self.repositories.append(contentsOf: gitRepositoryQueryResult.items)

                print("HomeViewModel::Loading completed:\(self.nextPageToLoad-1)/\(self.maxPages) perPage:\(self.itemsPerPage)  count:\(self.currentCount)/\(self.totalCount)")
                
                self.internalState.accept(.fetchSuccess)
            }
        }
    }
    
    private func resetLocalData() {
        nextPageToLoad = 1
        totalCount = 0
    }
    
    private func hasNextPage() -> Bool {
        return totalCount > 0 && nextPageToLoad <= maxPages
    }
}
