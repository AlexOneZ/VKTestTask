//
//  VKTestTaskTests.swift
//  VKTestTaskTests
//
//  Created by Алексей Кобяков on 05.12.2024.
//
import XCTest
import Combine
@testable import VKTestTask

final class APITests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testLoadRepositoriesSuccess() {
        let mockAPI = MockAPI() 
        let useCase = LoadRepositoriesUseCase(api: mockAPI)
        let expectation = self.expectation(description: "Load repositories successfully")
        var fetchedRepositories: [Repository] = []

        useCase.execute(searchName: "test", page: 1, perPage: 10)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    XCTFail("Expected success, but got failure")
                case .finished:
                    break
                }
            }, receiveValue: { repositories in
                fetchedRepositories = repositories
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(fetchedRepositories.count, 2)
        XCTAssertEqual(fetchedRepositories[0].name, "")
        XCTAssertEqual(fetchedRepositories[1].name, "Repo 2")
    }

    func testLoadRepositoriesFailure() {
        let mockAPI = MockAPI()
        mockAPI.shouldReturnError = true
        let useCase = LoadRepositoriesUseCase(api: mockAPI)
        let expectation = self.expectation(description: "Load repositories with failure")
        var receivedError: Error?

        useCase.execute(searchName: "test", page: 1, perPage: 10)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                case .finished:
                    XCTFail("Expected failure, but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, but got repositories")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertNotNil(receivedError)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//MARK: - Mock class
class MockAPI: LoadDataProtocol {
    var shouldReturnError = false
    func loadRepository(searchName: String, page: Int, perPage: Int) -> AnyPublisher<[VKTestTask.Repository], any Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "Test", code: 1, userInfo: nil))
                            .eraseToAnyPublisher()
        } else {
            let repositories = [
                VKTestTask.Repository(
                    name: "",
                    description: "",
                    full_name: "",
                    created_at: "",
                    owner: VKTestTask.Repository.Owner(avatar_url: "")
                ),
                VKTestTask.Repository(
                    name: "Repo 2",
                    description: "Description for Repo 2",
                    full_name: "full_name_2",
                    created_at: "2024-02-01",
                    owner: VKTestTask.Repository.Owner(avatar_url: "https://avatars.githubusercontent.com/u/8825476?v=4")
                )
            ]
            return Just(repositories)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

}

