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
    
    static let sharedInstance = CoreDataStack(modelName: "VirtualTourist")
    
    // Mark: - Properties
    
    private let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext!
    
    private init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // MARK: - Configuration
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
    
    // MARK: - Core Data Saving Support
    
    func saveViewContext(errorHandler: ((_ error: Error?) -> Void)? = nil) {
        viewContext.perform {
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                    errorHandler?(nil)
                } catch {
                    errorHandler?(error)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func saveBackgroundContext(errorHandler: ((_ error: Error?) -> Void)? = nil) {
        backgroundContext.perform {
            if self.backgroundContext.hasChanges {
                do {
                    try self.backgroundContext.save()
                    errorHandler?(nil)
                } catch {
                    errorHandler?(error)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Perform methods
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform {
            block(self.backgroundContext)
        }
    }
    
    func performViewTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        viewContext.perform {
            block(self.viewContext)
        }
    }
}
