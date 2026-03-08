//
//  ProfileViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Profile Screen
//

import UIKit

class ProfileViewController: UIViewController {
    
    // UI Elements
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let statsCard = UIView()
    private let totalMatchesLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        // Gradient Background
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.appPrimaryBackground.cgColor,
            UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .appPrimaryAccent
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        view.addSubview(profileImageView)
        
        // Username Label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = UserSession.shared.username ?? "User"
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        // Stats Card
        statsCard.translatesAutoresizingMaskIntoConstraints = false
        statsCard.applyCardStyle()
        view.addSubview(statsCard)
        
        // Total Matches Label
        totalMatchesLabel.translatesAutoresizingMaskIntoConstraints = false
        let matchCount = MatchStore.shared.loadMatches().count
        totalMatchesLabel.text = "Total Matches: \(matchCount)"
        totalMatchesLabel.textAlignment = .center
        statsCard.addSubview(totalMatchesLabel)
        
        // Logout Button
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Username Label
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Stats Card
            statsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            statsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            statsCard.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 40),
            statsCard.heightAnchor.constraint(equalToConstant: 100),
            
            // Total Matches Label
            totalMatchesLabel.centerXAnchor.constraint(equalTo: statsCard.centerXAnchor),
            totalMatchesLabel.centerYAnchor.constraint(equalTo: statsCard.centerYAnchor),
            totalMatchesLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 20),
            totalMatchesLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -20),
            
            // Logout Button
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            logoutButton.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 40),
            logoutButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Profile"
        
        // Username Label
        usernameLabel.font = .appHeading2
        usernameLabel.textColor = .appPrimaryAccent
        
        // Total Matches Label
        totalMatchesLabel.font = .appBodyLarge
        totalMatchesLabel.textColor = .appPrimaryText
        
        // Logout Button - error style
        logoutButton.backgroundColor = .appErrorColor
        logoutButton.setTitleColor(.appPrimaryText, for: .normal)
        logoutButton.titleLabel?.font = .appButtonText
        logoutButton.layer.cornerRadius = 16
    }

    @objc private func logoutTapped() {
        UserSession.shared.logout()
        
        // Navigate back to landing inside nav so Sign up / I have an account can push
        if let windowScene = view.window?.windowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: LandingViewController())
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
