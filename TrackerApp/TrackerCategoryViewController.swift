import UIKit

protocol TrackerCategoryViewControllerProtocol: AnyObject {
    func addCategoryInTracker(category: String?)
}

final class TrackerCategoryViewController: UIViewController {
    var trackerService: TrackerService?
    weak var delegate: TrackerCategoryViewControllerProtocol?
    private var selectedIndexes: IndexPath?
    private var mockCategory = ["Важное", "Питомец"]
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Категория"
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return headerLabel
    } ()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds)
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    } ()
    
    private lazy var placeholderLabel: UILabel = {
       let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Привычки и события можно nобъединить по смыслу"
        placeholderLabel.tintColor = .black
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return placeholderLabel
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        return addCategoryButton
    } ()
    
    @objc private func didTapAddCategoryButton() {
        dismiss(animated: true)
    }
    
    private func addView() {
        [headerLabel, tableView, addCategoryButton, placeholderLabel].forEach(view.setupView(_:))
    }
    
    private func applyConstraints () {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -8),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 342)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        applyConstraints()
    }
}

extension TrackerCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mockCategory.isEmpty {
            return 0
        } else {
            return mockCategory.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCategoryTableViewCell.identifier, for: indexPath) as? TrackerCategoryTableViewCell else {
            return UITableViewCell()
        }
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }
        if let selectedIndexes = selectedIndexes, selectedIndexes == indexPath {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        cell.selectionStyle = .none
        cell.label.text = mockCategory[indexPath.row]
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexes = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        let category = mockCategory[indexPath.row]
        delegate?.addCategoryInTracker(category: category )
        tableView.reloadData()
    }
    
   func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexes = nil
        tableView.reloadData()
    }
    
}
    final class TrackerCategoryTableViewCell: UITableViewCell {
        static let identifier = "CategoryCell"
        
        lazy var label: UILabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 17)
            return label
        } ()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: TrackerCategoryTableViewCell.identifier)
            addView()
            applyConstraints()
            backgroundColor = .ypLightGray
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func addView() {
            [label].forEach(setupView(_:))
        }
        
        private func applyConstraints() {
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            ])
        }
}
