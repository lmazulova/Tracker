import Foundation

enum CoreDataErrors: Error {
    case objectNotFound
    case noSectionsAvailable
    case sectionOutOfRange(index: Int)
    case rowOutOfRange(index: Int)
    case trackerConversionError
    case nilResult
    case categoryConversionError
}
