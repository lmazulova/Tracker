import CoreData
import UIKit

protocol TrackerDataProviderProtocol: AnyObject {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) throws -> Tracker
    func addRecord(_ record: Tracker) throws
    func filterByDate(_ date: Date)
    func filterByTitle(_ title: String)
    func titleForSection(_ section: Int) -> String?
    func deleteTracker(with id: UUID)
    func pinTracker(with id: UUID)
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func collectionFullReload()
}

final class TrackerStore: NSObject {
    
    static let shared = TrackerStore()
    
    let context: NSManagedObjectContext
    
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
    
    // MARK: - Private Properties
    
    private var trackerStoreUpdate = TrackerStoreUpdate(
        insertedSections: IndexSet(),
        deletedSections: IndexSet(),
        insertedIndexes: [],
        deletedIndexes: []
    )
    weak var delegate: DataProviderDelegate?
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        fetchResultController.delegate = self
        
        try? fetchResultController.performFetch()
        
        return fetchResultController
    }()
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        filterByDate(Calendar.current.startOfDay(for: Date()))
    }

    convenience override init() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            self.init(context: context)
        } else {
            fatalError("[\(#function)] - Unable to initialize Core Data context")
        }
    }
    
    // MARK: - Private Methods
    
    private func convertToTracker(_ record: TrackerCoreData) -> Tracker? {
        guard let title = record.title,
              let emoji = record.emoji,
              let color = record.color,
              let category = record.category,
              let id = record.id
        else { return nil}
                
        let schedule = WeekDay.fromBitmask(UInt8(record.schedule))
        
        return Tracker(
            id: id,
            title: title,
            color: color as? UIColor ?? UIColor.colorSelection1,
            emoji: emoji,
            schedule: Set(schedule),
            category: TrackerCategory(categoryTitle: category.categoryTitle ?? "", id: category.id ?? UUID()),
            isPinned: record.isPinned,
            originalCategory: record.originalCategoryID
        )
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait{
            guard let coordinator = self.context.persistentStoreCoordinator else { return }
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    private func findCategory(by title: String, in context: NSManagedObjectContext) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "categoryTitle == %@", title)
        
        let category = try? context.fetch(request)
        return category?.first
    }
    
    private func convertToTrackerCoreDataAndSave(_ tracker: Tracker, with context: NSManagedObjectContext) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.category = try? findCategory(by: tracker.category.categoryTitle, in: context)
        trackerCoreData.color = tracker.color
        trackerCoreData.createdAt = Date()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.title = tracker.title
        trackerCoreData.id = tracker.id
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.originalCategoryID = tracker.originalCategoryID
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = Int16(WeekDay.toBitmask(days: Array(schedule)))
        }
    }

    // MARK: - Deinitialization
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - DataProviderProtocol

extension TrackerStore: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) throws -> Tracker {
        guard let sections = fetchedResultController.sections else {
            throw CoreDataErrors.noSectionsAvailable
        }
        
        guard indexPath.section < sections.count else {
            throw CoreDataErrors.sectionOutOfRange(index: indexPath.section)
        }
        
        let section = sections[indexPath.section]
        
        guard indexPath.row < section.numberOfObjects else {
            throw CoreDataErrors.rowOutOfRange(index: indexPath.row)
        }
        
        let trackerData = fetchedResultController.object(at: indexPath)
        
        guard let tracker = convertToTracker(trackerData) else {
            throw CoreDataErrors.trackerConversionError
        }
                
        return tracker
    }
    
    func pinTracker(with id: UUID) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        do {
            let object = try context.fetch(fetchRequest)
            guard let tracker = object.first else { return }
            
            if tracker.isPinned {
                tracker.isPinned = false
                guard let categoryID = tracker.originalCategoryID else {
                    print("[\(#function)] - Отсутствует предыдущая категория.")
                    return
                }
                let request = TrackerCategoryCoreData.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", categoryID as NSUUID)
                
                guard let previousCategory = try? context.fetch(request).first else {
                    print("[\(#function)] - Не удалось найти предыдущую категорию")
                    return
                }
                tracker.category = previousCategory
            }
            else {
                tracker.isPinned = true
                if tracker.originalCategoryID == nil {
                    tracker.originalCategoryID = tracker.category?.id
                }
                
                let request = TrackerCategoryCoreData.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", PinnedCategory.id as NSUUID)
                guard let pinnedCategory = try context.fetch(request).first else {
                    print("[\(#function)] - Не найдена категория для закрепленияю.")
                    return
                }
                tracker.category = pinnedCategory
            }
            try context.save()
        }
        catch {
            print("[\(#function)] - Не получилось закрепить трекер.")
        }
    }
    
    func deleteTracker(with id: UUID) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as NSUUID)
        fetchRequest.predicate = predicate
        do {
            let object = try context.fetch(fetchRequest)
            if let tracker = object.first {
                context.delete(tracker)
            }
            
            try context.save()
            
        }
        catch {
            print("[\(#function)] - ошибка удаления трекера.")
        }
    }
    
    func addRecord(_ record: Tracker) throws {
        try performSync { context in
            Result {
                try convertToTrackerCoreDataAndSave(record, with: context)
                try context.save()
            }
        }
    }
    
    func titleForSection(_ section: Int) -> String? {
        guard let sections = fetchedResultController.sections, section < sections.count else {
            return nil
        }
        let sectionInfo = sections[section]
        if let trackerCoreData = sectionInfo.objects?.first as? TrackerCoreData {
            return trackerCoreData.category?.categoryTitle
        }
        
        return nil
    }
    
    func filterByDate(_ date: Date) {
        let weekDays: [WeekDay] = [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
        
        let selectedWeekDay = weekDays[Calendar.current.component(.weekday, from: date) - 1].bitValue
        let dayMask = Int16(selectedWeekDay)
        let startOfDay = Calendar.current.startOfDay(for: date) as NSDate
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay as Date) as? NSDate else {
            print("[\(#function)] - ошибка фильтрации.")
            return
        }
        
        let predicate = NSPredicate(format: "(schedule & %d != 0) OR (schedule == 0 AND createdAt >= %@ AND createdAt < %@)", dayMask, startOfDay, endOfDay)
        fetchedResultController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultController.performFetch()
            DispatchQueue.main.async {
                self.delegate?.collectionFullReload()
            }
        }
        catch {
            print("[\(#function)] - ошибка фильтрации.")
        }
    }
    
    func filterByTitle(_ title: String) {
        
        let predicate = title.isEmpty ? nil : NSPredicate(format: "title CONTAINS[cd] %@", title)
        
        fetchedResultController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultController.performFetch()
            DispatchQueue.main.async {
                self.delegate?.collectionFullReload()
            }
        }
        catch {
            print("[\(#function)] - ошибка фильтрации")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        trackerStoreUpdate = TrackerStoreUpdate(
            insertedSections: IndexSet(),
            deletedSections: IndexSet(),
            insertedIndexes: [],
            deletedIndexes: []
        )
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        delegate?.didUpdate(trackerStoreUpdate)
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                trackerStoreUpdate.deletedIndexes.insert(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                trackerStoreUpdate.insertedIndexes.insert(indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                trackerStoreUpdate.deletedIndexes.insert(indexPath)
            }
            if let newIndexPath = newIndexPath {
                trackerStoreUpdate.insertedIndexes.insert(newIndexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            trackerStoreUpdate.deletedSections.insert(sectionIndex)
        case .insert:
            trackerStoreUpdate.insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
}
