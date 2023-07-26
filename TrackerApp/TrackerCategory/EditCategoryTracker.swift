import UIKit

class EditCategoryTracker: UIViewController {
    
    var editableCategory: TrackerCategory?
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.text = "Редактирование категории"
        titleLabel.font = .systemFont(ofSize: 16)
        return titleLabel
    }()
    
    private lazy var titleTrackerTextField: UITextField = {
        let titleTrackerTextField = UITextField()
        titleTrackerTextField.textColor = .ypBlack
        titleTrackerTextField.backgroundColor = .backgroundColor
        titleTrackerTextField.layer.cornerRadius = 16
        titleTrackerTextField.font = .systemFont(ofSize: 17)
        titleTrackerTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        titleTrackerTextField.leftViewMode = .always
        titleTrackerTextField.text = editableCategory?.title
        UITextField.appearance().clearButtonMode = .whileEditing
        titleTrackerTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return titleTrackerTextField
    }()
    
    private lazy var editCategoryButton: UIButton = {
        let editCategoryButton = UIButton()
        editCategoryButton.setTitle("Готово", for: .normal)
        editCategoryButton.titleLabel?.textColor = .white
        editCategoryButton.backgroundColor = .ypGray
        editCategoryButton.isEnabled = true
        editCategoryButton.layer.cornerRadius = 16
        editCategoryButton.addTarget(self, action: #selector(editCategoryButtonAction), for: .touchUpInside)
        return editCategoryButton
    }()
    
    @objc func textFieldChanged() {
        if titleTrackerTextField.text != "" {
            editCategoryButton.backgroundColor = .ypBlack
            editCategoryButton.isEnabled = true
        } else {
            editCategoryButton.backgroundColor = .ypGray
            editCategoryButton.isEnabled = false
        }
    }
    
    @objc func editCategoryButtonAction() {
        guard let editableCategory = editableCategory else { return }
        if let newCategoryTitle = titleTrackerTextField.text {
            try? trackerCategoryStore.updateCategoryTitle(newCategoryTitle, editableCategory)
            dismiss(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        titleTrackerTextField.becomeFirstResponder()
        addView()
        applyConstraints()
    }
    
    private func addView() {
        [titleLabel, titleTrackerTextField, editCategoryButton].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleTrackerTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            titleTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            editCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            editCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
