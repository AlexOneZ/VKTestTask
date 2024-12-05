//
//  RealmStorage.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 04.12.2024.
//

import Foundation
//import SwiftData

//@Model
//class RepositoryObject {
//    @Attribute(.unique) var id: UUID
//    var name: String
//    var descriptionText: String
//    var iconURL: String
//    var isEdited: Bool = false
//    
//    init(name: String, descriptionText: String, iconURL: String, isEdited: Bool = false) {
//        self.id = UUID()
//        self.name = name
//        self.descriptionText = descriptionText
//        self.iconURL = iconURL
//        self.isEdited = isEdited
//    }
//}
//
//func saveRepositoriesToSwiftData(_ repositories: [Repository]) {
//    for repo in repositories {
//        if !self.repositories.contains(where: { $0.name == repo.name }) {
//            let newRepo = RepositoryObject(
//                name: repo.name,
//                descriptionText: repo.composedDescription,
//                iconURL: repo.owner.avatar_url
//            )
//            context.insert(newRepo)
//        }
//    }
//}
//
//
//func fetchRepositoriesFromREalm() -> [RepositoryObject] {
//    let realm = try! Realm()
//    let repositories = realm.objects(RepositoryObject.self)
//    return Array(repositories)
//}
//
//func editRepository(by id: UUID, newName: String, newDescription: String?) {
//    if let repo = repositories.first(where: { $0.id == id }) {
//        repo.name = newName
//        repo.descriptionText = newDescription ?? "No description"
//        repo.isEdited = true
//    }
//}
//
//func deleteRepository(by id: UUID) {
//    if let repo = repositories.first(where: { $0.id == id }) {
//        context.delete(repo)
//    }
//}
