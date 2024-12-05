//
//  RealmStorage.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 04.12.2024.
//

import Foundation
import RealmSwift

class RepositoryObject: Object {
    @Persisted(primaryKey: true) var fullName: String // Уникальный идентификатор
    @Persisted var name: String
    @Persisted var descriptionText: String?
    @Persisted var createdAt: String
    @Persisted var avatarURL: String
}

class RepositoryStorage: RepositoryStorageProtocol {

    
    private let realm = try! Realm()
    
    // Сохранение списка репозиториев
    func saveRepositories(_ repositories: [Repository]) {
        let realmObjects = repositories.map { repo in
            return repoToRealmObject(repo)
        }
        
        try! realm.write {
            realm.add(realmObjects, update: .modified)
        }
    }
    
    // Получение всех сохраненных репозиториев    
    func fetchRepositories() -> [Repository] {
        let realmObjects = realm.objects(RepositoryObject.self)
        return realmObjects.map { object in
            Repository(
                name: object.name,
                description: object.descriptionText,
                full_name: object.fullName,
                created_at: object.createdAt,
                owner: Repository.Owner(avatar_url: object.avatarURL)
            )
        }
    }
    
    // Удаление репозитория
    func deleteRepository(_ repository: Repository) {
        // Ищем объект в текущем экземпляре Realm по первичному ключу
        if let objectToDelete = realm.object(ofType: RepositoryObject.self, forPrimaryKey: repository.full_name) {
            try! realm.write {
                realm.delete(objectToDelete)
            }
        } else {
            print("Object not found in current Realm instance")
        }
    }
    
    func saveOneRepo(_ repository: RepositoryObject, name: String, description: String?) {
        do {
            try realm.write {
                repository.name = name
                repository.descriptionText = description
            }
        } catch {
            print("Error saving repository: \(error)")
        }
    }
    
    func getRepoFromRealm(_ repository: Repository) -> RepositoryObject? {
        return realm.object(ofType: RepositoryObject.self, forPrimaryKey: repository.full_name)
    }
    
    func deleteAllRepositories() {
        do {
            let realm = try Realm()
            let allRepositories = realm.objects(RepositoryObject.self)
            try realm.write {
                realm.delete(allRepositories)
            }
        }
        catch {
            print("Error deleting all repositories: \(error)")
        }
    }
    
    // Обновление данных репозитория
    func updateRepository(_ repository: RepositoryObject, with newData: Repository) {
        try! realm.write {
            repository.name = newData.name
            repository.descriptionText = newData.composedDescription
            repository.createdAt = newData.created_at
            repository.avatarURL = newData.owner.avatar_url
        }
    }
    
    private func repoToRealmObject(_ repo: Repository) -> RepositoryObject {
        let repoObject = RepositoryObject()
        repoObject.fullName = repo.full_name
        repoObject.name = repo.name
        repoObject.descriptionText = repo.composedDescription
        repoObject.createdAt = repo.created_at
        repoObject.avatarURL = repo.owner.avatar_url
        return repoObject
    }
}

//func testSaveRepositories() {
//    let realmConfig = Realm.Configuration(inMemoryIdentifier: "TestRealm")
//    let realm = try! Realm(configuration: realmConfig)
//
//    let viewModel = RepositoryViewModel()
//    viewModel.save(repositories: [mockRepository]) // Создай mock-данные
//
//    XCTAssertEqual(realm.objects(RepositoryObject.self).count, 1)
//}
