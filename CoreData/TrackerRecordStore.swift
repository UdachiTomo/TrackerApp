import CoreData
import Foundation

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes = [IndexSet]()
    let deletedIndexes = [IndexSet]()
    let updatedIndexes = [IndexSet]()
    let movedIndexes = Set<Move>()
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate update: TrackerRecordStoreUpdate
    )
}

class TrackerRecordStore: NSObject {
    private weak var delegate: TrackerRecordStoreDelegate?
    private let context: NSManagedObjectContext
    static let shared = TrackerRecordStore()
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    var trackerRecords: [TrackerRecord] {
        guard let objects = self.fetchedResultsController?.fetchedObjects, let trackerRecords = try? objects.map({ try self.trackerRecord(from: $0)})
        else { return [] }
        return trackerRecords
    }
    
    convenience override init() {
        let context = MainCoreData.shared.context
        self.init(context: context)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            assertionFailure("TrackerRecordStore fetch failed")
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func deleteTrackerRecord(with id: UUID, date: Date) throws {
        let trackerRecordCoreData = fetchedResultsController?.fetchedObjects?.first {
            $0.id == id &&
            $0.date?.yearMonthDayComponents == date.yearMonthDayComponents
        }
        if let trackerRecord = trackerRecordCoreData {
            context.delete(trackerRecord)
            try context.save()
        }
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
        guard let id = data.id,
              let date = data.date else { throw MainCoreDataError.error }
        return TrackerRecord(
            trackerId: id,
            date: date
        )
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            insertedIndexes = IndexSet()
            deletedIndexes = IndexSet()
            updatedIndexes = IndexSet()
            movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
        }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.store(
                self,
                didUpdate: TrackerRecordStoreUpdate()
            )
            insertedIndexes = nil
            deletedIndexes = nil
            updatedIndexes = nil
            movedIndexes = nil
        }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else {
                assertionFailure("insert indexPath - nil")
                return
            }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else {
                assertionFailure("delete indexPath - nil")
                return
            }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else {
                assertionFailure("update indexPath - nil")
                return
            }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {
                assertionFailure("move indexPath - nil")
                return
            }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            assertionFailure("unknown case")
        }
    }
}
