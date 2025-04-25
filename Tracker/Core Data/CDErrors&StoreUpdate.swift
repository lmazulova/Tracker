import Foundation

// MARK: - CoreDataErrors

enum CoreDataErrors: Error {
    case objectNotFound
    case noSectionsAvailable
    case sectionOutOfRange(index: Int)
    case rowOutOfRange(index: Int)
    case trackerConversionError
    case nilResult
    case categoryConversionError
}

// MARK: - TrackerStoreUpdate

struct TrackerStoreUpdate {
    var insertedSections: IndexSet
    var deletedSections: IndexSet
    var insertedIndexes: Set<IndexPath>
    var deletedIndexes: Set<IndexPath>
}


