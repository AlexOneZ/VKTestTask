//
//  ViewController.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 01.12.2024.
//

import UIKit
import Combine
import SwiftData

class ViewController: UIViewController, UISearchResultsUpdating {
    
    

    let cellIdentifier = "repositoryCell"
    private var cancellables = Set<AnyCancellable>()
    //private var currentTask: URLSessionTask?
    //var repositories: [RepositoryObject] = [] // Локальная копия данных для отображения
    var repositories: [Repository] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var searchQuery = "swift"
    
    private var perPage = 20
    private var hasMoreData = true
    
    private var lastOffsetY: CGFloat = 0
    private var scrollSpeed: CGFloat = 0
    private let scrollSpeedThreshold: CGFloat = 500 // Порог скорости прокрутки
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 16)
        //tableView.rowHeight = view.frame.height/6
        tableView.estimatedRowHeight = 100 
        tableView.backgroundColor = .white
        //tableView.separatorColor = .systemGray
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Введите запрос..."
        controller.obscuresBackgroundDuringPresentation = false
        //controller.searchResultsUpdater = self
        controller.hidesNavigationBarDuringPresentation = false // Оставить Navigation Bar видимым
        return controller
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGray3
        //indicator.isHidden = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        return button
    }()
    
// MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Поиск"
        
        setupViews()
        setupConstraints()
        
//        searchController.searchBar.textPublisher
//            .debounce(for: .milliseconds(200), scheduler: RunLoop.main) // оптимизация. не позволяет слишком часто отправлть запросы
//            .removeDuplicates() // исключает повторный запрос
//            .sink { [weak self] query in
//                guard let self = self, !query.isEmpty else { return }
//                if query != self.searchQuery {
//                    print("New search")
//                    self.currentPage = 1 // сброс страницы при новом поиске
//                    self.repositories.removeAll()
//                    self.tableView.reloadData()
//                    self.searchQuery = query
//                    self.fetchRepositries(query: query, page: self.currentPage)
//                }
//            }
//            .store(in: &cancellables)
        
        
//        loadRepository(searchName: "swift", page: 1)
//            .sink { [weak self] repositories in
//                self?.repositories = repositories
//                self?.tableView.reloadData()
//            }
//            .store(in: &cancellables)
        
    }

    private func setupViews() {
        //view.addSubview(searchBar)
        //navigationItem.titleView = searchBar
        navigationItem.searchController = searchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let fpsCounter = FPSCounter(frame: CGRect(x: 20, y: 50, width: 80, height: 30))
        fpsCounter.backgroundColor = .black
        //view.addSubview(fpsCounter)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sortButton)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: editButton),
            //UIBarButtonItem(customView: activityIndicator)
            UIBarButtonItem(customView: fpsCounter)
            
        ]

        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray5
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        view.addSubview(tableView)
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        let footerView = UIView(frame: CGRect(x:0,y: 0,width: view.frame.width, height: 50))
        footerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        tableView.tableFooterView = footerView
        
        searchController.searchResultsUpdater = self
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
//MARK: - fetchRepos
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let query = searchController.searchBar.text else {
            print("No query!")
            return
        }
        
        if query != searchQuery, !query.isEmpty {
            print("New search")
            currentPage = 1 // сброс страницы при новом поиске
            repositories.removeAll()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            searchQuery = query
            fetchRepositries(query: query, page: self.currentPage)
        }
    }
    
    private func fetchRepositries(query: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()

        
        loadRepository(searchName: query, page: page, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.activityIndicator.stopAnimating()
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Loading error: \(error)")
                    }
                
            }
                  , receiveValue: { [weak self] repositories in
                      guard let self = self else { return }
                     
                      if repositories.count < self.perPage {
                          print("end on page")
                          self.hasMoreData = false
                      }
                      self.repositories.append(contentsOf: repositories)
                      
                      
                      //saveRepositoriesToSwiftData(repositories)
                      self.tableView.reloadData()
                      self.isLoading = false
                  })
            .store(in: &cancellables)
    }

}

// MARK: - Extensions

extension ViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == repositories.count - 10 {
//            print("cell drawed")
//            if !isLoading && hasMoreData {
//                makeNextFetch()
//            }
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // текущая позиция скрола по вертикали
        //let offsetY = scrollView.contentOffset.y
        // полная высота содержимого таблицы
        //let contentHeight = scrollView.contentSize.height
        // высота видимой области таблицы
        //let frameHeight = scrollView.frame.size.height
//        let frameHeight = view.frame.size.height
//        let preloadThreshold: CGFloat = frameHeight * 1.5
//        
//        // Проверяю, осталось ли меньше определенного расстояния до конца
//        if offsetY + frameHeight + preloadThreshold > scrollView.contentSize.height {
//            if !isLoading && hasMoreData {
//                currentPage += 1
//                fetchRepositries(query: searchQuery, page: currentPage)
//            }
//            
//        }
        guard repositories.count != 0 else 
        {
            print("repos = 0")
            return
        }
        
        let currentOffsetY = scrollView.contentOffset.y
            scrollSpeed = abs(currentOffsetY - lastOffsetY)

            // Если скорость прокрутки высокая, подгружаем данные
            if scrollSpeed > scrollSpeedThreshold && !isLoading && hasMoreData {
                print("Speed up")
                makeNextFetch()
            }

            // Используем размер экрана для подгрузки данных заранее
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = view.frame.size.height
            let preloadThreshold: CGFloat = frameHeight * 2.5 // Когда остается полтора экрана

            if offsetY + frameHeight + preloadThreshold > contentHeight {
                if !isLoading && hasMoreData {
                    print("end of list")
                    makeNextFetch()
                }
            }

            // Обновляем предыдущий offset
            lastOffsetY = currentOffsetY
    }
    
    private func makeNextFetch() {
        currentPage += 1
        fetchRepositries(query: searchQuery, page: currentPage)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if repositories.isEmpty {
            print("Repositories is Empty!")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? RepositoryCell
        
        //cell?.backgroundColor = .clear
        
        let repository = repositories[indexPath.row]
        
        cell?.configure(with: repository)
        
        return cell ?? UITableViewCell()
    }
    
    
}

extension UISearchBar {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self.searchTextField)
            .map { ($0.object as? UISearchTextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
