//
//  ManageRepositoriesUseCaseTests.swift
//  VKTestTaskTests
//
//  Created by Алексей Кобяков on 05.12.2024.
//

import XCTest
@testable import VKTestTask
import RealmSwift

final class TestRealmConfiguration {
    static func inMemory(identifier: String = UUID().uuidString) -> Realm.Configuration {
        return Realm.Configuration(inMemoryIdentifier: identifier)
    }
}

final class ManageRepositoriesUseCaseTests: XCTestCase {
    let mockStorage = MockRepositoryStorage()
    
    func testSaveOneRepo() {
        let repoObject = RepositoryObject()
        repoObject.fullName = "User/Repo1"
        repoObject.name = "OldName"
        repoObject.descriptionText = "OldDescription"

        mockStorage.saveOneRepo(repoObject, name: "NewName", description: "NewDescription")

        let savedObject = mockStorage.getRepoFromRealm(Repository(name: "Repo1", description: "OldDescription", full_name: "User/Repo1", created_at: "", owner: Repository.Owner(avatar_url: "")))
        XCTAssertEqual(savedObject?.name, "NewName")
        XCTAssertEqual(savedObject?.descriptionText, "NewDescription")
    }
    
    func testDeleteRepository() {
        let repo = Repository(
            name: "RepoToDelete",
            description: "Description",
            full_name: "User/RepoToDelete",
            created_at: "2024-01-01",
            owner: Repository.Owner(avatar_url: "https://example.com/avatar")
        )
        mockStorage.saveRepositories([repo])

        mockStorage.deleteRepository(repo)

        let fetchedRepositories = mockStorage.fetchRepositories()
        XCTAssertFalse(fetchedRepositories.contains(where: { $0.full_name == repo.full_name }))
        XCTAssertNil(mockStorage.getRepoFromRealm(repo))
    }
    
    func testDeleteAllRepositories() {
        let repos = [
            Repository(
                name: "Repo1",
                description: "Description1",
                full_name: "User/Repo1",
                created_at: "2024-01-01",
                owner: Repository.Owner(avatar_url: "https://avatars.githubusercontent.com/u/8825476?v=4")
            ),
            Repository(
                name: "Repo2",
                description: "Description2",
                full_name: "User/Repo2",
                created_at: "2024-01-02",
                owner: Repository.Owner(avatar_url: "")
            )
        ]
        mockStorage.saveRepositories(repos)

        mockStorage.deleteAllRepositories()

        XCTAssertTrue(mockStorage.fetchRepositories().isEmpty)
        repos.forEach { repo in
            XCTAssertNil(mockStorage.getRepoFromRealm(repo))
        }
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//MARK: - Mock class
class MockRepositoryStorage: RepositoryStorageProtocol {
    private var storage: [Repository] = []
    private var objectStorage: [String: RepositoryObject] = [:] // Используется для работы с RepositoryObject
    
    func fetchRepositories() -> [Repository] {
        return storage
    }
    
    func saveRepositories(_ repositories: [Repository]) {
        storage.append(contentsOf: repositories)
        repositories.forEach { repo in
            let repoObject = RepositoryObject()
            repoObject.fullName = repo.full_name
            repoObject.name = repo.name
            repoObject.descriptionText = repo.description
            repoObject.createdAt = repo.created_at
            repoObject.avatarURL = repo.owner.avatar_url
            objectStorage[repo.full_name] = repoObject
        }
    }
    
    func deleteRepository(_ repository: Repository) {
        storage.removeAll { $0.full_name == repository.full_name }
        objectStorage.removeValue(forKey: repository.full_name)
    }
    
    func deleteAllRepositories() {
        storage.removeAll()
        objectStorage.removeAll()
    }
    
    func saveOneRepo(_ repository: RepositoryObject, name: String, description: String?) {
        repository.name = name
        repository.descriptionText = description
        objectStorage[repository.fullName] = repository
    }
    
    func getRepoFromRealm(_ repository: Repository) -> RepositoryObject? {
        return objectStorage[repository.full_name]
    }
}
