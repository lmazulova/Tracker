import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>?
    let category: TrackerCategory
    let isPinned: Bool
    let originalCategoryID: UUID?
    
    init(id: UUID = UUID(), title: String, color: UIColor, emoji: String, schedule: Set<WeekDay>?, category: TrackerCategory, isPinned: Bool = false, originalCategory: UUID? = nil) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.category = category
        self.isPinned = isPinned
        self.originalCategoryID = originalCategory
    }
}

enum WeekDay: String, CaseIterable {
    case Monday = "Понедельник"
    case Tuesday = "Вторник"
    case Wednesday = "Среда"
    case Thursday = "Четверг"
    case Friday = "Пятница"
    case Saturday = "Суббота"
    case Sunday = "Воскресенье"
    
    var bitValue: UInt8 {
        switch self {
        case .Monday: return 0b1000000
        case .Tuesday: return 0b0100000
        case .Wednesday: return 0b0010000
        case .Thursday: return 0b0001000
        case .Friday: return 0b0000100
        case .Saturday: return 0b0000010
        case .Sunday: return 0b0000001
        }
    }
    
    static func fromBitmask(_ mask: UInt8) -> [WeekDay] {
        return allCases.filter { day in
            mask & day.bitValue != 0
        }
    }
    
    static func toBitmask(days: [WeekDay]) -> UInt8 {
        return days.reduce(0) { $0 | $1.bitValue }
    }
}
