import Foundation
import CoreData

enum MainCoreDataError: Error {
    case error
}

final class MainCoreData {
    private let modelName = "CoreData"
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init() {
        _ = persistentContainer
    }
    
    static let shared = MainCoreData()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
