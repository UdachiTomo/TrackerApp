import UIKit

protocol CreateNewTrackerViewControllerProtocol: AnyObject {
        func createTracker(_ tracker: Tracker, categoryTitle: String)
}

final class CreateNewTrackerViewController: UIViewController, TrackerScheduleViewControllerDelegate, TrackerCategoryViewControllerProtocol {
    
    
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

    public weak var delegate: CreateNewTrackerViewControllerProtocol?
    private var trackerService = TrackerService.shared
    private var typeOfEvent: TypeOfEvent
    private var eventButtons: [String] {
        return typeOfEvent.caseOfButton
    }
    private var categoryTitle: String = ""
    private var scheduleTitle: String = ""
    private var schedule: [WeekDay] = []
    
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
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 8
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
    
    private func setupButtonStack() {
        buttonStack.addArrangedSubview(cancerTrackerButton)
        buttonStack.addArrangedSubview(addTrackerButton)
    }
    
    
    @objc func createTitleTracker() {
        
    }
    
    @objc func didTapAddTrackerButton() {
        let tracker = Tracker(id: UUID(), title: titleTrackerTextField.text ?? "", color: .color1, emoji: "🌚", schedule: schedule)
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
    
    private func setupCornerRadiusCell(for cell: CustomTableViewCell, indexPath: IndexPath) -> CustomTableViewCell {
        cell.layer.cornerRadius = 10
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return cell
    }
    
    private func addView() {
        [headerLabel, tableView, titleTrackerTextField, buttonStack].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
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
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addView()
        applyConstraints()
        setupButtonStack()
        view.addSubview(buttonStack)
        self.tableView.layer.cornerRadius = 8
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
        return eventButtons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        cell.firstLabel.text = eventButtons[indexPath.row]
        if indexPath.row == 0 {
            cell.secondLabel.text = categoryTitle
        }
        if indexPath.row == 1 {
            cell.secondLabel.text = scheduleTitle
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

final class CustomTableViewCell: UITableViewCell {
    
    static let identifier = "CustomCell"
    
    lazy var firstLabel: UILabel = {
        let firstLabel = UILabel()
        firstLabel.font = UIFont.systemFont(ofSize: 17)
        firstLabel.textColor = .black
        firstLabel.textAlignment = .left
        return firstLabel
    } ()
    
    lazy var secondLabel: UILabel = {
        let secondLabel = UILabel()
        secondLabel.font = UIFont.systemFont(ofSize: 17)
        secondLabel.textColor = .gray
        return secondLabel
    } ()
    
    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView()
        labelStack.alignment = .fill
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually
        labelStack.spacing = 5
        return labelStack
    } ()
    
    private func setupButtonStack() {
        labelStack.addArrangedSubview(firstLabel)
        labelStack.addArrangedSubview(secondLabel)
    }
    
    private func setupTableView() {
        addSubview(labelStack)
        backgroundColor = .ypLightGray
    }
    
    private func addView() {
        [labelStack].forEach(setupView(_:))
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CustomTableViewCell.identifier)
        addView()
        applyConstraints()
        setupButtonStack()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


