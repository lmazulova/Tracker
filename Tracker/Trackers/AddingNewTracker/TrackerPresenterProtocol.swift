import Foundation

protocol TrackerPresenterProtocol: AnyObject {
    func cancelingTrackerCreation()
    func addTracker(_ tracker: Tracker)
}
