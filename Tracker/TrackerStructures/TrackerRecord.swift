import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
    
    init(id: UUID, date: Date) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
    }
}
