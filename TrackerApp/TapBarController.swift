import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
//        super.awakeFromNib()
//        view.backgroundColor = .systemBackground
//        UITabBar.appearance().barTintColor = .systemBackground
//        tabBar.tintColor = .label
//        setupViewControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViewControllers()
        setupTabBar()
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createNavController(for: TrackersViewController(), title: "", image: UIImage(named: "record_circle_fill") ?? UIImage()),
            createNavController(for: TrackersViewController(), title: "", image: UIImage(named: "hare_fill") ?? UIImage())
        ]
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.selectionIndicatorTintColor = .blue
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                                      title: String,
                                                      image: UIImage) -> UIViewController {
            let navController = UINavigationController(rootViewController: rootViewController)
            navController.tabBarItem.title = title
            navController.tabBarItem.image = image
            navController.navigationBar.prefersLargeTitles = true
            rootViewController.navigationItem.title = title
            return navController
        }
}

