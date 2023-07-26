import UIKit

final class TrackerCategoryViewController: UIViewController, CreateNewTrackerCategoryDelegate {

    private var selectedIndexes: IndexPath?
    private let viewModel: CategoriesViewModel
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Категория"
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return headerLabel
    } ()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TrackerCategoryTableViewCell.self, forCellReuseIdentifier: TrackerCategoryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsMultipleSelection = false
        return tableView
    }()

    private lazy var placeholderLabel: UILabel = {
       let placeholderLabel = UILabel()
        placeholderLabel.text = "Привычки и события можно nобъединить по смыслу"
        placeholderLabel.tintColor = .black
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return placeholderLabel
    }()

    private lazy var placeholderImage: UIImageView = {
        let placeholderImage = UIImageView()
        placeholderImage.image = UIImage(named: "plug_image")
        return placeholderImage
    }()

    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        return addCategoryButton
    }()

    @objc private func didTapAddCategoryButton() {
        let vc = CreateNewTrackerCategory()
        vc.delegate = self
        present(vc, animated: true)
    }

    private func addView() {
        [headerLabel, tableView, addCategoryButton, placeholderLabel, placeholderImage].forEach(view.setupView(_:))
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
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.widthAnchor.constraint(equalToConstant: 200),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    func createCategory(_ category: TrackerCategory) {
        viewModel.selectCategory(category)
        viewModel.selectCategory(with: category.title)
    }

    private func actionSheet(categoryToDelete: TrackerCategory) {
        let alert = UIAlertController(title: "Эта категория точно не нужна?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить",
                                      style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(categoryToDelete)
        })
        alert.addAction(UIAlertAction(title: "Отменить",
                                      style: .cancel) { _ in

        })

        self.present(alert, animated: true, completion: nil)
    }

    func contexMenu(_ indexPath: IndexPath) -> UIMenu {
        let category = viewModel.categories[indexPath.row]
        let rename = UIAction(title: "Редактировать", image: nil) { [weak self] action in
            let vc = EditCategoryTracker()
            vc.editableCategory = category
            self?.present(vc, animated: true)
        }
        let delete = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] action in
            self?.actionSheet(categoryToDelete: category)
        }
        return UIMenu(children: [rename, delete])
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: {suggestedActions in
            return self.contexMenu(indexPath)
        })
    }

    init(delegate: CategoriesViewModelDelegate?, selectedCategory: TrackerCategory?) {
        viewModel = CategoriesViewModel(delegate: delegate, selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
        viewModel.onChange = self.tableView.reloadData
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let count = viewModel.categories.count
        tableView.isHidden = count == 0
        if count != 0 {
            placeholderLabel.isHidden = true
            placeholderImage.isHidden = true
        }
        return count
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
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
            if let selectedIndexes = selectedIndexes, selectedIndexes == indexPath {
                cell.accessoryType = .checkmark
                cell.tintColor = .ypBlue
            } else {
                cell.accessoryType = .none
            }
            cell.selectionStyle = .none
            cell.label.text = viewModel.categories[indexPath.row].title
            return cell
            
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let cell = tableView.cellForRow(at: indexPath) as? TrackerCategoryTableViewCell else { return }
            guard let category = cell.label.text else { return }
            viewModel.selectCategory(with: category)
            dismiss(animated: true)
        }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            selectedIndexes = nil
        }
    }
