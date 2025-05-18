import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: - Init
    static let shared = TrackerRecordStore()
    weak var delegate: StatisticsViewController?
    
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override convenience init() {
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
        DispatchQueue.main.async {
            self.delegate?.updateUI()
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
    
    func numberOfCompletedTrackers() -> Int {
        do {
            return try performSync { context in
                Result {
                    let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                    trackerRecordFetch.resultType = .countResultType
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
    
    func completedTrackersId(date: Date) -> [UUID]? {
        do {
            return try performSync { context in
                Result {
                    let currentDate = Calendar.current.startOfDay(for: date)
                    let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                    trackerRecordFetch.predicate = NSPredicate(format: "date == %@", currentDate as NSDate)
                    let result = try context.fetch(trackerRecordFetch)
                    
                    if result.isEmpty {
                        return nil
                    }
                    else {
                        return result.compactMap { record in
                            guard let id = record.id else { return nil }
                            return id
                        }
                    }
                }
            }
        }
        
        catch {
            print("[\(#function)] - Ошибка нахождения записей: \(error.localizedDescription)")
            return nil
        }
    }
}

