import CoreData
import UIKit

// MARK: - TrackerStoreUpdate

struct TrackerStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
}

// MARK: - Protocols

protocol DataProviderProtocol {
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

// MARK: - TrackerDataProvider

final class TrackerDataProvider: NSObject {
    
    // MARK: - Init
    
    init(delegate: DataProviderDelegate) {
        self.delegate = delegate
        super.init()
        self.filterByDate(Calendar.current.startOfDay(for: Date()))
    }
    
    // MARK: - Delegate
    
    weak var delegate: DataProviderDelegate?
    
    // MARK: - Private Properties
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?
    private let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var sectionsChanged: Bool = false
    
    private lazy var trackerStore: TrackerStore = {
        return TrackerStore(context: context)
    }()
    
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
    
    // MARK: - Private Methods
    
    private func convertToTracker(_ record: TrackerCoreData) -> Tracker? {
        guard let title = record.title,
              let emoji = record.emoji,
              let color = record.color,
              let category = record.category,
              let id = record.id else { return nil}
        
        let schedule = WeekDay.fromBitmask(UInt8(record.schedule))
        
        return Tracker(
            id: id,
            title: title,
            color: color as? UIColor ?? UIColor.colorSelection1,
            emoji: emoji,
            schedule: Set(schedule),
            category: TrackerCategory(categoryTitle: category.categoryTitle ?? "")
        )
    }
}

// MARK: - DataProviderProtocol

extension TrackerDataProvider: DataProviderProtocol {
    
    var numberOfSections: Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) throws -> Tracker {
        guard let sections = fetchedResultController.sections else {
            throw DataProviderErrors.noSectionsAvailable
        }
        
        guard indexPath.section < sections.count else {
            throw DataProviderErrors.sectionOutOfRange(index: indexPath.section)
        }
        
        let section = sections[indexPath.section]
        
        guard indexPath.row < section.numberOfObjects else {
            throw DataProviderErrors.rowOutOfRange(index: indexPath.row)
        }
        
        let trackerData = fetchedResultController.object(at: indexPath)
        
        guard let tracker = convertToTracker(trackerData) else {
            throw DataProviderErrors.trackerConversionError
        }
                
        return tracker
    }
    
    func addRecord(_ record: Tracker) throws {
        try? trackerStore.add(record)
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
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = NSPredicate(format: "(schedule & %d != 0) OR (schedule == 0 AND createdAt >= %@ AND createdAt < %@)", dayMask, startOfDay as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! as NSDate)
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

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        sectionsChanged = false
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        if !sectionsChanged {
            delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!)
            )
        }
        insertedIndexes?.removeAll()
        deletedIndexes?.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard !sectionsChanged else { return }
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath)
            }
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        sectionsChanged = true
        switch type {
        case .delete:
            delegate?.deleteSections(IndexSet(integer: sectionIndex))
        case .insert:
            delegate?.insertSections(IndexSet(integer: sectionIndex))
        default:
            break
        }
    }
}
