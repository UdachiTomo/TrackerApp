import UIKit

struct Tracker {
    let id: UUID 
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
    let pinned: Bool?
    var category: TrackerCategory? {
        return TrackerCategoryStore().category(forTracker: self)
    }
}
