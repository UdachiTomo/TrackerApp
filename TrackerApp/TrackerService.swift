import UIKit

protocol TrackerServiceDelegate: AnyObject {
    func addTrackers(trackersCategory: TrackerCategory)
}

final class TrackerService {
    static var shared = TrackerService()
    weak var delegate: TrackerServiceDelegate?
    
    var categoryTitle: String = ""
    var category: [Category] = []
    var trackers: [Tracker] = []
    //var schedule: [WeekDay] = []
    
    func createTracker(title: String, schedule: [WeekDay], categoryTitle: String) {
        let tracker = TrackerCategory(title: categoryTitle,
                                      trackers: [Tracker(id: UUID(),
                                                         title: title,
                                                         color: .color1,
                                                         emoji: "🙂",
                                                         schedule: schedule)])
        delegate?.addTrackers(trackersCategory: tracker)
        print(tracker)
    }
}
