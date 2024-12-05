//
//  ManageRepositoriesUseCase.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//

import Foundation

final class ManageRepositoriesUseCase {
    private let repositoryStorage: RepositoryStorageProtocol
    
    init(repositoryStorage: RepositoryStorageProtocol) {
        self.repositoryStorage = repositoryStorage
    }
    
    func fetchRepositories() -> [Repository] {
        return repositoryStorage.fetchRepositories()
    }
    
    func saveRepositories(_ repositories: [Repository]) {
        repositoryStorage.saveRepositories(repositories)
    }
    
    func deleteRepository(_ repository: Repository) {
        repositoryStorage.deleteRepository(repository)
    }
    
    func deleteAllRepositories() {
        repositoryStorage.deleteAllRepositories()
    }
}
