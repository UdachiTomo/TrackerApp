import UIKit

final class OnboardingViewControlller: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private lazy var pages: [UIViewController] = {
        return [firstPage, secondPage]
    } ()
    
    private lazy var firstPage: UIViewController = {
        let firstPage = UIViewController()
        let firstPageImage = "onboarding_screen"
        firstPage.view.assignbackground(image: firstPageImage)
        return firstPage
    } ()
    
    private lazy var secondPage: UIViewController = {
        let secondPage = UIViewController()
        let secondPageImage = "onboarding_screen_two"
        secondPage.view.assignbackground(image: secondPageImage)
        return secondPage
    } ()
    
    
    private lazy var firstPageButton: UIButton = {
        let startButton = UIButton()
        startButton.layer.cornerRadius = 15
        startButton.setTitle("Вот это технологии!", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        startButton.accessibilityIdentifier = "startButton"
        startButton.backgroundColor = .black
        startButton.addTarget(self, action: #selector(toMainView), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()
    
    private lazy var secondPageButton: UIButton = {
        let startButton = UIButton()
        startButton.layer.cornerRadius = 15
        startButton.setTitle("Вот это технологии!", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        startButton.accessibilityIdentifier = "startButton"
        startButton.backgroundColor = .black
        startButton.addTarget(self, action: #selector(toMainView), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()
    
    private lazy var descriptionFirstPageText: UILabel = {
        let descriptionText = UILabel()
        descriptionText.text = "Отслеживайте только то, что хотите"
        descriptionText.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        descriptionText.textColor = .ypBlack
        descriptionText.textAlignment = .center
        descriptionText.lineBreakMode = .byWordWrapping
        descriptionText.numberOfLines = 2
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        return descriptionText
    } ()
    
    private lazy var descriptionSecondPageText: UILabel = {
        let descriptionText = UILabel()
        descriptionText.text = "Даже если это не литры воды и йога"
        descriptionText.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        descriptionText.textColor = .ypBlack
        descriptionText.textAlignment = .center
        descriptionText.lineBreakMode = .byWordWrapping
        descriptionText.numberOfLines = 2
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        return descriptionText
    } ()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    } ()
    
    @objc private func toMainView() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarController()
        //UserDefaults.standard.set(true, forKey: "isChecked")
    }
    
    private func addFirstPage() {
        firstPage.view.addSubview(descriptionFirstPageText)
        firstPage.view.addSubview(firstPageButton)
        
            NSLayoutConstraint.activate([
                descriptionFirstPageText.bottomAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
                descriptionFirstPageText.centerXAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.centerXAnchor),
                descriptionFirstPageText.widthAnchor.constraint(equalToConstant: 343),
                
                firstPageButton.heightAnchor.constraint(equalToConstant: 60),
                firstPageButton.leadingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                firstPageButton.trailingAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                firstPageButton.bottomAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
            ])
    }
    
    private func addSecondPage() {
        secondPage.view.addSubview(descriptionSecondPageText)
        secondPage.view.addSubview(secondPageButton)
        
            NSLayoutConstraint.activate([
                descriptionSecondPageText.bottomAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
                descriptionSecondPageText.centerXAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.centerXAnchor),
                descriptionSecondPageText.widthAnchor.constraint(equalToConstant: 343),
                
                secondPageButton.heightAnchor.constraint(equalToConstant: 60),
                secondPageButton.leadingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                secondPageButton.trailingAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                secondPageButton.bottomAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.bottomAnchor, constant: -71)
            ])
    }
    
    private func addPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -155),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFirstPage()
        addPageControl()
        addSecondPage()
        if let first = pages.first { setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        dataSource = self
        delegate = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return pages.first
        }

        return pages[nextIndex]
    }
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool)
    {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}


