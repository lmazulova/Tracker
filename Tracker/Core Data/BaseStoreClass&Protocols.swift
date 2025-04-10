import CoreData
import UIKit

// MARK: - TrackerStoreUpdate

struct TrackerStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
}

// MARK: - Protocols

protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) throws -> Tracker
    func addRecord(_ record: Tracker) throws
    func filterByDate(_ date: Date)
    func filterByTitle(_ title: String)
    func titleForSection(_ section: Int) -> String?
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func collectionFullReload()
    func deleteSections(_ indexSet: IndexSet)
    func insertSections(_ indexSet: IndexSet)
}

// MARK: - BaseStore

class BaseStore: NSObject {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    convenience override init() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            self.init(context: context)
        } else {
            fatalError("[\(#function)] - Unable to initialize Core Data context")
        }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>?
        
        context.performAndWait {
            result = action(context)
        }
        
        return try result?.get() ?? {
            throw CoreDataErrors.nilResult
        }()
    }
}

