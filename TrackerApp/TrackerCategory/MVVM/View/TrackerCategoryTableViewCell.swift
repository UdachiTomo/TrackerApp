import UIKit

final class TrackerCategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryCell"

    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
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
//    static let identifier = "CategoryTableViewCell"
//
//    lazy var label: UILabel = {
//        let label = UILabel()
//        label.textColor = .black
//        label.font = .systemFont(ofSize: 17)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    lazy var view: UIView = {
//       let view = UIView()
//        view.backgroundColor = .backgroundColor
//        view.translatesAutoresizingMaskIntoConstraints = false
//       return view
//    }()
//
//    lazy var checkmarkImage: UIImageView = {
//        let checkmarkImage = UIImageView()
//        checkmarkImage.image = UIImage(named: "checkmark")
//        checkmarkImage.isHidden = true
//        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
//        return checkmarkImage
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .default, reuseIdentifier: TrackerCategoryTableViewCell.identifier)
//        setupView()
//        setupLayout()
//    }
//
//    private func setupView() {
//        self.contentView.addSubview(view)
//        view.addSubview(label)
//        view.addSubview(checkmarkImage)
//    }
//
//    private func setupLayout() {
//        NSLayoutConstraint.activate([
//            view.topAnchor.constraint(equalTo: contentView.topAnchor),
//            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
//            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            checkmarkImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            checkmarkImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
//            checkmarkImage.heightAnchor.constraint(equalToConstant: 14),
//            checkmarkImage.widthAnchor.constraint(equalToConstant: 14)
//        ])
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
