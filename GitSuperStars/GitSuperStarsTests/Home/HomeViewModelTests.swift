import XCTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import GitSuperStars

class HomeViewModelTests: XCTestCase {
    
    private var disposeBag: DisposeBag!

    private var viewModel: HomeViewModel!
    private var repository: Repository!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        super.tearDown()
        self.repository = nil
        self.viewModel = nil
    }
    
    func test_userRequestsToSeeTheFeed_withConnectivity_returnsFeed() throws {
        
        self.repository = StubRepository(with: .success(StubRepository.loadMockedGitRepositoryQueryResult()))
        self.viewModel = HomeViewModel(repository: repository)
        
        let expectation = XCTestExpectation(description: "Load stubbed feed results with connectivity.")
        let startedWithLoadedItemsCount = viewModel.currentCount
        
        self.viewModel.state.asObservable().subscribe(onNext: { [weak self] (state) in
            guard let self = self else { return }
            
            switch self.viewModel.state.value {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTAssertTrue( (self.viewModel.currentCount > startedWithLoadedItemsCount) , "The request started with \(startedWithLoadedItemsCount) but finished with \(self.viewModel.currentCount) saved results.")
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(self.viewModel.fetchFirstSetOfData(), "Request was refused")
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_userRequestsToSeeTheFeed_withNoConnectivity_returnsError() {
        
        self.repository = StubRepository(with: .error(RepositoryError(with: LocalizedString.unexpected_network_error.value)))
        self.viewModel = HomeViewModel(repository: repository)
        let expectation = XCTestExpectation(description: "Load stubbed feed results with no connectivity.")
        
        self.viewModel.state.asObservable().subscribe(onNext: { [weak self] (state) in
            guard let self = self else { return }
            
            switch self.viewModel.state.value {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTFail("Fetch returned success but the expected was an error")
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTAssertTrue(true, "The request succeded bringing the error: \(localizedDescription).")
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(viewModel.fetchFirstSetOfData(), "Request was refused")
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_userRequestsToSeeTheNextFeeds_withConnectivity_returnsFeed() {
        
        self.repository = StubRepository(with: .success(StubRepository.loadMockedGitRepositoryQueryResult()))
        self.viewModel = HomeViewModel(repository: repository)
        
        let expectation = XCTestExpectation(description: "Load more stubbed feed results.")
        let startedWithLoadedItemsCount = viewModel.currentCount
    
        self.viewModel.state.asObservable().subscribe(onNext: { [weak self] (state) in
            guard let self = self else { return }
            
            switch self.viewModel.state.value {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTAssertNotNil(self.viewModel, "Fetch success.")
                XCTAssertTrue( (self.viewModel.totalCount > startedWithLoadedItemsCount) , "The request started with \(startedWithLoadedItemsCount) but finished with \(self.viewModel.currentCount) saved results.")
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTFail("Fetch returned an error with description: \(localizedDescription)")
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(self.viewModel.fetchNextSetOfData(), "Request was refused")
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_userRequestsToSeeTheNextFeeds_withNoConnectivity_returnsError() {
        
        self.repository = StubRepository(with: .error(RepositoryError(with: LocalizedString.unexpected_network_error.value)))
        self.viewModel = HomeViewModel(repository: repository)
        let expectation = XCTestExpectation(description: "Load stubbed feed results with no connectivity.")
        
        self.viewModel.state.asObservable().subscribe(onNext: { [weak self] (state) in
            guard let self = self else { return }
            
            switch self.viewModel.state.value {
            case .none, .fetching: break
                
            case .fetchSuccess:
                XCTFail("Fetch returned success but the expected was an error")
                expectation.fulfill()
                
            case .fetchError(let localizedDescription):
                XCTAssertTrue(true, "The request succeded bringing the error: \(localizedDescription).")
                expectation.fulfill()
            }
        }).disposed(by: disposeBag)
        
        XCTAssertTrue(self.viewModel.fetchNextSetOfData(), "Request was refused")
        wait(for: [expectation], timeout: 5.0)
    }
}

