import CoreData
import Foundation

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store( _ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    enum TrackerCategoryStoreError: Error {
        case failedToInitializeContext
    }
    
    
    private let trackerStore = TrackerStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    weak var delegate: TrackerCategoryStoreDelegate?
    static let shared = TrackerCategoryStore()
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackerCategories = try? objects.map({ try self.trackerCategory(from: $0)})
        else { return [] }
        return trackerCategories
    }
    
    convenience override init() {
        let context = MainCoreData.shared.context
        do {
            try self.init(context: context)
        } catch {
            fatalError("Initialiser is hidden!")
        }
        
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titleCategory, ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest:
                                                        fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingTrackerCategory(trackerCategoryCoreData, with: trackerCategory)
        try context.save()
    }
    
    func deleteCategory(_ categoryToDelete: TrackerCategory) throws {
        let category = fetchedResultsController?.fetchedObjects?.first {
            $0.titleCategory == categoryToDelete.title
        }
        if let category = category {
            context.delete(category)
            try context.save()
        }
    }
    
    func updateExistingTrackerCategory(
        _ trackerCategoryCoreData: TrackerCategoryCoreData,
        with category: TrackerCategory)
    {
        trackerCategoryCoreData.titleCategory = category.title
        for tracker in category.trackers {
            let track = TrackerCoreData(context: context)
            track.id = tracker.id
            track.title = tracker.title
            track.color = tracker.color.hexString
            track.emoji = tracker.emoji
            track.schedule = tracker.schedule?.compactMap { $0.rawValue }
            trackerCategoryCoreData.addToTrackers(track)
        }
    }
    
    func addTracker(_ tracker: Tracker, to trackerCategory: TrackerCategory) throws {
        let category = fetchedResultsController?.fetchedObjects?.first {
            $0.titleCategory == trackerCategory.title
        }
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.title = tracker.title
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.compactMap { $0.rawValue }
        trackerCoreData.color = tracker.color.hexString
        
        category?.addToTrackers(trackerCoreData)
        try context.save()
    }
    
    func trackerCategory(from data: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = data.titleCategory else {
            throw TrackerCategoryStoreError.failedToInitializeContext
        }
        let trackers: [Tracker] = data.trackers?.compactMap { tracker in
            guard let trackerCoreData = (tracker as? TrackerCoreData) else { return nil }
            guard let id = trackerCoreData.id,
                  let title = trackerCoreData.title,
                  let color = trackerCoreData.color?.color,
                  let emoji = trackerCoreData.emoji else { return nil }
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: trackerCoreData.schedule?.compactMap { WeekDay(rawValue: $0) }
            )
        } ?? []
        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }
    
    func predicateFetch(title: String) -> [TrackerCategory] {
        if title.isEmpty {
            return trackerCategories
        } else {
            let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "ANY trackers.title CONTAINS[cd] %@", title)
            guard let trackerCategoriesCoreData = try? context.fetch(request) else { return [] }
            guard let categories = try? trackerCategoriesCoreData.map({ try self.trackerCategory(from: $0)})
            else { return [] }
            return categories
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: [],
                deletedIndexes: [],
                updatedIndexes: [],
                movedIndexes: []
            )
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
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
