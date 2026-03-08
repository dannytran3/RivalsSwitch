//
//  HomeViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Home Screen
//

import UIKit

class HomeViewController: UIViewController {
    
    // UI Elements
    private let welcomeLabel = UILabel()
    private let startMatchButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        startMatchButton.updateGradientFrame()
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
        
        // Welcome Label
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.textAlignment = .center
        if let username = UserSession.shared.username {
            welcomeLabel.text = "Welcome, \(username)"
        } else {
            welcomeLabel.text = "Welcome"
        }
        view.addSubview(welcomeLabel)
        
        // Start Match Button
        startMatchButton.translatesAutoresizingMaskIntoConstraints = false
        startMatchButton.setTitle("Start New Match", for: .normal)
        startMatchButton.addTarget(self, action: #selector(startNewMatchTapped), for: .touchUpInside)
        view.addSubview(startMatchButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Welcome Label
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Start Match Button
            startMatchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startMatchButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 60),
            startMatchButton.widthAnchor.constraint(equalToConstant: 280),
            startMatchButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Home"
        
        // Welcome label
        welcomeLabel.applyHeading2Style()
        welcomeLabel.textColor = .appPrimaryAccent
        
        // Start Match button - gradient
        startMatchButton.applyGradientStyle()
        startMatchButton.setTitle("Start New Match", for: .normal)
        startMatchButton.titleLabel?.font = .appButtonText
        startMatchButton.setTitleColor(.appPrimaryText, for: .normal)
        startMatchButton.layer.shadowColor = UIColor.appPrimaryAccent.cgColor
        startMatchButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        startMatchButton.layer.shadowRadius = 12
        startMatchButton.layer.shadowOpacity = 0.3
    }
    
    @objc private func startNewMatchTapped() {
        MatchStore.shared.clearCurrentMatch()
        let cameraVC = CameraScanViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}
