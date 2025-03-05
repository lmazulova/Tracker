import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule
}

struct Schedule {
    let Monday: Bool
    let Tuesday: Bool
    let Wednesday: Bool
    let Thursday: Bool
    let Friday: Bool
    let Saturday: Bool
    let Sunday: Bool
}

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
