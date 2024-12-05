//
//  RealmStorageProtocol.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//

protocol RepositoryStorageProtocol {
    func fetchRepositories() -> [Repository]
    func saveRepositories(_ repositories: [Repository])
    func deleteRepository(_ repository: Repository)
    func deleteAllRepositories()
    func saveOneRepo(_ repository: RepositoryObject, name: String, description: String?)
    func getRepoFromRealm(_ repository: Repository) -> RepositoryObject?
}
