//
//  LaunchViewController.swift
//  RivalsSwitch
//
//  Launch screen – loading icon centered, original colors, no container
//

import UIKit

// Launch screen shown before the app transitions user to the landing page or main app
class LaunchViewController: UIViewController {
    
    private let iconImageView = UIImageView()
    private var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start the launch animation when the view is visible
        animateLaunch()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Keep the gradient sized correctly during layout changes
        gradientLayer?.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        // Add app background gradient
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.appPrimaryBackground.cgColor,
            UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Use the loading icon if it is available, else use the app icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        var image = UIImage(named: "LoadingIcon") ?? UIImage(named: "RS-icon")
        image = image?.withRenderingMode(.alwaysOriginal)
        iconImageView.image = image
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.alpha = 1
        view.addSubview(iconImageView)
        
        // Center the loading icon on screen
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // Adds a small fade animation before entering the app
    private func animateLaunch() {
        iconImageView.alpha = 0.9
        iconImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.iconImageView.alpha = 1
            self.iconImageView.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.transitionToApp()
            }
        }
    }
    
    // Sends the user either to the main app or the login/signup page
    private func transitionToApp() {
        guard let window = view.window else { return }
        if UserSession.shared.isLoggedIn {
            window.rootViewController = MainTabBarController()
        } else {
            window.rootViewController = UINavigationController(rootViewController: LandingViewController())
        }
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
    }
}
