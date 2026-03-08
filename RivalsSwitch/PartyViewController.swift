//
//  PartyViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Party Screen
//

import UIKit

class PartyViewController: UIViewController {
    
    // UI Elements
    private let inviteFriendButton = UIButton(type: .system)
    private let friendsLabel = UILabel()
    private let emptyStateLabel = UILabel()
    private let emptyStateSubLabel = UILabel()
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        inviteFriendButton.updateGradientFrame()
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
        
        // Invite Friend Button
        inviteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendButton.setTitle("Invite Friend", for: .normal)
        inviteFriendButton.addTarget(self, action: #selector(inviteFriendTapped), for: .touchUpInside)
        view.addSubview(inviteFriendButton)
        
        // Friends Label
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsLabel.text = "Friends"
        view.addSubview(friendsLabel)
        
        // Empty State
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No friends yet"
        emptyStateLabel.textAlignment = .center
        view.addSubview(emptyStateLabel)
        
        emptyStateSubLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateSubLabel.text = "Invite friends to share matches"
        emptyStateSubLabel.textAlignment = .center
        view.addSubview(emptyStateSubLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Invite Friend Button
            inviteFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            inviteFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            inviteFriendButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            inviteFriendButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Friends Label
            friendsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            friendsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            friendsLabel.topAnchor.constraint(equalTo: inviteFriendButton.bottomAnchor, constant: 40),
            
            // Empty State
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            emptyStateSubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateSubLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 12),
            emptyStateSubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateSubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Party"
        
        // Invite Friend Button - gradient
        inviteFriendButton.applyGradientStyle()
        
        // Friends Label
        friendsLabel.font = .appHeading3
        friendsLabel.textColor = .appPrimaryText
        
        // Empty State
        emptyStateLabel.font = .appHeading4
        emptyStateLabel.textColor = .appSecondaryText
        
        emptyStateSubLabel.font = .appBodyMedium
        emptyStateSubLabel.textColor = .appTertiaryText
    }
    
    @objc private func inviteFriendTapped() {
        // Placeholder for invite functionality
        let alert = UIAlertController(title: "Invite Friend", message: "Friend invitation feature coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
