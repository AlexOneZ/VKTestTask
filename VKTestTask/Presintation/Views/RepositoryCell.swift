//
//  RepositoryCell.swift
//  VKTestTask
//
//  Created by Алексей Кобяков on 02.12.2024.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = Constants.Fonts.systemHeading
        label.textColor = .black
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label =  UILabel()
        label.text = "Description"
        label.font = Constants.Fonts.systemText
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var avatarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            
    }
    
    private func setupConstraints() {
        avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
            avatarImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
            avatarImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
            avatarImage.heightAnchor.constraint(equalToConstant: 50).isActive = true

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 10).isActive = true
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 10).isActive = true
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }
    
    func configure(with repository: Repository) {
        nameLabel.text = repository.name
        descriptionLabel.text = repository.composedDescription
        
        if let url = URL(string: repository.owner.avatar_url) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    self.avatarImage.image = UIImage(systemName: "person")
                    return
                }
                DispatchQueue.main.async {
                    self.avatarImage.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
