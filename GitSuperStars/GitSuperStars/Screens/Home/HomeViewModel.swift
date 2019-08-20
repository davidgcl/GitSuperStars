import Foundation
import RxCocoa

final class HomeViewModel {
    
    // MARK: - Enums

    enum HomeViewModelState: Equatable {
        case none
        case fetching
        case fetchSuccess
        case fetchError(localizedDescription: String)
    }
    
    // MARK: - Properties
    
    private weak var repository: Repository?
    private var repositories = [GitRepositoryItem]()
    
    /// The current page used in pagination, starting in 1.
    /// Reference: [GitHub Pagination](https://developer.github.com/v3/#pagination)
    private var currentPage = 1
    private var total = 0
    private var maxPages = 0
    
    // MARK: - Lifecycle

    init( repository: Repository ) {
        self.repository = repository
    }
    
    // MARK: - Observable

    let state = BehaviorRelay<HomeViewModelState>(value: HomeViewModelState.none)
    
    // MARK: - Public
 
    /// `true` if we have an fetching request in progress
    var isFetchInProgress: Bool {
        get {
            return state.value == HomeViewModelState.fetching
        }
    }
    
    /// The total amount of the items in repository on the server
    var totalCount: Int {
        return total
    }
    
    /// The amount of items from the repository current fetched
    var currentCount: Int {
        return repositories.count
    }
    
    /// Get a GitRepositoryItem for the presented index.
    ///
    /// - Parameters:
    ///   - index: The index for the local array containing the downloaded repository items.
    ///
    /// - Returns:
    ///   - The corresponding GitRepositoryItem for the local array of downloaded repository items.
    func gitRepositoryItem(at index: Int) -> GitRepositoryItem {
        return repositories[index]
    }
    
    /// Fetch the next set of data anda append to the current content.
    ///
    /// - Returns:
    ///   - `false` if we has a fetching in progress, or the current page is the last page.
    func fetchNextSetOfData() -> Bool {
        guard !isFetchInProgress, hasNextPage() else {
            return false
        }
        fetchData()
        return true
    }
    
    /// Clears the local data and fetch the first set.
    ///
    /// - Returns:
    ///   - `false` if we has a fetching in progress.
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
    /// The request, response and error will trigger a change in the `self` observable variable `state`.
    private func fetchData() {
        
       print("Loading page:\(currentPage)/\(maxPages) perPage:\(Settings.Services.Git.ITEMS_PER_PAGE)  count:\(currentCount)/\(totalCount)")
        
        state.accept(.fetching)
        
        repository?.getSwiftRepositories(page: currentPage, perPage: Settings.Services.Git.ITEMS_PER_PAGE) { [unowned self] (result) in
            
            switch result {
            case let .error(error):
                self.state.accept(.fetchError(localizedDescription: error.localizedDescription))

            case let .success(gitRepositoryQueryResult):

                print("Loading completed.")

                // If its the first page, it could be a reloading result request, clear all previous result.
                if (self.currentPage == 1) {
                    self.repositories.removeAll()
                }

                self.currentPage += 1

                self.total = min(gitRepositoryQueryResult.totalCount, Settings.Services.Git.MAX_SEARCH_LIMIT)
                self.maxPages = Int(ceil(Double(self.total) / Double(Settings.Services.Git.ITEMS_PER_PAGE)))
                self.repositories.append(contentsOf: gitRepositoryQueryResult.items)

                self.state.accept(.fetchSuccess)
            }
        }
    }
    
    private func resetLocalData() {
        currentPage = 1
        total = 0
    }
    
    private func hasNextPage() -> Bool {
        if (totalCount == 0) {
            return true
        }
        return currentPage <= maxPages
    }
}
