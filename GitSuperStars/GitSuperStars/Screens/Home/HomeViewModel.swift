import Foundation
import RxSwift
import RxCocoa

enum HomeViewModelState: Equatable {
    case none
    case fetching
    case fetchSuccess
    case fetchError(localizedDescription: String)
}

protocol HomeViewModelProtocol: BaseViewModelProtocol {
    var state: Driver<HomeViewModelState> { get }
    var repositories: Driver<GitRepositoryItem> { get }
    var isLoading: Driver<Bool> { get }
    var isFetchInProgress: Bool { get }
    var totalCount: Int { get }
    var currentCount: Int { get }
    func gitRepositoryItem(at index: Int) -> GitRepositoryItem
    func fetchNextSetOfData() -> Bool
    func fetchFirstSetOfData() -> Bool
    func didSelectItemAt(indexPath: IndexPath)
}

class HomeViewModel: BaseViewModel {

    private weak var repository: Repository?
    private var currentPage = 1
    private var total = 0
    private var maxPages = 0

    private let stateRelay = BehaviorRelay<HomeViewModelState>(value: HomeViewModelState.none)
    var state: Driver<HomeViewModelState> {
        return stateRelay.asDriver()
    }

    private let repositoriesRelay = BehaviorRelay<[GitRepositoryItem]>(value: [GitRepositoryItem]())
    var repositories: Driver<[GitRepositoryItem]> {
        return repositoriesRelay.asDriver()
    }

    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    var isLoading: Driver<Bool> {
        return isLoadingRelay.asDriver()
    }

    init( repository: Repository ) {
        self.repository = repository
    }

    var isFetchInProgress: Bool {
        return stateRelay.value == HomeViewModelState.fetching
    }

    var totalCount: Int {
        return total
    }

    var currentCount: Int {
        return repositoriesRelay.value.count
    }

    func gitRepositoryItem(at index: Int) -> GitRepositoryItem {
        return repositoriesRelay.value[index]
    }

    func fetchNextSetOfData() -> Bool {
        guard !isFetchInProgress, hasNextPage() else {
            return false
        }
        fetchData()
        return true
    }

    func fetchFirstSetOfData() -> Bool {
        guard !isFetchInProgress else {
            return false
        }
        resetLocalData()
        fetchData()
        return true
    }

    func didSelectItemAt(indexPath: IndexPath) {
        print("item selected")
    }
}

extension HomeViewModel {

    private func fetchData() {
        print("Loading page:\(currentPage)/\(maxPages) perPage:\(Settings.Services.Git.itemsPerPage)  count:\(currentCount)/\(totalCount)")
        stateRelay.accept(.fetching)
        repository?
            .getSwiftRepositories(
                page: currentPage,
                perPage: Settings.Services.Git.itemsPerPage) { [unowned self] (result) in
            switch result {
            case let .error(error):
                self.stateRelay.accept(.fetchError(localizedDescription: error.localizedDescription))

            case let .success(gitRepositoryQueryResult):
                if self.currentPage == 1 {
                    self.repositoriesRelay.accept([GitRepositoryItem]())
                }
                self.currentPage += 1
                self.total = min(gitRepositoryQueryResult.totalCount, Settings.Services.Git.maxSearchLimit)
                self.maxPages = Int(ceil(Double(self.total) / Double(Settings.Services.Git.itemsPerPage)))
                self.repositoriesRelay.accept(self.repositoriesRelay.value + gitRepositoryQueryResult.items)
                self.stateRelay.accept(.fetchSuccess)
            }
        }
    }

    private func resetLocalData() {
        currentPage = 1
        total = 0
    }

    private func hasNextPage() -> Bool {
        if totalCount == 0 {
            return true
        }
        return currentPage <= maxPages
    }
}
