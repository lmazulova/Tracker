import Foundation

struct TrackerCategory {
    let categoryTitle: String
    let id: UUID
}

//Параметры категории, которая будет отображаться как закрепленная
enum PinnedCategory {
    static let id = UUID(uuidString: "5E04D630-DFD0-420D-8F1F-9C9933C7C7F5")!
    static let title = "Закреплённое"
}


