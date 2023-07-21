import UIKit

final class TrackersViewController: UIViewController, UITextFieldDelegate, ChooseTypeOfTrackerControllerProtocol, TrackerCategoryStoreDelegate {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var categories: [TrackerCategory] = []
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var isCompletedToday: Bool = true
    private var trackerId: UUID? = nil
    private var currentDate: Int?
    private var searchText: String = ""
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var trackerLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.text = "Трекеры"
        trackerLabel.textColor = .ypBlack
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
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
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
    
    private lazy var plugLabel: UILabel = {
        let plugLabel = UILabel()
        plugLabel.text = "Что будем отслеживать?"
        plugLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        plugLabel.textColor = .ypBlack
        return plugLabel
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
    
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            updateCategories()
        }
    }
    
    @objc func textFieldChanged() {
        searchText = searchTrackerField.text ?? ""
        plugImage.image = searchText.isEmpty ? UIImage(named: "plug_image") : UIImage(named: "error")
        plugLabel.text = searchText.isEmpty ? "Что будем отслеживать?" : "Ничего не найдено"
        visibleCategories = trackerCategoryStore.predicateFetch(title: searchText)
        updateCategories()
    }
    
    private func updateVisibleCategories(_ newCategory: [TrackerCategory]) {
        visibleCategories = newCategory
        trackersCollectionView.reloadData()
    }
    
    private func setDayOfWeek() {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        currentDate = components.weekday
    }
    
    private func addView() {
        [trackerLabel, plugImage, plugLabel, searchTrackerField, datePicker,plusTrackerButton, trackersCollectionView].forEach(view.setupView(_:))
    }
    
    private func updateCategories() {
        var newCategories: [TrackerCategory] = []
        visibleCategories = trackerCategoryStore.trackerCategories
        for category in visibleCategories {
            var newTrackers: [Tracker] = []
            for tracker in category.trackers {
                guard let schedule = tracker.schedule else { return }
                let scheduleInts = schedule.map { $0.numberOfDay }
                if let day = currentDate, scheduleInts.contains(day) &&  (searchText.isEmpty || tracker.title.contains(searchText)) {
                    newTrackers.append(tracker)
                }
            }
            if newTrackers.count > 0 {
                let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(newCategory)
            }
        }
        visibleCategories = newCategories
        trackersCollectionView.reloadData()
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
            plugLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            searchTrackerField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTrackerField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTrackerField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTrackerField.heightAnchor.constraint(equalToConstant: 36),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 91),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.topAnchor.constraint(equalTo: searchTrackerField.bottomAnchor, constant: 24),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    func createTracker(_ tracker: Tracker, categoryTitle: String) {
        var categoryToUpdate: TrackerCategory?
        let categories: [TrackerCategory] = trackerCategoryStore.trackerCategories
        for i in 0..<categories.count {
            if categories[i].title == categoryTitle {
                categoryToUpdate = categories[i]
            }
        }
        if categoryToUpdate != nil {
            try? trackerCategoryStore.addTracker(tracker, to: categoryToUpdate!)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categoryToUpdate = newCategory
            try? trackerCategoryStore.addNewTrackerCategory(categoryToUpdate!)
        }
        updateCategories()
    }
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.trackerCategories
        trackersCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        applyConstraints()
        setNavBar()
        setDayOfWeek()
        updateCategories()
        do {
            completedTrackers = try self.trackerRecordStore.fetchTrackerRecord()
        } catch {
            fatalError("")
        }
        trackerCategoryStore.delegate = self
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.trackerId == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(TrackerRecord(trackerId: id, date: datePicker.date))
        } else {
            completedTrackers.append(TrackerRecord(trackerId: id, date: datePicker.date))
            try? trackerRecordStore.addNewTrackerRecord(TrackerRecord(trackerId: id, date: datePicker.date))
        }
        trackersCollectionView.reloadData()
    }
}

extension TrackersViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTrackerField.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTrackerField.text = ""
        updateCategories()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchTextField = textField.text else { return }
        searchText = searchTextField
        updateCategories()
    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visibleCategories.count
        collectionView.isHidden = count == 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        let tracker =  visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        let isCompleted = completedTrackers.contains(where: { record in
            record.trackerId == tracker.id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        })
        let isEnabled = datePicker.date < Date() || Date().yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        let completedCount = completedTrackers.filter({ record in
            record.trackerId == tracker.id
        }).count
        cell.configure(
            tracker.id,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            isCompleted: isCompleted,
            isEnabled: isEnabled,
            completedCount: completedCount
        )
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
        view.titleLabel.text = visibleCategories[indexPath.section].title
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
