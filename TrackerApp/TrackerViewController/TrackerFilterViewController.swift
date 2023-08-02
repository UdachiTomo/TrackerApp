import UIKit

protocol TrackerFilterViewControllerDelegate: AnyObject {
    func filterSelected(filter: Filter)
}

final class TrackerFilterViewController: UIViewController {
    
    weak var delegate: TrackerFilterViewControllerDelegate?
    private let filters: [Filter] = Filter.allCases
    private var selectedIndexes: IndexPath?
    var selectedFilter: Filter?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Фильтры"
        titleLabel.textColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    } ()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.identifier)
        tableView.separatorColor = .ypGray
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        return tableView
    } ()
    
    private func addView() {
        [titleLabel, tableView].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        applyConstraints()
    }
}

extension TrackerFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryTableViewCell.identifier, for: indexPath) as? TrackerCategoryTableViewCell else { return UITableViewCell() }
        let filter = filters[indexPath.row]
        cell.accessoryType = .none
        cell.label.text = filter.rawValue
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        if let selectedIndexes = selectedIndexes, selectedIndexes == indexPath {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filterCell = tableView.cellForRow(at: indexPath) as? TrackerCategoryTableViewCell else {
            return
        }
        let filter = filterCell.label.text
        delegate?.filterSelected(filter: Filter(rawValue: filter!) ?? .all)
        dismiss(animated: true)
    }
}
