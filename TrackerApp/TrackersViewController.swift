import UIKit

class MockData {
    static var categories: [TrackerCategory] = [
        TrackerCategory(title: "Важное", trackers: [
            Tracker(id: UUID(), title: "Сходить в магазин", color: .color1, emoji: "🏝", schedule: [.wednesday, .saturday]),
            Tracker(id: UUID(), title: "Сделать дубликат ключа", color: .color2, emoji: "🙂", schedule: [.monday, .saturday, .wednesday, .friday, .sunday, .thursday,.tuesday])
        ])]
}

final class TrackersViewController: UIViewController, UITextFieldDelegate, ChooseTypeOfTrackerControllerProtocol {
    
    private var categories: [TrackerCategory] = MockData.categories
    private var trackers: [Tracker] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    private var currentDate: Int?
    private var searchText: String = ""
    private let todayDate = Date()

    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
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
        updateCategories()
    }
    
    @objc func trackerCompleteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview as? TrackersCollectionViewCell,
              let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        //guard todayDate < Date() || ((tracker.schedule?.isEmpty) != nil) else { return }
        let trackerRecord = createTrackerRecord(with: tracker.id)
        if completedTrackers.contains(trackerRecord) {
            completedTrackers.remove(trackerRecord)
        } else {
            completedTrackers.insert(trackerRecord)
        }
        cell.resultLabel.text = setupCounterTextLabel(trackerID: tracker.id)
    }
    
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
    
    private func updateVisibleCategories(_ newCategory: [TrackerCategory]) {
        visibleCategories = newCategory
        trackersCollectionView.reloadData()
    }
    
    private func addView() {
        [trackerLabel, plugImage, plugLabel, searchTrackerField, datePicker,plusTrackerButton, trackersCollectionView].forEach(view.setupView(_:))
    }
    
    private func updateCategories() {
        var newCategories: [TrackerCategory] = []
        for category in categories {
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
    
    private func setupUICell(_ cell: TrackersCollectionViewCell, withTracker tracker: Tracker) {
        cell.emojiLabel.text = tracker.emoji
        cell.trackerName.text = tracker.title
        cell.collectionView.backgroundColor = tracker.color
        cell.checkButton.backgroundColor = tracker.color
        let trackerRecord = createTrackerRecord(with: tracker.id)
        let isCompleted = completedTrackers.contains(trackerRecord)
        cell.checkButton.toggled = isCompleted
        cell.checkButton.addTarget(self, action: #selector(trackerCompleteButtonTapped(_:)), for: .touchUpInside)
        cell.resultLabel.text = setupCounterTextLabel(trackerID: tracker.id)
    }

    private func setupCounterTextLabel(trackerID: UUID) -> String {
        let count = completedTrackers.filter { $0.trackerId == trackerID }.count
        let lastDigit = count % 10
        var text: String
        text = count.days()
        return("\(text)")
    }
    
    private func createTrackerRecord(with id: UUID) -> TrackerRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: todayDate)
        let trackerRecord = TrackerRecord(trackerId: id, date: date)
        return trackerRecord
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
        setupUICell(cell, withTracker: tracker)
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
        if kind == UICollectionView.elementKindSectionHeader {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersSupplementaryView.identifier, for: indexPath) as? TrackersSupplementaryView else { return UICollectionReusableView() }
            view.titleLabel.text = visibleCategories[indexPath.section].title
            return view
        }
        return UICollectionReusableView()
        
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
