import CoreData
import Foundation

class TrackerStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = MainCoreData.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.title = tracker.title
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.compactMap { $0.rawValue }
        trackerCoreData.color = tracker.color.hexString
    }
    
    func fetchTracker() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(fetchRequest)
        return try trackersFromCoreData.map { try self.tracker(from: $0) }
        
    }
    
    func tracker(from data: TrackerCoreData) throws -> Tracker {
        guard let title = data.title else { throw MainCoreDataEror.Error }
        
        guard let uuid = data.id else { throw MainCoreDataEror.Error }
        
        guard let emoji = data.emoji else { throw MainCoreDataEror.Error }
        
        guard let color = data.color else { throw MainCoreDataEror.Error }
        
        guard let schedule = data.schedule else { throw MainCoreDataEror.Error }
        
        return Tracker(id: uuid,
                       title: title,
                       color: color.color,
                       emoji: emoji,
                       schedule: schedule.compactMap { WeekDay(rawValue: $0)}
                       )
    }
    
}
