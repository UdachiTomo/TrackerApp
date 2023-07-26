import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func createCategory(category: TrackerCategory)
}

final class CategoriesViewModel: NSObject, TrackerCategoryStoreDelegate {
    
    var onChange: (() -> Void)?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onChange?()
        }
    }
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private(set) var selectedCategory: TrackerCategory?
    weak var delegate: CategoriesViewModelDelegate?
    
    init(delegate: CategoriesViewModelDelegate?, selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        self.delegate = delegate
        super.init()
        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        try? self.trackerCategoryStore.deleteCategory(category)
        print(category)
    }
    
    func selectCategory(with title: String) {
        let category = TrackerCategory(title: title, trackers: [])
        delegate?.createCategory(category: category)
        print(category)
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        onChange?()
    }
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.trackerCategories
        print(categories)
    }
}

