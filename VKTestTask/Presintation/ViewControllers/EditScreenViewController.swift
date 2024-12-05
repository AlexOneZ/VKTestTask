//
//  EditScreenViewController.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 05.12.2024.
//

import UIKit

class EditScreenViewController: UIViewController {
    
    var editRepositoryUseCase: EditRepositoryUseCase?
    var repository: Repository?
    var repositoryObject: RepositoryObject?

    
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBAction func saveButtonAction(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
                  let description = descriptionTextField.text else {
                return
            }

        guard let repositoryObject = repositoryObject, let useCase = editRepositoryUseCase else {
            return
        }
        useCase.updateRepositoryObject(repositoryObject, name: name, description: description)
    
        navigationController?.popViewController(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Редактирование"
        // Заполняю текстовые поля переданной информацией
        guard let repository = repository, let useCase = editRepositoryUseCase else {
               print("No repository object passed")
               return
           }
        repositoryObject = useCase.fetchRepositoryObject(for: repository)
        nameTextField.text = repository.name
        descriptionTextField.text = repository.composedDescription
    }
}
