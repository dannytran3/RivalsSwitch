//
//  LaunchViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Animated Launch Screen
//

import UIKit

class LaunchViewController: UIViewController {
    
    // UI Elements
    private let iconImageView = UIImageView()
    private var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLaunch()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        // Add gradient background
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.appPrimaryBackground.cgColor,
            UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Setup icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let iconImage = UIImage(named: "AppIcon") ?? UIImage(named: "RS-icon") {
            iconImageView.image = iconImage
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.alpha = 0
        iconImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(iconImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func animateLaunch() {
        // Fade in and scale up animation
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: {
            self.iconImageView.alpha = 1.0
            self.iconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { _ in
            // Pulse animation
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.iconImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
            
            // Transition to landing screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.transitionToApp()
            }
        }
    }
    
    private func transitionToApp() {
        // Check if user is logged in
        if UserSession.shared.isLoggedIn {
            // Navigate to main app
            if let windowScene = view.window?.windowScene,
               let window = windowScene.windows.first {
                window.rootViewController = MainTabBarController()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        } else {
            // Navigate to landing screen
            if let windowScene = view.window?.windowScene,
               let window = windowScene.windows.first {
                window.rootViewController = LandingViewController()
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}
