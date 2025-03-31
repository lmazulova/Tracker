import CoreData
import UIKit

// MARK: - TrackerStore

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Private Methods
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
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
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = Int16(WeekDay.toBitmask(days: Array(schedule)))
        }
    }
    
    // MARK: - Public Methods
    
    func add(_ record: Tracker) throws {
        try performSync { context in
            Result {
                try convertToTrackerCoreDataAndSave(record, with: context)
                try context.save()
            }
        }
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - TrackerCategoryStore

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Private Methods
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait{
            guard let coordinator = self.context.persistentStoreCoordinator else { return }
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    // MARK: - Public Methods
    
    func setupRecords() {
        let checkRequest = TrackerCategoryCoreData.fetchRequest()
        guard let result = try? context.fetch(checkRequest),
           result.isEmpty
        else {
            return
        }
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.categoryTitle = "Важное"
        
        try! context.save()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

// MARK: - TrackerRecordStore

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    // MARK: - Private Methods
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    // MARK: - Public Methods
    
    func changeState(for record: TrackerRecord) throws {
        try performSync { context in
            Result {
                let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                trackerRecordFetch.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate)
                
                let results = try context.fetch(trackerRecordFetch)
                if results.isEmpty {
                    let trackerRecord = TrackerRecordCoreData(context: context)
                    trackerRecord.id = record.id
                    trackerRecord.date = record.date
                }
                else {
                    results.forEach { result in
                        context.delete(result)
                    }
                }
                try context.save()
            }
        }
    }
    
    func trackerIsCompleted(_ record: TrackerRecord) -> Bool {
        do {
            return try performSync { context in
                Result {
                    let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                    trackerRecordFetch.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate)
                    let result = try context.fetch(trackerRecordFetch)
                    
                    if result.isEmpty {
                        return false
                    }
                    else {
                        return true
                    }
                }
            }
        }
        
        catch {
            return false
        }
    }
    func amountOfRecords(for id: UUID) -> Int {
        do {
            return try performSync { context in
                Result {
                    let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                    trackerRecordFetch.resultType = .countResultType
                    
                    trackerRecordFetch.predicate = NSPredicate(format: "id == %@", id as NSUUID)
                    let result = try context.count(for: trackerRecordFetch)
                    return result
                }
            }
        }
        catch {
            print("Ошибка при подсчете записей: \(error.localizedDescription)")
            return 0
        }
    }
}
