//
//  LoadDataProtocol.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//
import Combine

protocol LoadDataProtocol {
    func loadRepository(searchName: String, page: Int, perPage: Int) -> AnyPublisher<[Repository], Error>
}
