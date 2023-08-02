import UIKit

protocol CreateNewTrackerCategoryDelegate: AnyObject {
    func createCategory(_ category: TrackerCategory)
}

final class CreateNewTrackerCategory: UIViewController {
    
    var delegate: CreateNewTrackerCategoryDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16)
        return label
    } ()
    
    private lazy var categoryTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = .ypBlack
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        UITextField.appearance().clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .ypGray
        button.isEnabled = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    @objc func textFieldChanged() {
        if categoryTitleTextField.text != "" {
            addCategoryButton.backgroundColor = .black
            addCategoryButton.isEnabled = true
        } else {
            addCategoryButton.backgroundColor = .gray
            addCategoryButton.isEnabled = false
        }
    }
    
    @objc func addCategoryButtonAction() {
        if let categoryTitle = categoryTitleTextField.text {
            let category = TrackerCategory(title: categoryTitle, trackers: [])
            try? trackerCategoryStore.addNewTrackerCategory(category)
            delegate?.createCategory(category)
            dismiss(animated: true)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        setupLayout()
    }
    
    private func addView() {
        [titleLabel, categoryTitleTextField, addCategoryButton].forEach(view.setupView(_:))
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            categoryTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTitleTextField.heightAnchor.constraint(equalToConstant: 75),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

