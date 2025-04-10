import UIKit
import CoreData

final class TrackerRecordStore: BaseStore {
    
    // MARK: - Init
    
    override init(context: NSManagedObjectContext) {
        super.init(context: context)
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

