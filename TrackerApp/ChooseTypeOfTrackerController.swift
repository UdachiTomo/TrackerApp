import UIKit

protocol ChooseTypeOfTrackerControllerProtocol: AnyObject {
    func createTracker(_ tracker: Tracker, categoryTitle: String)
}

extension ChooseTypeOfTrackerController: CreateNewTrackerViewControllerProtocol {
    func createTracker(_ tracker: Tracker, categoryTitle: String) {
        delegate?.createTracker(tracker, categoryTitle: categoryTitle)
    }
    

}

final class ChooseTypeOfTrackerController: UIViewController {
   
    public weak var delegate: ChooseTypeOfTrackerControllerProtocol?
    
    private lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "Создание Трекера"
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return headerLabel
    } ()
    
    private lazy var regularButton: UIButton = {
        let regularButton = UIButton()
        regularButton.setTitle("Привычка", for: .normal)
        regularButton.setTitleColor(.ypWhite, for: .normal)
        regularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        regularButton.backgroundColor = .ypBlack
        regularButton.layer.cornerRadius = 16
        regularButton.addTarget(self, action: #selector(regularTapButton), for: .touchUpInside)
        return regularButton
    } ()
    
    private lazy var irregularButton: UIButton = {
        let irregularButton = UIButton()
        irregularButton.setTitle("Нерегулярное событие", for: .normal)
        irregularButton.setTitleColor(.ypWhite, for: .normal)
        irregularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularButton.backgroundColor = .ypBlack
        irregularButton.layer.cornerRadius = 16
        irregularButton.addTarget(self, action: #selector(irregularTapButton), for: .touchUpInside)
        return irregularButton
    } ()
    
    @objc private func regularTapButton() {
        let viewController = CreateNewTrackerViewController(typeOfEvent: .regular)
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    @objc private func irregularTapButton() {
        let viewController = CreateNewTrackerViewController(typeOfEvent: .irregular)
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func addView() {
        [headerLabel, regularButton, irregularButton].forEach(view.setupView(_:))
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            regularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 395),
            regularButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.topAnchor.constraint(equalTo: regularButton.bottomAnchor, constant: 16),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addView()
        applyConstraints()
    }
}
