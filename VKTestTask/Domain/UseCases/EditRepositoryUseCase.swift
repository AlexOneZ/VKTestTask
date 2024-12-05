//
//  EditRepositoryUseCase.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//

final class EditRepositoryUseCase {
    private let repositoryStorage: RepositoryStorageProtocol

    init(repositoryStorage: RepositoryStorageProtocol) {
        self.repositoryStorage = repositoryStorage
    }

    func fetchRepositoryObject(for repository: Repository) -> RepositoryObject? {
        return repositoryStorage.getRepoFromRealm(repository)
    }

    func updateRepositoryObject(_ repositoryObject: RepositoryObject, name: String, description: String?) {
        repositoryStorage.saveOneRepo(repositoryObject, name: name, description: description)
    }
}
