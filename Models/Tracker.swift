import UIKit

struct Tracker: Hashable {
    let id: UUID 
    let title: String
    let color: UIColor?
    let emoji: String?
    let schedule: [WeekDay]?
    let pinned: Bool?
    var category: TrackerCategory? {
        return TrackerCategoryStore().category(forTracker: self)
    }
}
