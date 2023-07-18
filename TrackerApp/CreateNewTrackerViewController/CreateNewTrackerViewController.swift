import UIKit

protocol CreateNewTrackerViewControllerProtocol: AnyObject {
        func createTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateNewTrackerViewController: UIViewController, TrackerScheduleViewControllerDelegate, TrackerCategoryViewControllerProtocol {
    public weak var delegate: CreateNewTrackerViewControllerProtocol?
    private var trackerService = TrackerService.shared
    private var typeOfEvent: TypeOfEvent
    private var eventButtons: [String] {
        return typeOfEvent.caseOfButton
    }
    private var categoryTitle: String = ""
    private var scheduleTitle: String = ""
    private var schedule: [WeekDay] = []
    private var color: [UIColor] = [.color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9, .color10, .color11, .color12, .color13, .color14, .color15, .color16, .color17, .color18]
    private var emoji: [String] = ["🙂", "😻", "🌺", "🐶", "♥️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedEmojiCell: IndexPath? = nil
    private var selectedColorCell: IndexPath? = nil
    private var selectedColor: UIColor? = nil
    private var selectedEmoji: String = "" 
    private var collectionViewHeader = ["Emoji", "Цвет"]
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
        titleTrackerTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleTrackerTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        titleTrackerTextField.leftViewMode = .always
        titleTrackerTextField.layer.cornerRadius = 16
        titleTrackerTextField.addTarget(self, action: #selector(method), for: .editingChanged)
        return titleTrackerTextField
    } ()
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton()
        addTrackerButton.setTitle("Создать", for: .normal)
        addTrackerButton.setTitleColor(.white, for: .normal)
        addTrackerButton.layer.cornerRadius = 16
        addTrackerButton.backgroundColor = .ypGray
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
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiAndColorCollectionViewCell.self, forCellWithReuseIdentifier: EmojiAndColorCollectionViewCell.identifier)
        collectionView.register(EmojiAndColorSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorSupplementaryView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    } ()
    
    private func setupButtonStack() {
        buttonStack.addArrangedSubview(cancerTrackerButton)
        buttonStack.addArrangedSubview(addTrackerButton)
    }
    
    
    @objc func createTitleTracker() {
        
    }
    
    @objc func didTapAddTrackerButton() {
        let tracker = Tracker(id: UUID(), title: titleTrackerTextField.text ?? "", color: selectedColor ?? .color1, emoji: selectedEmoji, schedule: schedule)
        delegate?.createTracker(tracker, categoryTitle: categoryTitle)
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc private func didTapCancelTrackerButton() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = firstScene.windows.first else { return }
        let vc = firstWindow.rootViewController
        vc?.dismiss(animated: true)
    }
    
    private func didTapCategoryButton() {
        let viewController = TrackerCategoryViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func didTapScheduleButton() {
        let viewController = TrackerScheduleViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
   
    private func addView() {
        [headerLabel, tableView, titleTrackerTextField, buttonStack, collectionView].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
        
        if typeOfEvent == .regular {
            NSLayoutConstraint.activate([
                headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
                titleTrackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
                titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75 ),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.topAnchor.constraint(equalTo: titleTrackerTextField.bottomAnchor, constant: 38),
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
        view.backgroundColor = .white
        addView()
        applyConstraints()
        setupButtonStack()
        view.addSubview(buttonStack)
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
        print(count)
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
        let section = indexPath.section
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell
        if section == 0 {
            if selectedEmojiCell != nil {
                collectionView.deselectItem(at: selectedEmojiCell!, animated: true)
                collectionView.cellForItem(at: selectedEmojiCell!)?.backgroundColor = .white
            }
            cell?.backgroundColor = .ypLightGray
            selectedEmoji = cell?.emojiLabel.text ?? ""
            selectedEmojiCell = indexPath
        } else if section == 1 {
            if selectedColorCell != nil {
                collectionView.deselectItem(at: selectedColorCell!, animated: true)
                collectionView.cellForItem(at: selectedColorCell!)?.layer.borderWidth = 0
            }
            cell?.layer.borderWidth = 3
            cell?.layer.cornerRadius = 8
            cell?.layer.borderColor = UIColor.ypLightGray.cgColor
            selectedColor = cell?.colorView.backgroundColor ?? nil
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
