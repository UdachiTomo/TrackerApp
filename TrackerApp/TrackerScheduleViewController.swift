import UIKit


protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func addDaysToSchedule(schedule: [WeekDay])
}

final class TrackerScheduleViewController: UIViewController, WeekDayTableViewCellDelegate {
    public weak var delegate: TrackerScheduleViewControllerDelegate?
    private var schedule: [WeekDay] = []
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Расписание"
        headerLabel.textColor = .black
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return headerLabel
    } ()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(WeekDayTableViewCell.self, forCellReuseIdentifier: WeekDayTableViewCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    } ()
    
    
    private lazy var finishButton: UIButton = {
        let finishButton = UIButton()
        finishButton.setTitle("Готово", for: .normal)
        finishButton.backgroundColor = .black
        finishButton.layer.cornerRadius = 16
        finishButton.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        return finishButton
    } ()
    
    @objc private func didTapFinishButton() {
        let schedule = schedule
        delegate?.addDaysToSchedule(schedule: schedule)
        dismiss(animated: true)
    }
    
    private func addView() {
        [headerLabel, tableView, finishButton].forEach(view.setupView(_:))
    }
    
    func stateChanged(for day: WeekDay, isOn: Bool) {
        if isOn {
            schedule.append(day)
            print(schedule)
        } else {
            if let index = schedule.firstIndex(of: day) {
                schedule.remove(at: index)
            }
        }
    }
    
    private func applyConstraints () {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -62),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            finishButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        applyConstraints()
    }
}

extension TrackerScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekDayTableViewCell.identifier) as? WeekDayTableViewCell else {
            return UITableViewCell()
        }
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }
        let weekDay = WeekDay.allCases[indexPath.row]
        cell.delegate = self
        cell.weekDay = weekDay
        cell.label.text = weekDay.fullName
        return cell
    }
}

protocol WeekDayTableViewCellDelegate: AnyObject {
    func stateChanged(for day: WeekDay, isOn: Bool)
}

class WeekDayTableViewCell: UITableViewCell {
    
    static let identifier = "WeekDayCell"
    weak var delegate: WeekDayTableViewCellDelegate?
    var weekDay: WeekDay?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        return label
    } ()
    
    lazy var switchDay: UISwitch = {
        let switchDay = UISwitch()
        switchDay.translatesAutoresizingMaskIntoConstraints = false
        switchDay.isOn = false
        switchDay.onTintColor = .ypBlue
        switchDay.addTarget(self, action: #selector(switchValueChange), for: .valueChanged)
        return switchDay
    } ()
    
    @objc private func switchValueChange(_ sender: UISwitch) {
        guard let weekDay else { return }
        delegate?.stateChanged(for: weekDay, isOn: sender.isOn)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: WeekDayTableViewCell.identifier)
        setupUI()
        applyConstraits()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .ypLightGray
        contentView.addSubview(switchDay)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraits() {
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            switchDay.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchDay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
    
