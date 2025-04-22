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
    let insertedIndexes: Set<IndexPath>
    let deletedIndexes: Set<IndexPath>
}


