//
//  CoreDataManager.swift.swift
//  DailyPlanner
//
//  Created by Márcio Torres on 08/07/25.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    // MARK: - Persistent Container
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Init
    private init() {
        persistentContainer = NSPersistentContainer(name: "DailyPlannerDataModel")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Erro ao carregar o container do Core Data: \(error)")
            }
        }
    }
    
    // MARK: - Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Erro ao salvar no Core Data: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
