
import Foundation


protocol TrackerPresenterProtocol: AnyObject {
    func cancelingTrackerCreation()
    func addTracker(for category: TrackerCategory)
}
