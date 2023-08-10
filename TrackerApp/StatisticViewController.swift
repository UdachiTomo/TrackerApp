import UIKit

final class StatisticViewController: UIViewController {
    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .ypBlack
        titleLabel.text = NSLocalizedString("statistic", tableName: "LocalizableString", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
    private lazy var plugImage: UIImageView = {
        let plugImage = UIImageView()
        plugImage.image = UIImage(named: "error_statistic")
        return plugImage
    }()
    
    private lazy var plugLabel: UILabel = {
        let plugLabel = UILabel()
        plugLabel.textColor = .ypBlack
        plugLabel.text = "Анализировать пока нечего"
        plugLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return plugLabel
    }()
    
    private lazy var completedTrackerView: UIView = {
        let completedTrackerView = UIView()
        return completedTrackerView
    }()
    
    private lazy var resultTitle: UILabel = {
        let resultLabel = UILabel()
        resultLabel.textColor = .ypBlack
        resultLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        resultLabel.textAlignment = .left
        return resultLabel
    }()
    
    private lazy var resultSubTitle: UILabel = {
        let resultSubTitle = UILabel()
        resultSubTitle.textColor = .ypBlack
        resultSubTitle.font = .systemFont(ofSize: 12, weight: .medium)
        resultSubTitle.textAlignment = .left
        return resultSubTitle
    }()
    
    private func addView() {
        [titleLabel, plugImage, plugLabel, completedTrackerView, resultTitle, resultSubTitle].forEach(view.setupView(_:))
        
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            plugImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            plugImage.widthAnchor.constraint(equalToConstant: 80),
            plugImage.heightAnchor.constraint(equalToConstant: 80),
            plugLabel.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: plugImage.centerXAnchor),
            completedTrackerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            completedTrackerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            completedTrackerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            completedTrackerView.heightAnchor.constraint(equalToConstant: 90),
            resultTitle.topAnchor.constraint(equalTo: completedTrackerView.topAnchor, constant: 12),
            resultTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultTitle.heightAnchor.constraint(equalToConstant: 41),
            resultSubTitle.bottomAnchor.constraint(equalTo: completedTrackerView.bottomAnchor, constant: -12),
            resultSubTitle.leadingAnchor.constraint(equalTo: completedTrackerView.leadingAnchor, constant: 12),
            resultSubTitle.trailingAnchor.constraint(equalTo: completedTrackerView.trailingAnchor, constant: -12),
            resultSubTitle.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func updateCompletedTrackers() {
        completedTrackers = trackerRecordStore.trackerRecords
        resultTitle.text = "\(completedTrackers.count)"
        resultSubTitle.text = String.localizedStringWithFormat(NSLocalizedString("trackerCompleted", comment: ""), completedTrackers.count)
        plugLabel.isHidden = completedTrackers.count > 0
        plugImage.isHidden = completedTrackers.count > 0
        resultTitle.isHidden = completedTrackers.count == 0
        resultSubTitle.isHidden = completedTrackers.count == 0
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgorundColor
        trackerRecordStore.delegate = self
        addView()
        applyConstraints()
        updateCompletedTrackers()
    }
}

extension StatisticViewController: TrackerRecordStoreDelegate {
    
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        updateCompletedTrackers()
    }
}
