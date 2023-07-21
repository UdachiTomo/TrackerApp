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
    
    private func setupTableView() {
        addSubview(firstLabel)
        addSubview(secondLabel)
        backgroundColor = .ypLightGray
    }
    
    private func addView() {
        [ firstLabel, secondLabel].forEach(setupView(_:))
    }
    
    private func applyConstraints() {
        if secondLabel.text?.isEmpty == true {
            NSLayoutConstraint.activate([
                firstLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
                firstLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: -2),
                secondLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            ])
        } else if secondLabel.text?.isEmpty != false {
            NSLayoutConstraint.activate([
                firstLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
                firstLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: -2),
                secondLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            ])
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CreateNewTrackerTableViewCell.identifier)
        addView()
        applyConstraints()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

