import SnapshotTesting
import XCTest
@testable import TrackerApp

final class TrackerAppTests: XCTestCase {

    func testTrackerViewInLightMode() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let trackerViewController = (vc.children.first as? UINavigationController)?.viewControllers.first
        guard let view = trackerViewController?.view else { return }
        assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackerViewInDarkMode() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let trackerViewController = (vc.children.first as? UINavigationController)?.viewControllers.first
        guard let view = trackerViewController?.view else { return }
        assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
