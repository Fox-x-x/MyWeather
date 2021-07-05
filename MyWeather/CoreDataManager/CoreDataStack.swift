//
//  CoreDataStack.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 16.06.2021.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    static var persistentStoreContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError()
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return CoreDataStack.persistentStoreContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return CoreDataStack.persistentStoreContainer.newBackgroundContext()
    }
    
    func save(context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                 do {
                     try context.save()
                 } catch {
                     print(error.localizedDescription)
                 }
             }
        }
    }
    
    func createObject<CW: NSManagedObject> (from entity: CW.Type, with context: NSManagedObjectContext) -> CW {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! CW
        return object
    }
    
    func delete(object: NSManagedObject, with context: NSManagedObjectContext) {
        context.delete(object)
        save(context: context)
    }
    
    func fetchData<CW: NSManagedObject>(for entity: CW.Type, with context: NSManagedObjectContext) -> [CW] {
        let request = entity.fetchRequest() as! NSFetchRequest<CW>
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data from context")
            fatalError()
        }
    }
    
    func fetchDataWithRequest<CW: NSManagedObject>(for entity: CW.Type, with context: NSManagedObjectContext, request: NSFetchRequest<CW>) -> [CW] {
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data from context")
            fatalError()
        }
    }
}
