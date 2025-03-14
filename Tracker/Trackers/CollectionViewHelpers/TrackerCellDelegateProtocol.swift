import Foundation

protocol TrackerCellDelegate: AnyObject {
    func updateCompletedTrackers(for id: UUID)
}
