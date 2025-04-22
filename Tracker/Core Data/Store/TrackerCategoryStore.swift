import UIKit
import CoreData

protocol CategoryDataProviderProtocol: AnyObject {
    var numberOfRows: Int { get }
    func object(at index: Index) throws -> TrackerCategory
    
    func addRecord(with title: String) throws
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    
    static let shared = TrackerCategoryStore()
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var insertedIndexes: Set<IndexPath> = []
    private var deletedIndexes: Set<IndexPath> = []
    
    // MARK: - Init

    
    // MARK: - Private Methods
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait{
            guard let coordinator = self.context.persistentStoreCoordinator else { return }
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    
    // MARK: - Deinitialization
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchResultController.delegate = self
        
        try? fetchResultController.performFetch()
        
        return fetchResultController
    }()
}

extension TrackerCategoryStore: CategoryDataProviderProtocol {
    func addRecord(with title: String) throws {
        try performSync { context in
            Result {
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData.categoryTitle = title
                trackerCategoryCoreData.createdAt = Date()

                try context.save()
            }
        }
    }
    
    
    func object(at index: Index) throws -> TrackerCategory {
        
        guard let numberOfCategories = fetchedResultController.fetchedObjects?.count,
              index < numberOfCategories else {
            throw CoreDataErrors.rowOutOfRange(index: index)
        }
        
        let categoryData = fetchedResultController.object(at: IndexPath(row: index, section: 0))
        
        guard let title = categoryData.categoryTitle else {
            throw CoreDataErrors.categoryConversionError
        }
        
        let trackerCategory = TrackerCategory(categoryTitle: title)
          
        return trackerCategory
    }
    
    var numberOfRows: Int {
        fetchedResultController.fetchedObjects?.count ?? 0
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes)
        )
        
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes.insert(indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath)
            }
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath)
            }
        default:
            break
        }
    }
    
}
