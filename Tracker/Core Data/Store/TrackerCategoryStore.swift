import UIKit
import CoreData

protocol CategoryDataProviderProtocol {
    var numberOfRows: Int { get }
    func title(at indexPath: IndexPath) throws -> String
    
    func addRecord(with title: String) throws
}

final class TrackerCategoryStore: BaseStore {
    
    weak var delegate: CategoryViewController?
    
    private var insertedIndexes: Set<IndexPath> = []
    private var deletedIndexes: Set<IndexPath> = []
    
    // MARK: - Init
    
    override init(context: NSManagedObjectContext) {
        super.init(context: context)
    }
    
    // MARK: - Private Methods
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait{
            guard let coordinator = self.context.persistentStoreCoordinator else { return }
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    // MARK: - Public Methods
    
//    func setupRecords() {
//        let checkRequest = TrackerCategoryCoreData.fetchRequest()
//        guard let result = try? context.fetch(checkRequest),
//           result.isEmpty
//        else {
//            return
//        }
//        let newCategory = TrackerCategoryCoreData(context: context)
//        newCategory.categoryTitle = "Важное"
//        newCategory.createdAt = Date()
//        
//        try? context.save()
//    }
    
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
    
    
    func title(at indexPath: IndexPath) throws -> String {
        
        guard let numberOfRows = fetchedResultController.fetchedObjects?.count,
              indexPath.row < numberOfRows else {
            throw CoreDataErrors.sectionOutOfRange(index: indexPath.section)
        }
        
        let categoryData = fetchedResultController.object(at: indexPath)
        
        guard let title = categoryData.categoryTitle else {
            throw CoreDataErrors.categoryConversionError
        }
          
        return title
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
