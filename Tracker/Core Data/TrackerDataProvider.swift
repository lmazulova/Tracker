import CoreData
import UIKit

struct TrackerStoreUpdate {
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> Tracker?
    func addRecord(_ record: Tracker) throws
    func filterByDate(_ date: Date) throws
    func filterByTitle(_ title: String) throws
    func titleForSection(_ section: Int) -> String?
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func deleteSections(_ indexSet: IndexSet)
    func insertSections(_ indexSet: IndexSet)
}

final class TrackerDataProvider: NSObject {
    
    init(delegate: DataProviderDelegate) {
        self.delegate = delegate
    }
    
    weak var delegate: DataProviderDelegate?
    
    private var insertedIndexes: Set<IndexPath>?
    private var deletedIndexes: Set<IndexPath>?
    private let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
            color: color as! UIColor,
            emoji: emoji,
            schedule: Set(schedule),
            category: TrackerCategory(categoryTitle: category.categoryTitle ?? "")
        )
    }
   
}

extension TrackerDataProvider: DataProviderProtocol {
    
    var numberOfSections: Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerRecord = fetchedResultController.object(at: indexPath)
        
        let tracker = convertToTracker(trackerRecord)
        
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
    func filterByDate(_ date: Date) throws {
        let weekDays: [WeekDay] = [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
        
        let selectedWeekDay = weekDays[Calendar.current.component(.weekday, from: date) - 1].bitValue
        let dayMask = Int16(selectedWeekDay)
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = NSPredicate(format: "(schedule & %d != 0) OR (schedule == nil AND createdAt >= %@ AND createdAt < %@)", dayMask, startOfDay as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! as NSDate)
        
        fetchedResultController.fetchRequest.predicate = predicate
        
        try? fetchedResultController.performFetch()
    }
    
    func filterByTitle(_ title: String) throws {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        
        fetchedResultController.fetchRequest.predicate = predicate
        
        try? fetchedResultController.performFetch()
    }
}

extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes?.removeAll()
        deletedIndexes?.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath)
            }
        case .insert:
            if let indexPath = indexPath {
                insertedIndexes?.insert(indexPath)
            }
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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
