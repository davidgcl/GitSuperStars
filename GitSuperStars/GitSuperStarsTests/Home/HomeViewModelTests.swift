import XCTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import GitSuperStars

class HomeViewModelTests: XCTestCase {
    
    // MARK: - Properties

    private var sut: HomeViewModel!
    private var repository: Repository!
    private var disposeBag: DisposeBag!

    // MARK: - Stubbed results
    
    private let stubbedMaxPages: Int = 2
    private let stubbedItemsPerPage: Int = 10
    
    private let stubbedErrorWithZeroResults: Result<GitRepositoryQueryResult> = {
        let queryResult = GitRepositoryQueryResult(totalCount: 0, items: [])
        return .error(RepositoryError(with: LocalizedString.unexpected_network_error.value))
    }()
    
    private lazy var stubbedSuccessWithManyResults: Result<GitRepositoryQueryResult> = {
        var items = [GitRepositoryItem]()
        for i in 1...self.stubbedItemsPerPage {
            items.append(GitRepositoryItem(id: 0, name: "name_\(i)", stars: Double(100 - i), owner: GitRepositoryItem.Owner(login: "login_\(i)", avatar_url: nil, name: nil)))
        }
        let queryResult = GitRepositoryQueryResult(totalCount: self.stubbedItemsPerPage * self.stubbedMaxPages, items:items)
        return .success(queryResult)
    }()
    
    private lazy var stubbedSuccessWithLastPageManyResults: Result<GitRepositoryQueryResult> = {
        var items = [GitRepositoryItem]()
        for i in 1...self.stubbedItemsPerPage {
            items.append(GitRepositoryItem(id: 0, name: "name_\(i)", stars: Double(100 - i), owner: GitRepositoryItem.Owner(login: "login_\(i)", avatar_url: nil, name: nil)))
        }
        let queryResult = GitRepositoryQueryResult(totalCount: self.stubbedItemsPerPage, items:items)
        return .success(queryResult)
    }()
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        self.repository = nil
        self.sut = nil
    }
    
    // MARK: - Feed Result Tests
    
    func test_userRequestsToSeeTheFeed_withConnectivity_responseReturnsTheFeed() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let expectation = XCTestExpectation(description: "Load the feed with success.")
        let startedWithLoadedItemsCount = sut.currentCount
        
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        self.sut.state.subscribe(onNext: { [weak self] (newState) in
            guard let self = self else { return }
            
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTAssertTrue( (self.sut.currentCount > startedWithLoadedItemsCount) , "The request started with \(startedWithLoadedItemsCount) but finished with \(self.sut.currentCount) saved results.")
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_userRequestsToSeeTheFeed_withNoConnectivity_responseReturnsAnError() {
        
        self.repository = StubRepository(with: stubbedErrorWithZeroResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        let expectation = XCTestExpectation(description: "Load the feed returns error.")
        
        self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTFail("Fetch returned success but the expected was an error")
                
            case .fetchError:
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(sut.fetchFirstSetOfData(), "Request was refused")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_userRequestsToSeeMoreFeeds_withConnectivity_responseReturnsTheFeed() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let firstSetOfDataExpectation = XCTestExpectation(description: "Load first feeds with success.")
        let nextSetOfDataExpectation = XCTestExpectation(description: "Load more feeds with success.")
        var startedWithLoadedItemsCount = sut.currentCount
    
        // request the first set of data
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        let firstSetRequestDisposable = self.sut.state.subscribe(onNext: { [weak self] newState in
            guard let self = self else { return }
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTAssertTrue( (self.sut.currentCount > startedWithLoadedItemsCount) , "The request started with \(startedWithLoadedItemsCount) but finished with \(self.sut.currentCount) saved results.")
                startedWithLoadedItemsCount = self.sut.currentCount
                firstSetOfDataExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for: [firstSetOfDataExpectation], timeout: 1.0)
        firstSetRequestDisposable.dispose()
        
        // request the next set of data
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request was refused")
        self.sut.state.subscribe(onNext: { [weak self] (newState) in
            guard let self = self else { return }
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTAssertTrue( (self.sut.currentCount > startedWithLoadedItemsCount) , "The request started with \(startedWithLoadedItemsCount) but finished with \(self.sut.currentCount) saved results.")
                nextSetOfDataExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        }).disposed(by: disposeBag)
        wait(for: [nextSetOfDataExpectation], timeout: 1.0)
    }
    
    func test_userRequestsToSeeMoreFeeds_withNoConnectivity_responseReturnsAnError() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let firstSetOfDataExpectation = XCTestExpectation(description: "Load first feeds with success.")
        let nextSetOfDataExpectation = XCTestExpectation(description: "Load more feeds with error.")
        
        // request the first set of data
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        let firstSetRequestDisposable = self.sut.state.subscribe(onNext: { newState in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                firstSetOfDataExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for: [firstSetOfDataExpectation], timeout: 1.0)
        firstSetRequestDisposable.dispose()
        
        // request the next set of data
        (self.repository as! StubRepository).setStubbedResult(stubbedErrorWithZeroResults)
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request was refused")
        self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTFail("Fetch returned success but the expected was an error")
                
            case .fetchError:
                nextSetOfDataExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        wait(for: [nextSetOfDataExpectation], timeout: 1.0)
    }
    
    func test_userRequestsToSeeTheFeed_withConnectivity_theResultItemsAreAccessible() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        let expectation = XCTestExpectation(description: "Load feed with success, the results are accessible.")
        
        self.sut.state.subscribe( onNext: { [weak self] (newState) in
            guard let self = self else { return }
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                for i in 0..<self.sut.currentCount {
                    XCTAssertNotNil(self.sut.gitRepositoryItem(at: i), "The index \(i) of the total \(self.sut.currentCount) should be accessible.")
                }
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_userRequestsToRefreshTheFeeds_withPreviousResults_responseResetsTheResults() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        let loadNextSetExpectation = XCTestExpectation(description: "Load next set of results.")
        let clearExpectation = XCTestExpectation(description: "Reload first set of results, the response should reset previous results.")
        
        var firstSetOfItemsCount: Int = 0
        
        // load first set of items, record the count
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        let firstSetDisposable = self.sut.state.subscribe(onNext: { [weak self] (newState) in
            guard let self = self else { return }
            
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                firstSetOfItemsCount = self.sut.currentCount
                print("firstSetOfItemsCount: \(firstSetOfItemsCount)")
                XCTAssertTrue( self.sut.currentCount > 0 , "The request result count should not be zero.")
                loadFirstSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadFirstSetExpectation], timeout: 1.0)
        firstSetDisposable.dispose()
        
        // load more items, asserto the count is increased
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request was refused")
        let nextSetDisposable = self.sut.state.asObservable().subscribe(onNext: { [weak self] (newState) in
            guard let self = self else { return }

            switch newState {
            case .none, .fetching: break

            case .fetchSuccess:
                print("secondSetOfItemsCount: \(self.sut.currentCount)")
                XCTAssertTrue( self.sut.currentCount > firstSetOfItemsCount , "The request result count (\(self.sut.currentCount)) should be more than previous (\(firstSetOfItemsCount)).")
                loadNextSetExpectation.fulfill()

            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadNextSetExpectation], timeout: 1.0)
        nextSetDisposable.dispose()
        
        // reload first set of items, the count has to be the first count
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        self.sut.state.subscribe(onNext: { [weak self] (newState) in
            guard let self = self else { return }

            switch newState {
            case .none, .fetching: break

            case .fetchSuccess:
                XCTAssertTrue( self.sut.currentCount == firstSetOfItemsCount , "The request result should be equals to the first set of results.")
                clearExpectation.fulfill()

            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        }).disposed(by: disposeBag)
        wait(for:[clearExpectation], timeout: 1.0)
    }
    
    func test_userRequestsToRefreshTheFeeds_withPreviousPagingResults_responseResetsThePagingCalculation() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        let loadNextSetExpectation = XCTestExpectation(description: "Load next set of results.")
        let loadFirstSetAgainExpectation = XCTestExpectation(description: "Load first set of results again.")
        let loadNextSetAgainExpectation = XCTestExpectation(description: "Load next set of results again.")
        
        // request first results of page 1/2
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        let firstSetDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadFirstSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadFirstSetExpectation], timeout: 1.0)
        firstSetDisposable.dispose()
        
        // request next results of page 2/2
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request was refused")
        let nextSetDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadNextSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadNextSetExpectation], timeout: 1.0)
        nextSetDisposable.dispose()
        
        // request next results should return false due to last page calculation
        XCTAssertFalse(self.sut.fetchNextSetOfData(), "Request should be refused")
        
        // request first results should return true due to first page reset 1/2
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request was refused")
        let firstSetAgainDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadFirstSetAgainExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadFirstSetAgainExpectation], timeout: 1.0)
        firstSetAgainDisposable.dispose()
        
        // request next results should return true again due to page 2/2
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request was refused")
        let nextSetAgainDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadNextSetAgainExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadNextSetAgainExpectation], timeout: 1.0)
        nextSetAgainDisposable.dispose()
    }
    
    // MARK: - Paging Tests
    
    func test_userRequestToSeeTheFeed_beforeReachedTheLastPage_requestReturnsTrue() {
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should return true")
    }
    
    func test_userRequestToSeeTheFeed_afterReachedTheLastPage_requestReturnsFalse() {
        self.repository = StubRepository(with: stubbedSuccessWithLastPageManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        
        // request first results of page 1/1
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be true")
        let firstSetDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadFirstSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for:[loadFirstSetExpectation], timeout: 1.0)
        firstSetDisposable.dispose()
        
        // request next results of page 1/1
        XCTAssertFalse(self.sut.fetchNextSetOfData(), "Request should be refused")
    }
    
    func test_userRequestToSeeTheFeed_withACurrentRequestInProgress_requestReturnsFalse() {
        self.repository = StubRepository(with: stubbedSuccessWithManyResults, delay: 1.0)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        XCTAssertFalse(self.sut.fetchFirstSetOfData(), "Request should be refused")
    }
    
    func test_userRequestToSeeMoreFeeds_withACurrentRequestInProgress_requestReturnsFalse() {
        self.repository = StubRepository(with: stubbedSuccessWithManyResults, delay: 1.0)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        XCTAssertFalse(self.sut.fetchNextSetOfData(), "Request should be refused")
    }

    // MARK: - State Changes Tests

    func test_userRequestsToSeeTheFeed_withConnectivity_theStatesChangesFromNoneToFetchingThenSuccess() {
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        var stateHistory = [HomeViewModel.HomeViewModelState]()
        
        self.sut.state.asObservable().subscribe(onNext: { (newState) in
            stateHistory.append(newState)
            
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess, .fetchError:
                loadFirstSetExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        wait(for:[loadFirstSetExpectation], timeout: 1.0)
        
        XCTAssert( stateHistory.elementsEqual([
            HomeViewModel.HomeViewModelState.none,
            HomeViewModel.HomeViewModelState.fetching,
            HomeViewModel.HomeViewModelState.fetchSuccess
            ]), "State sequence should be from None to Fetching then Success but was: \(stateHistory)")
    }
    
    func test_userRequestsToSeeTheFeed_withNoConnectivity_theStatesChangesFromNoneToFetchingThenError() {
        self.repository = StubRepository(with: stubbedErrorWithZeroResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        var stateHistory = [HomeViewModel.HomeViewModelState]()
        
        self.sut.state.asObservable().subscribe(onNext: { (newState) in
            stateHistory.append(newState)
            
            switch newState {
            case .none, .fetching: break
            case .fetchSuccess, .fetchError:
                loadFirstSetExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        wait(for:[loadFirstSetExpectation], timeout: 1.0)
        
        XCTAssert( stateHistory.elementsEqual([
            HomeViewModel.HomeViewModelState.none,
            HomeViewModel.HomeViewModelState.fetching,
            HomeViewModel.HomeViewModelState.fetchError(localizedDescription: LocalizedString.unexpected_network_error.value)
            ]), "State sequence should be from None to Fetching then Error but was: \(stateHistory)")
    }
    
    func test_userRequestsToSeeMoreFeeds_withConnectivity_theStatesChangesFromSuccessToFetchingThenSuccess() {
        
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)

        var stateHistory = [HomeViewModel.HomeViewModelState]()
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        let nextSetOfDataExpectation = XCTestExpectation(description: "Load more feeds with error.")
        
        // load the first set of data
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        let loadFirstSetDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadFirstSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for: [loadFirstSetExpectation], timeout: 1.0)
        loadFirstSetDisposable.dispose()
        
        // load more data
        self.sut.state.asObservable().subscribe(onNext: { (newState) in
            stateHistory.append(newState)
            
            switch newState {
            case .none, .fetching: break
            case .fetchSuccess, .fetchError:
                nextSetOfDataExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request should be accepted")
        wait(for:[nextSetOfDataExpectation], timeout: 1.0)
        
        XCTAssert( stateHistory.elementsEqual([
            HomeViewModel.HomeViewModelState.fetchSuccess,
            HomeViewModel.HomeViewModelState.fetching,
            HomeViewModel.HomeViewModelState.fetchSuccess
            ]), "State sequence should be from None to Fetching then Success but was: \(stateHistory)")
    }
    
    func test_userRequestsToSeeMoreFeeds_withNoConnectivity_theStatesChangesFromSuccessToFetchingThenError() {
        self.repository = StubRepository(with: stubbedSuccessWithManyResults)
        self.sut = HomeViewModel(repository: repository, itemsPerPage: stubbedItemsPerPage)
        
        var stateHistory = [HomeViewModel.HomeViewModelState]()
        
        let loadFirstSetExpectation = XCTestExpectation(description: "Load first set of results.")
        let nextSetOfDataExpectation = XCTestExpectation(description: "Load more feeds with error.")
        
        // load the first set of data
        XCTAssertTrue(self.sut.fetchFirstSetOfData(), "Request should be accepted")
        let loadFirstSetDisposable = self.sut.state.subscribe(onNext: { (newState) in
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess:
                loadFirstSetExpectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
            }
        })
        wait(for: [loadFirstSetExpectation], timeout: 1.0)
        loadFirstSetDisposable.dispose()
        
        // set an error stubbed result
        (repository as! StubRepository).setStubbedResult(stubbedErrorWithZeroResults)
        
        // load more data
        self.sut.state.asObservable().subscribe(onNext: { (newState) in
            stateHistory.append(newState)
            
            switch newState {
            case .none, .fetching: break
                
            case .fetchSuccess, .fetchError:
                nextSetOfDataExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        XCTAssertTrue(self.sut.fetchNextSetOfData(), "Request should be accepted")
        wait(for:[nextSetOfDataExpectation], timeout: 1.0)
        
        XCTAssert( stateHistory.elementsEqual([
            HomeViewModel.HomeViewModelState.fetchSuccess,
            HomeViewModel.HomeViewModelState.fetching,
            HomeViewModel.HomeViewModelState.fetchError(localizedDescription: LocalizedString.unexpected_network_error.value)
            ]), "State sequence should be from None to Fetching then Success but was: \(stateHistory)")
    }
}
