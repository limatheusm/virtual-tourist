//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Matheus Lima on 23/01/19.
//  Copyright © 2019 Matheus Lima. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    // Mark: - Singleton
    
    static let sharedInstance = CoreDataStack()
    
    // Mark: - Properties
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    }
    
    // MARK: - Configuration
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    // MARK: - Core Data Saving Support
    
    func saveViewContext(errorHandler: ((_ error: Error) -> Void)? = nil) {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                errorHandler?(error)
                print(error.localizedDescription)
            }
        }
    }
    
}
