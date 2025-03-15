import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = UIColor.customWhite
        tabBar.tintColor = UIColor.customBlue
        tabBar.unselectedItemTintColor = UIColor.customGray
        tabBar.isTranslucent = false
        tabBar.layer.shadowColor = UIColor.customBlack.cgColor
        tabBar.layer.shadowOpacity = 1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.2)
        tabBar.layer.shadowRadius = 0.2
        tabBar.layer.masksToBounds = false
        
        let trackerViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackerItem"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticsItem"),
            selectedImage: nil
        )
        self.viewControllers = [trackerViewController, statisticsViewController]
    }

}

