//
//  CoreData.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 11/12/20.
//

import Foundation
import CoreData

// MARK: - Core Data stack
class CoreDataStack {
  static let shared = CoreDataStack()
  lazy var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "DataStore")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    guard context.hasChanges else {return}
    do {
      try context.save()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
  
}
