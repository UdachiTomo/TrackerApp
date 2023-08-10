import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completedTracker(id: UUID)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "trackerCollectionViewCell"
    public weak var delegate: TrackersCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    
    public var updateMenu: UIView {
        return collectionView
    }
    
    private lazy var collectionView: UIView = {
        let collectionView = UIView()
        collectionView.layer.cornerRadius = 16
        return collectionView
    } ()
    
    private lazy var emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .white.withAlphaComponent(0.3)
        emojiView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        emojiView.layer.cornerRadius = emojiView.bounds.height / 2
        emojiView.layer.masksToBounds = true
        return emojiView
    } ()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        return emojiLabel
    } ()
    
    private lazy var trackerName: UILabel = {
        let trackerName = UILabel()
        trackerName.font = UIFont.systemFont(ofSize: 12)
        trackerName.textAlignment = .left
        trackerName.adjustsFontSizeToFitWidth = true
        trackerName.minimumScaleFactor = 0.5
        trackerName.numberOfLines = 2
        return trackerName
    } ()
    
    private lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.font = UIFont.systemFont(ofSize: 12)
        resultLabel.text = " 0 дней"
        return resultLabel
    } ()
    
    private lazy var checkButton: UIButton = {
        let checkButton = UIButton(type: .system)
        let image = UIImage(systemName: "plus")
        checkButton.setImage(image, for: .normal)
        checkButton.tintColor = .white
        checkButton.layer.cornerRadius = 16
        checkButton.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        return checkButton
    } ()
    
    private lazy var pinImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pin")
        image.isHidden = false
        return image
    }()
    
    @objc private func didTapCheckButton() {
        guard let id = trackerId else { return }
        delegate?.completedTracker(id: id)
    }
    
    private func addView() {
        [collectionView, emojiView, emojiLabel, trackerName, resultLabel, checkButton, pinImageView].forEach(setupView(_:))
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 90),
            collectionView.widthAnchor.constraint(equalToConstant: 167),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 12),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            trackerName.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -6),
            trackerName.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 12),
            trackerName.heightAnchor.constraint(equalToConstant: 34),
            checkButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            checkButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -12),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            checkButton.widthAnchor.constraint(equalToConstant: 34 ),
            resultLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            pinImageView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -4)
        ])
    }
    
    func configure(
        _ id: UUID,
        title: String,
        color: UIColor,
        emoji: String,
        isCompleted: Bool,
        isEnabled: Bool,
        completedCount: Int,
        pinned: Bool
    ) {
        trackerId = id
        trackerName.text = title
        collectionView.backgroundColor = color
        checkButton.backgroundColor = color
        emojiLabel.text = emoji
        isCompletedToday = isCompleted
        checkButton.setImage(isCompletedToday ? UIImage(systemName: "checkmark")! : UIImage(systemName: "plus")!, for: .normal)
        pinImageView.isHidden = !pinned
        checkButton.isEnabled = isEnabled
        if isCompletedToday == true {
            checkButton.alpha = 0.5
        } else {
            checkButton.alpha = 1
        }
        resultLabel.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDay", comment: ""), completedCount)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        applyConstraints()
        addSubview(checkButton)
        collectionView.addSubview(pinImageView)
        collectionView.addSubview(emojiView)
        collectionView.addSubview(trackerName)
        collectionView.addSubview(emojiLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TrackersSupplementaryView: UICollectionReusableView {
    
    static let identifier = "header"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
