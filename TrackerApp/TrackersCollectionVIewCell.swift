import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completedTracker(id: UUID, indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "trackerCollectionViewCell"
    public weak var delegate: TrackersCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID? = nil
    private var indexPath: IndexPath?
    
    lazy var collectionView: UIView = {
        let collectionView = UIView()
        collectionView.layer.cornerRadius = 16
        return collectionView
    } ()
    
    lazy var emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .white.withAlphaComponent(0.3)
        emojiView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        emojiView.layer.cornerRadius = emojiView.bounds.height / 2
        emojiView.layer.masksToBounds = true
        return emojiView
    } ()
    
    lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        return emojiLabel
    } ()
    
    lazy var trackerName: UILabel = {
        let trackerName = UILabel()
        trackerName.font = UIFont.systemFont(ofSize: 12)
        trackerName.textAlignment = .left
        trackerName.sizeToFit()
        trackerName.numberOfLines = 2
        return trackerName
    } ()
    
    lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.font = UIFont.systemFont(ofSize: 12)
        resultLabel.text = " 0 дней"
        return resultLabel
    } ()
    
    lazy var checkButton: UIButton = {
        let checkButton = UIButton()
        let image = UIImage(systemName: "plus")
        checkButton.setImage(image, for: .normal)
        checkButton.tintColor = .white
        checkButton.layer.cornerRadius = 16
        checkButton.addTarget(self, action: #selector(didTapCheckButton), for: .touchUpInside)
        return checkButton
    } ()
    
    @objc func didTapCheckButton() {
        guard let id = trackerId,
              let indexPath = indexPath else { return }
        if isCompletedToday {
            delegate?.completedTracker(id: id, indexPath: indexPath)
        } else {
            delegate?.uncompleteTracker(id: id, at: indexPath)
        }
    }
    
    func setupCell(tracker: Tracker, isCompleted: Bool, completedCount: Int, indexPath: IndexPath ) {
        emojiLabel.text = tracker.emoji
        trackerName.text = tracker.title
        collectionView.backgroundColor = tracker.color
        checkButton.backgroundColor = tracker.color
        isCompletedToday = isCompleted
        trackerId = tracker.id
        self.indexPath = indexPath
        checkButton.setImage(isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus"), for: .normal)
    }
   
   
    private func addView() {
        [collectionView, emojiView, emojiLabel, trackerName, resultLabel, checkButton].forEach(setupView(_:))
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
            trackerName.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 44),
            trackerName.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 12),
            trackerName.heightAnchor.constraint(equalToConstant: 34),
            checkButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            checkButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -12),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            checkButton.widthAnchor.constraint(equalToConstant: 34 ),
            resultLabel.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        applyConstraints()
        addSubview(checkButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TrackersSupplementaryView: UICollectionReusableView {
    
    static let identifier = "header"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
