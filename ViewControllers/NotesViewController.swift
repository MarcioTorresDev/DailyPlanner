//
//  NotesViewController.swift
//  DailyPlanner
//
//  Created by Márcio Torres on 08/07/25.
//

import UIKit

class NotesViewController: UIViewController {
    
    // MARK: - Properties
    var category: Category
    private var notes: [Note] = []
    
    private let tableView = UITableView()
    
    // MARK: - Initializer
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = category.name
        
        setupTableView()
        setupNavigationBar()
        setupConstraints()
        
        fetchNotes()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
        view.addSubview(tableView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                             target: self,
                                                             action: #selector(addNoteTapped))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Fetch Notes
    private func fetchNotes() {
        if let notesSet = category.notes as? Set<Note> {
            notes = notesSet.sorted { ($0.title ?? "") < ($1.title ?? "") }
        } else {
            notes = []
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addNoteTapped() {
        let addNoteVC = AddNoteViewController()
        addNoteVC.category = self.category
        
        addNoteVC.onSaveNote = { [weak self] in
            self?.fetchNotes()
        }
        
        navigationController?.pushViewController(addNoteVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension NotesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let selectedNote = notes[indexPath.row]
        
        let editNoteVC = AddNoteViewController()
        editNoteVC.category = self.category
        editNoteVC.noteToEdit = selectedNote
        
        editNoteVC.onEditNote = { [weak self] in
            self?.fetchNotes()
        }
        
        navigationController?.pushViewController(editNoteVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe to Delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Deletar") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            let noteToDelete = self.notes[indexPath.row]
            CoreDataManager.shared.context.delete(noteToDelete)
            CoreDataManager.shared.saveContext()
            
            self.fetchNotes()
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
