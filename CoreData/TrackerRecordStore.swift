import CoreData
import Foundation

class TrackerRecordStore {
    private let context: NSManagedObjectContext
    static let shared = TrackerRecordStore()
    
    convenience init() {
        let context = MainCoreData.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with record: TrackerRecord) {
        trackerRecordCoreData.id = record.trackerId
        trackerRecordCoreData.date = record.date
    }
    
    func fetchTrackerRecord() throws -> [TrackerRecord] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let trackerRecordFromCoreData = try context.fetch(fetchRequest)
        return try trackerRecordFromCoreData.map { try self.trackerRecord(from: $0) }
    }
    
    func trackerRecord(from data: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = data.id else { throw MainCoreDataError.error }
        guard let date = data.date else { throw MainCoreDataError.error }
        return TrackerRecord(
            trackerId: id,
            date: date
        )
    }
}
