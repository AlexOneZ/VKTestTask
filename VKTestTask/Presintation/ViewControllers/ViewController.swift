//
//  ViewController.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 01.12.2024.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let cellIdentifier = "repositoryCell"
    
    private let loadRepositoriesUseCase: LoadRepositoriesUseCase
    private let manageRepositoriesUseCase: ManageRepositoriesUseCase
    private let editRepositroiesUseCase: EditRepositoryUseCase
    private var cancellables = Set<AnyCancellable>()
    var repositories: [Repository] = []
    

    
    private var isEditingMode = false
    
    private var currentPage = 1
    private var isLoading = false
    private var searchQuery = ""
    
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
        tableView.allowsMultipleSelectionDuringEditing = true
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Введите запрос..."
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
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
    
    private lazy var deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить ВСЕ", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteSelectedRows), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.addTarget(self, action: #selector(toggleEditingMode), for: .touchUpInside)
        return button
    }()
    
    private lazy var footerView: UIView = { UIView(frame: CGRect(x:0,y: 0,width: view.frame.width, height: 50)) }()
    
// MARK: - viewDidLoad, init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupViews()
        updateNavigationButtons(visible: true)
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromRealm()
        updateDeleteButtonTitle()
    }
    
    init(loadRepositoriesUseCase: LoadRepositoriesUseCase,
         manageRepositoriesUseCase: ManageRepositoriesUseCase,
         editRepositoriesUseCase: EditRepositoryUseCase) {
        self.loadRepositoriesUseCase = loadRepositoriesUseCase
        self.manageRepositoriesUseCase = manageRepositoriesUseCase
        self.editRepositroiesUseCase = editRepositoriesUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        title = "Поиск"
        view.backgroundColor = .white
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    
        view.addSubview(tableView)
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        footerView.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        tableView.tableFooterView = footerView
        
        searchController.searchResultsUpdater = self
    }
    
    //MARK: - Button functions
    @objc private func toggleEditingMode() {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
        deleteAllButton.isHidden = !isEditingMode
    }
    
    @objc private func deleteSelectedRows() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            // Удаление из массива
            let reposToDelete = selectedRows.map { repositories[$0.row] }
            reposToDelete.forEach { manageRepositoriesUseCase.deleteRepository($0) }
            repositories = repositories.enumerated()
                .filter { !selectedRows.contains(IndexPath(row: $0.offset, section: 0)) }
                .map { $0.element }
            
            tableView.deleteRows(at: selectedRows, with: .automatic)
        } 
        else {
            // Удаление всех строк
            manageRepositoriesUseCase.deleteAllRepositories()
            repositories.removeAll()
            tableView.reloadData()
        }
        updateDeleteButtonTitle()
    }
    
    private func updateNavigationButtons(visible: Bool) {
        if visible {
            let fpsCounter = FPSCounter(frame: CGRect(x: 20, y: 50, width: 80, height: 30))
            fpsCounter.backgroundColor = .black
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: deleteAllButton)
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(customView: editButton),
                UIBarButtonItem(customView: fpsCounter)
            ]
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItems = nil
        }
        if isEditingMode {
            toggleEditingMode()
        }
    }
    
//MARK: - Get repos
    private func fetchRepositries(query: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        print("fetching")
        
        loadRepositoriesUseCase.execute(searchName: query, page: page, perPage: perPage)
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
                      self.manageRepositoriesUseCase.saveRepositories(repositories)
                      self.tableView.reloadData()
                      self.isLoading = false
                  })
            .store(in: &cancellables)
    }
    
    private func loadDataFromRealm() {
        repositories = manageRepositoriesUseCase.fetchRepositories()
        tableView.reloadData()
    }
}

// MARK: - Extensions
extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard repositories.count != 0 else 
        {
            print("repos = 0")
            return
        }
        
        let currentOffsetY = scrollView.contentOffset.y
            scrollSpeed = abs(currentOffsetY - lastOffsetY)

            // Если скорость прокрутки высокая
            if scrollSpeed > scrollSpeedThreshold && !isLoading && hasMoreData {
                print("Speed up")
                makeNextFetch()
            }

            // Использую размер экрана для подгрузки данных
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = view.frame.size.height
            let preloadThreshold: CGFloat = frameHeight * 2.5

            if offsetY + frameHeight + preloadThreshold > contentHeight {
                if !isLoading && hasMoreData {
                    print("end of list")
                    makeNextFetch()
                }
            }

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
        let repository = repositories[indexPath.row]
        cell?.configure(with: repository)
        
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            updateDeleteButtonTitle()
            return
        }
        
        let storyboard = UIStoryboard(name: "EditRepoScreen", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditScreenViewController") as? EditScreenViewController else { return }

        editVC.repository = repositories[indexPath.row]
        editVC.editRepositoryUseCase = self.editRepositroiesUseCase
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        updateDeleteButtonTitle()
        
    }
    private func updateDeleteButtonTitle() {
        if let selectedRows = tableView.indexPathsForSelectedRows, !selectedRows.isEmpty {
            deleteAllButton.setTitle("Удалить строк: (\(selectedRows.count))", for: .normal)
        } else {
            deleteAllButton.setTitle("Удалить ВСЕ", for: .normal)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
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
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    // Убираю кнопки редактирования в момент начала поиска
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateNavigationButtons(visible: false)
    }
    
    // в момент натия Отмены и Поиска восстанавливаю кнопки
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateNavigationButtons(visible: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateNavigationButtons(visible: true)
    }
}
