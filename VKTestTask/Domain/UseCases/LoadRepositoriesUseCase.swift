//
//  LoadRepositoriesUseCase.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//
import Combine

final class LoadRepositoriesUseCase {
    private let api: LoadDataProtocol
    
    init(api: LoadDataProtocol) {
        self.api = api
    }
    
    func execute(searchName: String, page: Int, perPage: Int) -> AnyPublisher<[Repository], Error> {
        return api.loadRepository(searchName: searchName, page: page, perPage: perPage)
    }
}
