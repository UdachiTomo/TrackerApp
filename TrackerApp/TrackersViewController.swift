import UIKit

class MockData {
    static var categories: [TrackerCategory] = [
        TrackerCategory(title: "Важное", trackers: [
            Tracker(id: UUID(), title: "Сходить в магазин", color: .color1, emoji: "🏝", schedule: [.wednesday, .saturday]),
            Tracker(id: UUID(), title: "Сделать дубликат ключа", color: .color2, emoji: "🙂", schedule: [.monday, .saturday, .wednesday, .friday, .sunday, .thursday,.tuesday])
        ])]
}

final class TrackersViewController: UIViewController, UITextFieldDelegate, ChooseTypeOfTrackerControllerProtocol {
    func createTracker(_ tracker: Tracker, categoryTitle: String) {
        let newTracker = TrackerCategory(title: categoryTitle, trackers: [tracker])
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let array = categories[index].trackers + newTracker.trackers
            let trackerCategory = TrackerCategory(title: categoryTitle, trackers: array)
            categories[index] = trackerCategory
        } else {
            categories.append(newTracker)
        }
        visibleCategories = categories
        updateVisibleCategories(visibleCategories)
        trackersCollectionView.reloadData()
        
    }
    
    private var categories: [TrackerCategory] = [] //MockData.categories
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord]? = []
    private var visibleCategories: [TrackerCategory] = []
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    private var currentDate: Int?
    private var searchText: String = ""
    
    private lazy var trackerLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.text = "Трекеры"
        trackerLabel.textColor = .black
        trackerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return trackerLabel
    } ()
    
    private lazy var plusTrackerButton: UIButton = {
        let plustTrackerButton = UIButton()
        plustTrackerButton.setImage(UIImage(named: "plus"), for: .normal)
        plustTrackerButton.addTarget(self, action: #selector(createNewTrackers), for: .touchUpInside)
        return plustTrackerButton
    } ()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    } ()
    
    private lazy var searchTrackerField: UISearchTextField = {
        let searchTrackerField = UISearchTextField()
        searchTrackerField.placeholder = "Поиск"
        searchTrackerField.layer.cornerRadius = 10
        searchTrackerField.layer.masksToBounds = true
        searchTrackerField.delegate = self
        searchTrackerField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return searchTrackerField
    } ()
    
    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView()
        plugImage.image = UIImage(named: "plug_image")
        return plugImage
    } ()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSupplementaryView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    @objc private func createNewTrackers() {
        let viewController = ChooseTypeOfTrackerController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func updateVisibleCategories(_ newCategory: [TrackerCategory]) {
        visibleCategories = newCategory
        trackersCollectionView.reloadData()
    }
    
    private func addView() {
        [trackerLabel, plugImage, searchTrackerField, datePicker,plusTrackerButton, trackersCollectionView].forEach(view.setupView(_:))
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        guard let completedTrackers = completedTrackers else { return false }
        return completedTrackers.contains { trackerRecord in
            let sameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerId == id && sameDay
        }
    }
    
   @objc func filterTrackers(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let date = components.weekday {
            currentDate = date
            trackersCollectionView.reloadData()
        }
        
    }
    
    @objc func textFieldChanged() {
        guard let textField = searchTrackerField.text else { return }
        let categories = visibleCategories
        let newCategories = searchTracker(categories: categories, text: textField)
        updateVisibleCategories(newCategories)
    }
    
    func searchTracker(categories: [TrackerCategory], text: String) -> [TrackerCategory] {
        var newCategories: [TrackerCategory] = []
        
        for category in categories {
            var newCategory = TrackerCategory(title: category.title, trackers: [])
            
            for tracker in category.trackers {
                if tracker.title.contains(text) {
                    newCategory.trackers.append(tracker)
                }
            }
            if !newCategory.trackers.isEmpty {
                newCategories.append(newCategory)
            }
        }
        
        return newCategories
    }
    
    private func setNavBar() {
        let plusTrackerButton = UIBarButtonItem(customView: plusTrackerButton)
        let datePicker = UIBarButtonItem(customView: datePicker)
        self.navigationItem.leftBarButtonItem = plusTrackerButton
        self.navigationItem.rightBarButtonItem = datePicker
    }
    
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            searchTrackerField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTrackerField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTrackerField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 91),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.topAnchor.constraint(equalTo: searchTrackerField.bottomAnchor, constant: 10),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        applyConstraints()
        setNavBar()
        updateVisibleCategories(visibleCategories)
    }
}

extension TrackersViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTrackerField.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {

    func completedTracker(id: UUID, indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: id, date: datePicker.date)
        completedTrackers?.append(trackerRecord)
        trackersCollectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers?.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date , inSameDayAs: datePicker.date)
            return trackerRecord.trackerId == id && isSameDay
        }
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = categories.count
        collectionView.isHidden = count == 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        let tracker =  categories[indexPath.section].trackers[indexPath.row]
        guard let days = completedTrackers else { return UICollectionViewCell() }
        cell.delegate = self
        cell.bringSubviewToFront(cell.checkButton)
        let isCompleted = isTrackerCompletedToday(id: tracker.id)
        let completedCount = days.filter { $0.trackerId == tracker.id}.count
        cell.setupCell(tracker: tracker, isCompleted: isCompleted, completedCount: completedCount, indexPath: indexPath)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackersSupplementaryView else { return UICollectionReusableView() }
        view.titleLabel.text = categories[indexPath.section].title
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
