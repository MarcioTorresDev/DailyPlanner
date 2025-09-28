//
//  ViewController.swift
//  DailyPlanner
//
//  Created by Márcio Torres on 08/07/25.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [Category] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Minhas Categorias"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                             target: self,
                                                             action: #selector(addCategoryTapped))
        
        setupTableView()
        setupConstraints()
        fetchCategories()
    }
    
    // ✅ Atualiza a lista de categorias toda vez que a tela aparecer
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
        let alert = UIAlertController(title: "Nova Categoria",
                                      message: "Digite o nome da categoria",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome da categoria"
        }
        
        let addAction = UIAlertAction(title: "Adicionar", style: .default) { [weak self] _ in
            guard let self = self,
                  let categoryName = alert.textFields?.first?.text,
                  !categoryName.isEmpty else { return }
            
            let newCategory = Category(context: CoreDataManager.shared.context)
            newCategory.name = categoryName
            CoreDataManager.shared.saveContext()
            
            self.fetchCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    private func fetchCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try CoreDataManager.shared.context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Erro ao buscar categorias: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.configure(with: categories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        let notesVC = NotesViewController(category: selectedCategory)
        navigationController?.pushViewController(notesVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe Actions: Edit and Delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let category = categories[indexPath.row]
        
        // Delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Deletar") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            CoreDataManager.shared.context.delete(category)
            CoreDataManager.shared.saveContext()
            
            self.fetchCategories()
            completionHandler(true)
        }
        
        // Edit
        let editAction = UIContextualAction(style: .normal, title: "Editar") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Editar Categoria",
                                          message: "Digite o novo nome",
                                          preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = category.name
                textField.placeholder = "Nome da categoria"
            }
            
            let saveAction = UIAlertAction(title: "Salvar", style: .default) { _ in
                guard let newName = alert.textFields?.first?.text, !newName.isEmpty else {
                    completionHandler(false)
                    return
                }
                
                category.name = newName
                CoreDataManager.shared.saveContext()
                self.fetchCategories()
                completionHandler(true)
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                completionHandler(false)
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
