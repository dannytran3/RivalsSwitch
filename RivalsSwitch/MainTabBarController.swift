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
        
        // Create all view controllers
        let homeVC = HomeViewController()
        let matchVC = CameraScanViewController()
        let historyVC = HistoryViewController()
        let profileVC = ProfileViewController()
        let settingsVC = SettingsViewController()
        let partyVC = PartyViewController()
        
        // Wrap each screen inside a navigation controller
        // This allows pushing new screens inside each tab
        let homeNav = UINavigationController(rootViewController: homeVC)
        let matchNav = UINavigationController(rootViewController: matchVC)
        let historyNav = UINavigationController(rootViewController: historyVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        let partyNav = UINavigationController(rootViewController: partyVC)
        
        // Change tab icons and labels using SF Symbols
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        matchNav.tabBarItem = UITabBarItem(title: "Match", image: UIImage(systemName: "camera.fill"), tag: 1)
        historyNav.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 2)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 3)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 4)
        partyNav.tabBarItem = UITabBarItem(title: "Party", image: UIImage(systemName: "person.2.fill"), tag: 5)
        
        //Attach all tabs to the tab bar controller
        viewControllers = [homeNav, matchNav, historyNav, profileNav, settingsNav, partyNav]
        
        // styling across the tab bar
        tabBar.applyAppStyle()
    }
}
