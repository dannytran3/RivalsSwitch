//
//  RecommendationsViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Recommendations Screen
//

import UIKit

class RecommendationsViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let switch1Card = UIView()
    private let switch1HeroLabel = UILabel()
    private let switch1ReasonLabel = UILabel()
    private let switch2Card = UIView()
    private let switch2HeroLabel = UILabel()
    private let switch2ReasonLabel = UILabel()
    private let switch3Card = UIView()
    private let switch3HeroLabel = UILabel()
    private let switch3ReasonLabel = UILabel()
    private let saveMatchButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        
        // Load data
        switch1HeroLabel.text = MatchStore.shared.recommendedHero1.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero1
        switch1ReasonLabel.text = MatchStore.shared.recommendedReason1.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason1
        
        switch2HeroLabel.text = MatchStore.shared.recommendedHero2.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero2
        switch2ReasonLabel.text = MatchStore.shared.recommendedReason2.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason2
        
        switch3HeroLabel.text = MatchStore.shared.recommendedHero3.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero3
        switch3ReasonLabel.text = MatchStore.shared.recommendedReason3.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason3
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        saveMatchButton.updateGradientFrame()
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
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Recommendations"
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Recommendation Cards
        [switch1Card, switch2Card, switch3Card].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            card.applyCardStyle(elevated: card == switch1Card)
            contentView.addSubview(card)
        }
        
        // Hero Labels
        [switch1HeroLabel, switch2HeroLabel, switch3HeroLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        switch1Card.addSubview(switch1HeroLabel)
        switch2Card.addSubview(switch2HeroLabel)
        switch3Card.addSubview(switch3HeroLabel)
        
        // Reason Labels
        [switch1ReasonLabel, switch2ReasonLabel, switch3ReasonLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        switch1Card.addSubview(switch1ReasonLabel)
        switch2Card.addSubview(switch2ReasonLabel)
        switch3Card.addSubview(switch3ReasonLabel)
        
        // Save Match Button
        saveMatchButton.translatesAutoresizingMaskIntoConstraints = false
        saveMatchButton.setTitle("Save Match", for: .normal)
        saveMatchButton.addTarget(self, action: #selector(saveMatchTapped), for: .touchUpInside)
        contentView.addSubview(saveMatchButton)
        
        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        contentView.addSubview(backButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Card 1 (Top Recommendation - Elevated)
            switch1Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch1Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch1Card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            switch1Card.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            switch1HeroLabel.leadingAnchor.constraint(equalTo: switch1Card.leadingAnchor, constant: 20),
            switch1HeroLabel.trailingAnchor.constraint(equalTo: switch1Card.trailingAnchor, constant: -20),
            switch1HeroLabel.topAnchor.constraint(equalTo: switch1Card.topAnchor, constant: 20),
            
            switch1ReasonLabel.leadingAnchor.constraint(equalTo: switch1Card.leadingAnchor, constant: 20),
            switch1ReasonLabel.trailingAnchor.constraint(equalTo: switch1Card.trailingAnchor, constant: -20),
            switch1ReasonLabel.topAnchor.constraint(equalTo: switch1HeroLabel.bottomAnchor, constant: 12),
            switch1ReasonLabel.bottomAnchor.constraint(equalTo: switch1Card.bottomAnchor, constant: -20),
            
            // Card 2
            switch2Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch2Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch2Card.topAnchor.constraint(equalTo: switch1Card.bottomAnchor, constant: 16),
            switch2Card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            switch2HeroLabel.leadingAnchor.constraint(equalTo: switch2Card.leadingAnchor, constant: 20),
            switch2HeroLabel.trailingAnchor.constraint(equalTo: switch2Card.trailingAnchor, constant: -20),
            switch2HeroLabel.topAnchor.constraint(equalTo: switch2Card.topAnchor, constant: 16),
            
            switch2ReasonLabel.leadingAnchor.constraint(equalTo: switch2Card.leadingAnchor, constant: 20),
            switch2ReasonLabel.trailingAnchor.constraint(equalTo: switch2Card.trailingAnchor, constant: -20),
            switch2ReasonLabel.topAnchor.constraint(equalTo: switch2HeroLabel.bottomAnchor, constant: 8),
            switch2ReasonLabel.bottomAnchor.constraint(equalTo: switch2Card.bottomAnchor, constant: -16),
            
            // Card 3
            switch3Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch3Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch3Card.topAnchor.constraint(equalTo: switch2Card.bottomAnchor, constant: 16),
            switch3Card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            switch3HeroLabel.leadingAnchor.constraint(equalTo: switch3Card.leadingAnchor, constant: 20),
            switch3HeroLabel.trailingAnchor.constraint(equalTo: switch3Card.trailingAnchor, constant: -20),
            switch3HeroLabel.topAnchor.constraint(equalTo: switch3Card.topAnchor, constant: 16),
            
            switch3ReasonLabel.leadingAnchor.constraint(equalTo: switch3Card.leadingAnchor, constant: 20),
            switch3ReasonLabel.trailingAnchor.constraint(equalTo: switch3Card.trailingAnchor, constant: -20),
            switch3ReasonLabel.topAnchor.constraint(equalTo: switch3HeroLabel.bottomAnchor, constant: 8),
            switch3ReasonLabel.bottomAnchor.constraint(equalTo: switch3Card.bottomAnchor, constant: -16),
            
            // Save Match Button
            saveMatchButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            saveMatchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            saveMatchButton.topAnchor.constraint(equalTo: switch3Card.bottomAnchor, constant: 32),
            saveMatchButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            backButton.topAnchor.constraint(equalTo: saveMatchButton.bottomAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 56),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Recommendations"
        
        // Title Label
        titleLabel.font = .appHeading3
        titleLabel.textColor = .appPrimaryText
        
        // Hero labels
        switch1HeroLabel.applyHeading2Style()
        switch1HeroLabel.textColor = .appPrimaryAccent
        
        switch2HeroLabel.applyHeading3Style()
        switch2HeroLabel.textColor = .appPrimaryText
        
        switch3HeroLabel.applyHeading3Style()
        switch3HeroLabel.textColor = .appPrimaryText
        
        // Reason labels
        switch1ReasonLabel.applyBodyLargeStyle()
        switch1ReasonLabel.textColor = .appSecondaryText
        
        switch2ReasonLabel.applyBodyMediumStyle()
        switch2ReasonLabel.textColor = .appSecondaryText
        
        switch3ReasonLabel.applyBodyMediumStyle()
        switch3ReasonLabel.textColor = .appSecondaryText
        
        // Save Match button - gradient
        saveMatchButton.applyGradientStyle()
        
        // Back button - secondary
        backButton.applySecondaryStyle()
    }

    @objc private func saveMatchTapped() {
        MatchStore.shared.saveCurrentMatch()

        let alert = UIAlertController(title: "Saved", message: "Match added to history.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate back to home
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
