import UIKit

final class CreateNewTrackerTableViewCell: UITableViewCell {
    
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
        if ((secondLabel.text?.isEmpty) == nil) {
            NSLayoutConstraint.activate([
                labelStack.topAnchor.constraint(equalTo: topAnchor, constant: 26),
                labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            ])
        } else if ((secondLabel.text?.isEmpty) != nil) {
            NSLayoutConstraint.activate([
                labelStack.centerXAnchor.constraint(equalTo: centerXAnchor),
                labelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            ])
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CreateNewTrackerTableViewCell.identifier)
        addView()
        applyConstraints()
        setupButtonStack()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

