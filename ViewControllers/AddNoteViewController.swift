//
//  AddNoteViewController.swift
//  DailyPlanner
//
//  Created by Márcio Torres on 08/07/25.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    // MARK: - Callbacks
    var onSaveNote: (() -> Void)? // agora não precisa passar a Note, vamos buscar depois do Core Data
    var onEditNote: (() -> Void)?
    
    // MARK: - Edição
    var noteToEdit: Note?
    
    // MARK: - Nova Propriedade (obrigatória)
    var category: Category! // precisa ser passada pela NotesViewController
    
    // MARK: - UI Elements
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Título da nota"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Salvar", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let note = noteToEdit {
            titleTextField.text = note.title
            contentTextView.text = note.content
            title = "Editar Nota"
        } else {
            title = "Nova Nota"
        }
        
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 300),
            
            saveButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let content = contentTextView.text ?? ""
        
        if let note = noteToEdit {
            // Editar nota existente
            note.title = title
            note.content = content
            CoreDataManager.shared.saveContext()
            onEditNote?()
        } else {
            // Criar nova nota
            let note = Note(context: CoreDataManager.shared.context)
            note.title = title
            note.content = content
            note.category = category // relacionamento
            CoreDataManager.shared.saveContext()
            onSaveNote?()
        }
        
        navigationController?.popViewController(animated: true)
    }
}
