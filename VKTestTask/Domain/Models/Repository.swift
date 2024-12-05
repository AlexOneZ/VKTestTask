//
//  Repository.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 02.12.2024.
//

import Foundation

struct Repository: Decodable {
    let name: String
    let description: String?
    let full_name: String
    let created_at: String
    let owner: Owner
        
    struct Owner: Decodable {
        let avatar_url: String
    }
    
    var composedDescription: String {
        if let description = description, !description.isEmpty {
            return description
        }
        else {
            return "\(full_name)\n\(created_at)"
        }
    }
}
