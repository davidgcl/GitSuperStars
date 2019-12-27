import Foundation
import GSCore
import RxSwift
import RxCocoa

public enum HomeViewModelState: Equatable {
    case none
    case fetching
    case fetchSuccess
    case fetchError(localizedDescription: String)
}

public protocol HomeViewModelProtocol: BaseViewModelProtocol {
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

public class HomeViewModel: BaseViewModel {

    private weak var repository: Repository?
    private var currentPage = 1
    private var total = 0
    private var maxPages = 0

    private let stateRelay = BehaviorRelay<HomeViewModelState>(value: HomeViewModelState.none)
    public var state: Driver<HomeViewModelState> {
        return stateRelay.asDriver()
    }

    private let repositoriesRelay = BehaviorRelay<[GitRepositoryItem]>(value: [GitRepositoryItem]())
    public var repositories: Driver<[GitRepositoryItem]> {
        return repositoriesRelay.asDriver()
    }

    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    public var isLoading: Driver<Bool> {
        return isLoadingRelay.asDriver()
    }

    public init( repository: Repository ) {
        self.repository = repository
    }

    public var isFetchInProgress: Bool {
        return stateRelay.value == HomeViewModelState.fetching
    }

    public var totalCount: Int {
        return total
    }

    public var currentCount: Int {
        return repositoriesRelay.value.count
    }

    public func gitRepositoryItem(at index: Int) -> GitRepositoryItem {
        return repositoriesRelay.value[index]
    }

    public func fetchNextSetOfData() -> Bool {
        guard !isFetchInProgress, hasNextPage() else {
            return false
        }
        fetchData()
        return true
    }

    public func fetchFirstSetOfData() -> Bool {
        guard !isFetchInProgress else {
            return false
        }
        resetLocalData()
        fetchData()
        return true
    }

    public func didSelectItemAt(indexPath: IndexPath) {
        print("item selected")
    }
}

extension HomeViewModel {

    private func fetchData() {
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
