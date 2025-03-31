import Foundation

enum DataProviderErrors: Error {
    case objectNotFound
    case noSectionsAvailable
    case sectionOutOfRange(index: Int)
    case rowOutOfRange(index: Int)
    case trackerConversionError
}
