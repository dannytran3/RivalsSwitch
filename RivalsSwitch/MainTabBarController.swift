//
//  MainTabBarController.swift
//  RivalsSwitch
//
//  Fully Programmatic Tab Bar Controller
//

import UIKit

// Main tab bar that holds all primary screens of the app
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    // Creates each tab and assigns icons/navigation controllers
    private func setupTabBar() {
        
        // Create all view controllers (Party has its own tab after removing the old “More” hub)
        let homeVC = HomeViewController()
        let partyVC = PartyViewController()
        let matchVC = CameraScanViewController()
        let historyVC = HistoryViewController()
        let profileVC = ProfileViewController()
        
        // Wrap each screen inside a navigation controller
        // This allows pushing new screens inside each tab
        let homeNav = UINavigationController(rootViewController: homeVC)
        let partyNav = UINavigationController(rootViewController: partyVC)
        let matchNav = UINavigationController(rootViewController: matchVC)
        let historyNav = UINavigationController(rootViewController: historyVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        partyNav.tabBarItem = UITabBarItem(title: "Party", image: UIImage(systemName: "person.2.fill"), tag: 1)
        matchNav.tabBarItem = UITabBarItem(title: "Match", image: UIImage(systemName: "camera.fill"), tag: 2)
        historyNav.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 3)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 4)
        
        viewControllers = [homeNav, partyNav, matchNav, historyNav, profileNav]
        
        // styling across the tab bar
        tabBar.applyAppStyle()
    }
}
