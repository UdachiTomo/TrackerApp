import UIKit

protocol CreateNewTrackerViewControllerProtocol: AnyObject {
        func createTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateNewTrackerViewController: UIViewController, TrackerScheduleViewControllerDelegate , CategoriesViewModelDelegate {
    
    func createCategory(category: TrackerCategory) {
                self.category = category
                let categoryString = category.title
                categoryTitle = categoryString
                tableView.reloadData()
        }
    
    public weak var delegate: CreateNewTrackerViewControllerProtocol?
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var typeOfEvent: TypeOfEvent
    private var completedTrackers: [TrackerRecord] = []
    private var eventButtons: [String] {
        return typeOfEvent.caseOfButton
    }
    
    private var charactersOfTitle = 0
    private var limitOfCharacters = 38
    var category: TrackerCategory? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    private var categoryTitle: String = "" {
        didSet {
            updateCreateEventButton()
        }
    }
    private var scheduleTitle: String = ""
    private var schedule: [WeekDay] = [] {
        didSet {
            updateCreateEventButton()
        }
    }
    private var color: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    private var emoji: [String] = ["🙂", "😻", "🌺", "🐶", "♥️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedEmojiCell: IndexPath? = nil
    private var selectedColorCell: IndexPath? = nil
    private var selectedColor: UIColor? = nil {
        didSet {
            updateCreateEventButton()
        }
    }
    private var selectedEmoji: String = "" {
        didSet {
            updateCreateEventButton()
        }
    }
    private var collectionViewHeader = ["Emoji", "Цвет"]
    var editTracker: Tracker?
    var editTrackerDate: Date?
    
    enum TypeOfEvent {
        case regular
        case irregular
        
        var caseOfButton: [String] {
            switch self {
            case .regular: return ["Категория", "Расписание"]
            case .irregular: return ["Категория"]
            }
        }
    }
    
    init(typeOfEvent: TypeOfEvent) {
        self.typeOfEvent = typeOfEvent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Новая привычка"
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return headerLabel
    } ()
    
    private lazy var titleTrackerTextField: UITextField = {
        let titleTrackerTextField = UITextField()
        titleTrackerTextField.placeholder = "Введите название трекера"
        titleTrackerTextField.clearButtonMode = .whileEditing
        titleTrackerTextField.backgroundColor = .ypLightGray
        titleTrackerTextField.delegate = self
        titleTrackerTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleTrackerTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        titleTrackerTextField.leftViewMode = .always
        titleTrackerTextField.layer.cornerRadius = 16
        titleTrackerTextField.addTarget(self, action: #selector(createTitleTracker), for: .editingChanged)
        return titleTrackerTextField
    } ()
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton()
        var titileLabel = editTracker == nil ? "Создать" : "Сохранить"
        addTrackerButton.setTitle(titileLabel, for: .normal)
        addTrackerButton.setTitleColor(.white, for: .normal)
        addTrackerButton.layer.cornerRadius = 16
        addTrackerButton.backgroundColor = .ypGray
        addTrackerButton.isEnabled = false
        addTrackerButton.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return addTrackerButton
    } ()
    
    private lazy var cancerTrackerButton: UIButton = {
        let cancerTrackerButton = UIButton()
        cancerTrackerButton.setTitle("Отменить", for: .normal)
        cancerTrackerButton.setTitleColor(.ypRed, for: .normal)
        cancerTrackerButton.layer.cornerRadius = 16
        cancerTrackerButton.layer.borderWidth = 1
        cancerTrackerButton.layer.borderColor = UIColor.red.cgColor
        cancerTrackerButton.addTarget(self, action: #selector(didTapCancelTrackerButton), for: .touchUpInside)
        return cancerTrackerButton
    } ()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(CreateNewTrackerTableViewCell.self, forCellReuseIdentifier: CreateNewTrackerTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 8
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 345, bottom: 0, right: 345)
        return tableView
    } ()
    
    private lazy var buttonStack: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.alignment = .fill
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        return buttonStack
    } ()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .justified
        return label
    }()
    
    private lazy var complatedDay: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Дней"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiAndColorCollectionViewCell.self, forCellWithReuseIdentifier: EmojiAndColorCollectionViewCell.identifier)
        collectionView.register(EmojiAndColorSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorSupplementaryView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        return collectionView
    } ()
    
    private func setupButtonStack() {
        buttonStack.addArrangedSubview(cancerTrackerButton)
        buttonStack.addArrangedSubview(addTrackerButton)
    }
    
    private func setupEditTracker() {
        if let editTracker = editTracker {
            schedule = editTracker.schedule ?? []
            addDaysToSchedule(schedule: schedule)
            titleTrackerTextField.text = editTracker.title
            headerLabel.text = "Редактирование привычки"
            selectedColor = editTracker.color
            selectedEmoji = editTracker.emoji  ?? ""
            categoryTitle = editTracker.category?.title ?? ""
            updateCreateEventButton()
            updateComplatedDay()
        }
    }
    
    
    @objc func createTitleTracker() {
        updateCreateEventButton()
        guard let text = titleTrackerTextField.text?.count else { return }
        charactersOfTitle = text
        if charactersOfTitle < limitOfCharacters {
            errorLabel.text = ""
        } else {
            errorLabel.text = "Ограничение 38 символов"
        }
    }
    
    @objc func didTapAddTrackerButton() {
        var tracker: Tracker?
        if editTracker == nil {
            if typeOfEvent == .regular {
                tracker = Tracker(id: UUID(), title: titleTrackerTextField.text ?? "", color: selectedColor, emoji: selectedEmoji, schedule: schedule, pinned: false)
            } else {
                schedule = WeekDay.allCases
                tracker = Tracker(id: UUID(), title: titleTrackerTextField.text ?? "", color: selectedColor ?? .color1, emoji: selectedEmoji, schedule: schedule, pinned: false)
            }
            guard let tracker = tracker else { return }
            delegate?.createTracker(tracker, categoryTitle: categoryTitle)
        } else {
            guard let editTracker = editTracker else { return }
            try? trackerStore.updateTracker(newTitle: titleTrackerTextField.text ?? "",
                                            newEmoji: selectedEmoji,
                                            newColor: selectedColor?.hexString ?? "",
                                            newSchedule: schedule,
                                            categoryTitle: category?.title ?? "Без названия",
                                            editableTracker: editTracker)
        }
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc private func didTapCancelTrackerButton() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = firstScene.windows.first else { return }
        let vc = firstWindow.rootViewController
        vc?.dismiss(animated: true)
    }
    
    private func didTapCategoryButton() {
        let viewController = TrackerCategoryViewController(delegate: self, selectedCategory: category)
        present(viewController, animated: true)
    }
    
    private func didTapScheduleButton() {
        let viewController = TrackerScheduleViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func updateComplatedDay() {
        if let editTracker = editTracker,
           let editTrackerDate = editTrackerDate {
            completedTrackers = trackerRecordStore.trackerRecords
            let completedCount = completedTrackers.filter({ record in
                record.trackerId == editTracker.id
            }).count
            complatedDay.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDay", comment: "дней"), completedCount)
        }
    }
    private func addView() {
        [headerLabel,complatedDay ,tableView, titleTrackerTextField, buttonStack, errorLabel, collectionView].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
        if editTracker == nil {
            complatedDay.isHidden = true
            if typeOfEvent == .regular {
                NSLayoutConstraint.activate([
                    headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
                    titleTrackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
                    titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75 ),
                    errorLabel.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 8),
                    errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 38),
                    tableView.heightAnchor.constraint(equalToConstant: 150),
                    buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    buttonStack.heightAnchor.constraint(equalToConstant: 60),
                    buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
                    collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                    collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -10),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
            } else if typeOfEvent == .irregular {
                NSLayoutConstraint.activate([
                    headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
                    complatedDay.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
                    complatedDay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    complatedDay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
                    titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75 ),
                    errorLabel.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 8),
                    errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 38),
                    tableView.heightAnchor.constraint(equalToConstant: 75),
                    buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    buttonStack.heightAnchor.constraint(equalToConstant: 60),
                    buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
                    collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                    collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -10),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
            }
        } else {
            if typeOfEvent == .regular {
                NSLayoutConstraint.activate([
                    headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
                    complatedDay.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
                    complatedDay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    complatedDay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.topAnchor.constraint(equalTo: complatedDay.bottomAnchor, constant: 40),
                    titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75 ),
                    errorLabel.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 8),
                    errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 38),
                    tableView.heightAnchor.constraint(equalToConstant: 150),
                    buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    buttonStack.heightAnchor.constraint(equalToConstant: 60),
                    buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
                    collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                    collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -10),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
            } else if typeOfEvent == .irregular {
                NSLayoutConstraint.activate([
                    headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
                    titleTrackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
                    titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75 ),
                    errorLabel.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 8),
                    errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    tableView.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 38),
                    tableView.heightAnchor.constraint(equalToConstant: 75),
                    buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    buttonStack.heightAnchor.constraint(equalToConstant: 60),
                    buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
                    collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                    collectionView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -10),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
                ])
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
            }
        }
    }
    
    func addCategoryInTracker(category: String?) {
        self.categoryTitle = category ?? "Без названия"
        tableView.reloadData()
    }
    
    func addDaysToSchedule(schedule: [WeekDay]) {
        self.schedule = schedule
        let scheduleString = schedule.map { $0.shortName }.joined(separator: ", ")
        scheduleTitle = scheduleString == "Пн, Вт, Ср, Чт, Пт, Сб, Вс" ? "Каждый день" : scheduleString
        tableView.reloadData()
    }
    
    func updateCreateEventButton() {
        addTrackerButton.isEnabled = titleTrackerTextField.text?.isEmpty == false && selectedColor != nil && !selectedEmoji.isEmpty
        if typeOfEvent == .regular {
            addTrackerButton.isEnabled = addTrackerButton.isEnabled && !schedule.isEmpty
        }
        
        if addTrackerButton.isEnabled {
            addTrackerButton.backgroundColor = .ypBlack
        } else {
            addTrackerButton.backgroundColor = .gray
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        applyConstraints()
        setupButtonStack()
        view.addSubview(buttonStack)
        setupEditTracker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let indexPathEmoji = emoji.firstIndex(where: {$0 == selectedEmoji}) else { return }
        let cellEmoji = self.collectionView.cellForItem(at: IndexPath(row: indexPathEmoji, section: 0))
        cellEmoji?.backgroundColor = .ypLightGray
        selectedEmojiCell = IndexPath(row: indexPathEmoji, section: 0)
        
        guard let indexPathColor = color.firstIndex(where: {$0.hexString == selectedColor?.hexString}) else { return }
        let cellColor = self.collectionView.cellForItem(at: IndexPath(row: indexPathColor, section: 1))
        cellColor?.layer.borderWidth = 3
        cellColor?.layer.cornerRadius = 8
        cellColor?.layer.borderColor = UIColor.ypLightGray.cgColor
        selectedColorCell = IndexPath(item: indexPathColor, section: 1)
    }
}

extension CreateNewTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            didTapCategoryButton()
        } else if indexPath.row == 1 {
            didTapScheduleButton()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = eventButtons.count
        tableView.isHidden = count == 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateNewTrackerTableViewCell.identifier) as? CreateNewTrackerTableViewCell else {
            return UITableViewCell()
        }
        cell.firstLabel.text = eventButtons[indexPath.row]
        if indexPath.row == 0 {
            cell.secondLabel.text = categoryTitle
        }
        if indexPath.row == 1 {
            cell.secondLabel.text = scheduleTitle
            cell.separatorInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension CreateNewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if section == 0 {
            count = emoji.count
        } else if section == 1 {
            count = color.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiAndColorCollectionViewCell.identifier, for: indexPath) as? EmojiAndColorCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.section == 0 {
            cell.emojiLabel.text = emoji[indexPath.row]
        } else if indexPath.section == 1 {
            cell.colorView.backgroundColor = color[indexPath.row]
            cell.colorView.layer.cornerRadius = 8
        }
        cell.layer.cornerRadius = 16
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
}

extension CreateNewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell else { return }
        if indexPath.section == 0 {
            if selectedEmojiCell != nil {
                collectionView.deselectItem(at: selectedEmojiCell ?? [0], animated: true)
                collectionView.cellForItem(at: selectedEmojiCell ?? [0])?.backgroundColor = .white
            }
            cell.backgroundColor = .ypLightGray
            selectedEmoji = cell.emojiLabel.text ?? ""
            selectedEmojiCell = indexPath
        } else if indexPath.section == 1 {
            if selectedColorCell != nil {
                collectionView.deselectItem(at: selectedColorCell ?? [0], animated: true)
                collectionView.cellForItem(at: selectedColorCell ?? [0])?.layer.borderWidth = 0
            }
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 8
            cell.layer.borderColor = UIColor.ypLightGray.cgColor
            selectedColor = cell.colorView.backgroundColor ?? nil
            selectedColorCell = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: true)
        cell?.backgroundColor = .white
        cell?.layer.borderWidth = 0
        if indexPath.section == 0 {
            selectedEmoji = ""
            selectedEmojiCell = nil
        } else {
            selectedColor = nil
            selectedColorCell = nil
        }
    }
}

extension CreateNewTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
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
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? EmojiAndColorSupplementaryView else { return UICollectionReusableView() }
        let section = indexPath.section
        if section == 0 {
            view.titleLabel.text = collectionViewHeader[0]
        } else if section == 1 {
            view.titleLabel.text = collectionViewHeader[1]
        }
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

extension CreateNewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTrackerTextField.resignFirstResponder()
        return true
    }
}
