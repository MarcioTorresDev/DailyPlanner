//
//  Note+CoreDataProperties.swift
//  DailyPlanner
//
//  Created by Márcio Torres on 10/07/25.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension Note : Identifiable {

}
