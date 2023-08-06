import UIKit

final class TrackersViewController: UIViewController, UITextFieldDelegate {
    
    private let analyticsService = AnalyticsService()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let colors = Colors()
    private var pinnedTrackers: [Tracker] = []
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var isCompletedToday: Bool = true
    private var currentDate: Int?
    private var searchText: String = ""
    private var selectedFilter: Filter?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private lazy var trackerLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.text = NSLocalizedString("trackers", tableName: "LocalizableString", comment: "")
        trackerLabel.textColor = .ypBlack
        trackerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return trackerLabel
    }()
    
    private lazy var plusTrackerButton: UIButton = {
        let plustTrackerButton = UIButton()
        plustTrackerButton.setImage(UIImage(named: "plus"), for: .normal)
        plustTrackerButton.tintColor = .ypBlack
        plustTrackerButton.addTarget(self, action: #selector(createNewTrackers), for: .touchUpInside)
        return plustTrackerButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .datePickerColor
        datePicker.tintColor = .ypBlue
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
        datePicker.layer.masksToBounds = true
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchTrackerField: UISearchTextField = {
        let searchTrackerField = UISearchTextField()
        searchTrackerField.placeholder = "Поиск"
        searchTrackerField.layer.cornerRadius = 10
        searchTrackerField.layer.masksToBounds = true
        searchTrackerField.delegate = self
        searchTrackerField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return searchTrackerField
    }()
    
    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView()
        plugImage.image = UIImage(named: "plug_image")
        return plugImage
    }()
    
    private lazy var plugLabel: UILabel = {
        let plugLabel = UILabel()
        plugLabel.text = NSLocalizedString("emptyState.title", tableName: "LocalizableString", comment: "")
        plugLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        plugLabel.textColor = .ypBlack
        return plugLabel
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersSupplementaryView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let filtersButton = UIButton()
        filtersButton.setTitle("Фильтр", for: .normal)
        filtersButton.backgroundColor = .ypBlue
        filtersButton.setTitleColor(.white, for: .normal)
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17.0, weight: .regular)
        filtersButton.layer.cornerRadius = 16
        filtersButton.addTarget(self, action: #selector(filtersButtonAction), for: .touchUpInside)
        return filtersButton
    }()
    
    @objc private func filtersButtonAction() {
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.filter.rawValue])
        print("Event: filter")
        let vc = TrackerFilterViewController()
        vc.delegate = self
        vc.selectedFilter = selectedFilter
        present(vc, animated: true)
    }
    
    @objc private func createNewTrackers() {
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.add_track.rawValue])
        print("Event: add_tracker")
        let viewController = ChooseTypeOfTrackerController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            updateCategories(with: trackerCategoryStore.trackerCategories)
        }
    }
    
    @objc func textFieldChanged() {
        
        searchText = searchTrackerField.text ?? ""
        plugImage.image = searchText.isEmpty ? UIImage(named: "plug_image") : UIImage(named: "error")
        plugLabel.text = searchText.isEmpty ? "Что будем отслеживать?" : "Ничего не найдено"
        visibleCategories = trackerCategoryStore.predicateFetch(title: searchText)
        updateCategories(with: trackerCategoryStore.predicateFetch(title: searchText))
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        try? self.trackerStore.deleteTracker(tracker)
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.delete.rawValue])
        print("Event: delete_tracker")
    }
    
    private func actionSheet(trackerToDelete: Tracker) {
        let alert = UIAlertController(title: NSLocalizedString("delete.confirmation", tableName: "LocalizableString", comment: ""),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", tableName: "LocalizableString", comment: ""),
                                      style: .destructive) { [weak self] _ in
            self?.deleteTracker(trackerToDelete)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", tableName: "LocalizableString", comment: ""),
                                      style: .cancel) { _ in
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].trackers[indexPath.row]
        }
        let pinTitle = tracker.pinned == true ? "Открепить" : "Закрепить"
        let pin = UIAction(title: pinTitle, image: nil) { [weak self] action in
            try? self?.trackerStore.togglePinTracker(tracker)
        }
        let rename = UIAction(title: "Редактировать", image: nil) { [weak self] action in
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.edit.rawValue])
            let vc = CreateNewTrackerViewController(typeOfEvent: .regular)
            vc.editTracker = tracker
            vc.editTrackerDate = self?.datePicker.date ?? Date()
            vc.category = tracker.category
            self?.present(vc, animated: true)
        }
        let delete = UIAction(title: NSLocalizedString("delete", tableName: "LocalizableString", comment: ""), image: nil, attributes: .destructive) { [weak self] action in
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.delete.rawValue])
            self?.actionSheet(trackerToDelete: tracker)
        }
        return UIMenu(children: [pin, rename, delete])
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
        [trackerLabel, plugImage, plugLabel, searchTrackerField, datePicker,plusTrackerButton, trackersCollectionView, filtersButton].forEach(view.setupView(_:))
    }
    
    private func updateCategories(with categories: [TrackerCategory]) {
        var newCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        visibleCategories = trackerCategoryStore.trackerCategories
        for category in categories {
            var newTrackers: [Tracker] = []
            for tracker in category.trackers {
                guard let schedule = tracker.schedule else { return }
                let scheduleInts = schedule.map { $0.numberOfDay }
                if let day = currentDate, scheduleInts.contains(day)  {
                    if selectedFilter == .completed {
                        if !completedTrackers.contains(where: { record in
                            record.trackerId == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                    }
                    if selectedFilter == .uncompleted {
                        if completedTrackers.contains(where: { record in
                            record.trackerId == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                    }
                    if tracker.pinned == true {
                        pinnedTrackers.append(tracker)
                    } else {
                        newTrackers.append(tracker)
                    }
                }
            }
            if newTrackers.count > 0 {
                let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(newCategory)
            }
        }
        visibleCategories = newCategories
        self.pinnedTrackers = pinnedTrackers
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
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analyticsService.report(event: .open, params: ["Screen" : "Main"])
        print("Event: open")
        addView()
        applyConstraints()
        setNavBar()
        setDayOfWeek()
        updateCategories(with: trackerCategoryStore.trackerCategories)
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, params: ["Screen" : "Main"])
        print("Event: close")
    }
}

extension TrackersViewController: TrackerStoreDelegate, TrackerCategoryStoreDelegate, TrackerRecordStoreDelegate {

    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        updateCategories(with: trackerCategoryStore.trackerCategories)
        trackersCollectionView.reloadData()
    }
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.trackerCategories
        trackersCollectionView.reloadData()
    }
    
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        updateCategories(with: trackerCategoryStore.trackerCategories)
        trackersCollectionView.reloadData()
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { record in
            record.trackerId == id &&
            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(with: id, date: datePicker.date)
        } else {
            analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.track.rawValue])
            print("Event: completed_track")
            completedTrackers.append(TrackerRecord(trackerId: id, date: datePicker.date))
            try? trackerRecordStore.addNewTrackerRecord(TrackerRecord(trackerId: id, date: datePicker.date))
        }
        updateCategories(with: trackerCategoryStore.trackerCategories)
    }
}

extension TrackersViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTrackerField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchTrackerField.text = ""
        updateCategories(with: trackerCategoryStore.trackerCategories)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchTextField = textField.text else { return }
        searchText = searchTextField
        updateCategories(with: trackerCategoryStore.trackerCategories)
    }
}


extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visibleCategories.count
        collectionView.isHidden = count == 0 && pinnedTrackers.count == 0
        filtersButton.isHidden = collectionView.isHidden && selectedFilter == nil
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pinnedTrackers.count
        } else {
            return visibleCategories[section - 1].trackers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else { return UICollectionViewCell() }
        let tracker: Tracker
        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].trackers[indexPath.row]
        }
         
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
            completedCount: completedCount,
            pinned: tracker.pinned ?? false
        )
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (trackersCollectionView.bounds.width - 7) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 7
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
        if indexPath.section == 0 {
            view.titleLabel.text = "Закрепленные"
        } else {
            view.titleLabel.text = visibleCategories[indexPath.section - 1].title
        }
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 && pinnedTrackers.count == 0 {
            return .zero
        }
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(
         _ collectionView: UICollectionView,
         contextMenuConfigurationForItemAt indexPath: IndexPath,
         point: CGPoint
     ) -> UIContextMenuConfiguration? {
         let identifier = "\(indexPath.row):\(indexPath.section)" as NSString
         return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) {
             suggestedActions in
              return self.makeContextMenu(indexPath)
         }
     }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        let components = identifier.components(separatedBy: ":")
        print(identifier)
        guard let rowString = components.first,
              let sectionString = components.last,
              let row = Int(rowString),
              let section = Int(sectionString) else { return nil }
        let indexPath = IndexPath(row: row, section: section)
                
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else { return nil }
        
        return UITargetedPreview(view: cell.updateMenu)
    }
}

extension TrackersViewController: TrackerFilterViewControllerDelegate, ChooseTypeOfTrackerControllerProtocol {
    func filterSelected(filter: Filter) {
        selectedFilter = filter
        searchText = ""
        switch filter {
        case .all:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        case .today:
            datePicker.date = Date()
            dateChanged(datePicker)
            updateCategories(with: trackerCategoryStore.trackerCategories)
        case .completed:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        case .uncompleted:
            updateCategories(with: trackerCategoryStore.trackerCategories)
        }
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
        updateCategories(with: trackerCategoryStore.trackerCategories)
    }
}
