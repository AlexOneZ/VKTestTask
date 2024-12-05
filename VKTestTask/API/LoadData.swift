//
//  LoadData.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 03.12.2024.
//

import Foundation
import Combine

private struct SearchResponse: Decodable {
    let items: [Repository]
}

final class LoadData: LoadDataProtocol {

    func loadRepository(searchName: String, page: Int, perPage: Int) -> AnyPublisher<[Repository], Error> {
        
        guard let url = url(text: searchName, page: page, perPage: perPage) else {
            //print("Just")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            //return Just([]).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map { $0.items }
        //.replaceError(with: [])
        //.receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func url(text: String, page: Int, perPage: Int) -> URL? {
        //return URL(string: "https://api.github.com/search/repositories?q=\(text)/&sort=stars&order=asc&page=\(page)")
        return URL(string: "https://api.github.com/search/repositories?q=\(text)&sort=stars&order=asc&page=\(page)&per_page=\(perPage)")
    }
}
