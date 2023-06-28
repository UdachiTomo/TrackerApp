import UIKit

final class SplashViewController: UIViewController {
    
    private lazy var screenView: UIImageView = {
        let screenView = UIImageView()
        screenView.image = UIImage(named: "onboarding_screen")
        screenView.contentMode = .scaleAspectFill
        return screenView
    } ()
    
    private lazy var startButton: UIButton = {
        let startButton = UIButton()
        startButton.layer.cornerRadius = 15
        startButton.setTitle("Вот это технологии!", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        startButton.accessibilityIdentifier = "startButton"
        startButton.backgroundColor = .black
        startButton.addTarget(self, action: #selector(toMainView), for: .touchUpInside)
        
        return startButton
    }()
    
    private lazy var descriptionText: UILabel = {
      let descriptionText = UILabel()
        descriptionText.text = "Отслеживайте только то, что хотите"
        descriptionText.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        descriptionText.textColor = .black
        descriptionText.textAlignment = .center
        descriptionText.lineBreakMode = .byWordWrapping
        descriptionText.numberOfLines = 2
        return descriptionText
    } ()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageControlHandle), for: .valueChanged)
        return pageControl
    } ()
    
    @objc private func pageControlHandle(sender: UIPageControl){
        print(sender.currentPage)
        if sender.currentPage != 0 {
            screenView.image = UIImage(named: "onboarding_screen_two")
            descriptionText.text = "Даже если это не литры воды и йога"
        } else {
            screenView.image = UIImage(named: "onboarding_screen")
            descriptionText.text = "Отслеживайте только то, что хотите"
        }
    }
    
    @objc private func toMainView() {
        let navigationViewController = UINavigationController(rootViewController: TabBarController())
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true)
//        let vc = TabBarController()
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true)
        
    }
    
    private func addView(){
        [screenView,startButton, descriptionText, pageControl].forEach(view.setupView(_:))
    }
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            screenView.topAnchor.constraint(equalTo:view.topAnchor),
            screenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            screenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            screenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionText.centerXAnchor.constraint(equalTo: screenView.centerXAnchor),
            descriptionText.centerYAnchor.constraint(equalTo: screenView.centerYAnchor),
            descriptionText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            descriptionText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:0),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        applyConstraints()
    }
}
