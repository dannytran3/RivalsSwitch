//
//  SettingsViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Settings Screen
//

import UIKit

class SettingsViewController: UIViewController {
    
    // UI Elements
    private let messagingToneCard = UIView()
    private let messagingToneLabel = UILabel()
    private let messagingToneSegmentedControl = UISegmentedControl(items: ["Direct", "Neutral", "Encouraging"])
    private let messagingToneDescription = UILabel()
    
    private let recommendationStyleCard = UIView()
    private let recommendationStyleLabel = UILabel()
    private let recommendationStyleSegmentedControl = UISegmentedControl(items: ["Only Critical", "Balanced", "Always Optimal"])
    private let recommendationStyleDescription = UILabel()
    
    private let saveButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        loadSettings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        saveButton.updateGradientFrame()
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
        
        // Messaging Tone Card
        messagingToneCard.translatesAutoresizingMaskIntoConstraints = false
        messagingToneCard.applyCardStyle()
        contentView.addSubview(messagingToneCard)
        
        messagingToneLabel.translatesAutoresizingMaskIntoConstraints = false
        messagingToneLabel.text = "Messaging Tone"
        messagingToneCard.addSubview(messagingToneLabel)
        
        messagingToneSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        messagingToneSegmentedControl.selectedSegmentIndex = 1 // Default: Neutral
        messagingToneCard.addSubview(messagingToneSegmentedControl)
        
        messagingToneDescription.translatesAutoresizingMaskIntoConstraints = false
        messagingToneDescription.text = "Controls how the app phrases messages"
        messagingToneDescription.numberOfLines = 0
        messagingToneCard.addSubview(messagingToneDescription)
        
        // Recommendation Style Card
        recommendationStyleCard.translatesAutoresizingMaskIntoConstraints = false
        recommendationStyleCard.applyCardStyle()
        contentView.addSubview(recommendationStyleCard)
        
        recommendationStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationStyleLabel.text = "Recommendation Style"
        recommendationStyleCard.addSubview(recommendationStyleLabel)
        
        recommendationStyleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        recommendationStyleSegmentedControl.selectedSegmentIndex = 1 // Default: Balanced
        recommendationStyleCard.addSubview(recommendationStyleSegmentedControl)
        
        recommendationStyleDescription.translatesAutoresizingMaskIntoConstraints = false
        recommendationStyleDescription.text = "Controls how often switches are suggested"
        recommendationStyleDescription.numberOfLines = 0
        recommendationStyleCard.addSubview(recommendationStyleDescription)
        
        // Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
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
            
            // Messaging Tone Card
            messagingToneCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            messagingToneCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            messagingToneCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            
            messagingToneLabel.leadingAnchor.constraint(equalTo: messagingToneCard.leadingAnchor, constant: 20),
            messagingToneLabel.trailingAnchor.constraint(equalTo: messagingToneCard.trailingAnchor, constant: -20),
            messagingToneLabel.topAnchor.constraint(equalTo: messagingToneCard.topAnchor, constant: 20),
            
            messagingToneSegmentedControl.leadingAnchor.constraint(equalTo: messagingToneCard.leadingAnchor, constant: 20),
            messagingToneSegmentedControl.trailingAnchor.constraint(equalTo: messagingToneCard.trailingAnchor, constant: -20),
            messagingToneSegmentedControl.topAnchor.constraint(equalTo: messagingToneLabel.bottomAnchor, constant: 16),
            
            messagingToneDescription.leadingAnchor.constraint(equalTo: messagingToneCard.leadingAnchor, constant: 20),
            messagingToneDescription.trailingAnchor.constraint(equalTo: messagingToneCard.trailingAnchor, constant: -20),
            messagingToneDescription.topAnchor.constraint(equalTo: messagingToneSegmentedControl.bottomAnchor, constant: 12),
            messagingToneDescription.bottomAnchor.constraint(equalTo: messagingToneCard.bottomAnchor, constant: -20),
            
            // Recommendation Style Card
            recommendationStyleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            recommendationStyleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            recommendationStyleCard.topAnchor.constraint(equalTo: messagingToneCard.bottomAnchor, constant: 20),
            
            recommendationStyleLabel.leadingAnchor.constraint(equalTo: recommendationStyleCard.leadingAnchor, constant: 20),
            recommendationStyleLabel.trailingAnchor.constraint(equalTo: recommendationStyleCard.trailingAnchor, constant: -20),
            recommendationStyleLabel.topAnchor.constraint(equalTo: recommendationStyleCard.topAnchor, constant: 20),
            
            recommendationStyleSegmentedControl.leadingAnchor.constraint(equalTo: recommendationStyleCard.leadingAnchor, constant: 20),
            recommendationStyleSegmentedControl.trailingAnchor.constraint(equalTo: recommendationStyleCard.trailingAnchor, constant: -20),
            recommendationStyleSegmentedControl.topAnchor.constraint(equalTo: recommendationStyleLabel.bottomAnchor, constant: 16),
            
            recommendationStyleDescription.leadingAnchor.constraint(equalTo: recommendationStyleCard.leadingAnchor, constant: 20),
            recommendationStyleDescription.trailingAnchor.constraint(equalTo: recommendationStyleCard.trailingAnchor, constant: -20),
            recommendationStyleDescription.topAnchor.constraint(equalTo: recommendationStyleSegmentedControl.bottomAnchor, constant: 12),
            recommendationStyleDescription.bottomAnchor.constraint(equalTo: recommendationStyleCard.bottomAnchor, constant: -20),
            
            // Save Button
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            saveButton.topAnchor.constraint(equalTo: recommendationStyleCard.bottomAnchor, constant: 32),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Settings"
        
        // Labels
        messagingToneLabel.font = .appHeading4
        messagingToneLabel.textColor = .appPrimaryText
        
        recommendationStyleLabel.font = .appHeading4
        recommendationStyleLabel.textColor = .appPrimaryText
        
        // Descriptions
        messagingToneDescription.font = .appBodySmall
        messagingToneDescription.textColor = .appTertiaryText
        
        recommendationStyleDescription.font = .appBodySmall
        recommendationStyleDescription.textColor = .appTertiaryText
        
        // Segmented Controls
        styleSegmentedControl(messagingToneSegmentedControl)
        styleSegmentedControl(recommendationStyleSegmentedControl)
        
        // Save Button
        saveButton.applyGradientStyle()
    }
    
    private func styleSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.backgroundColor = .appTertiaryBackground
        segmentedControl.selectedSegmentTintColor = .appPrimaryAccent
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.appPrimaryText,
            .font: UIFont.appBodyMedium
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.appPrimaryText,
            .font: UIFont.appBodyMedium
        ], for: .selected)
    }
    
    private func loadSettings() {
        // Load saved settings from UserDefaults
        let toneIndex = UserDefaults.standard.integer(forKey: "messagingTone")
        if toneIndex >= 0 && toneIndex < 3 {
            messagingToneSegmentedControl.selectedSegmentIndex = toneIndex
        }
        
        let styleIndex = UserDefaults.standard.integer(forKey: "recommendationStyle")
        if styleIndex >= 0 && styleIndex < 3 {
            recommendationStyleSegmentedControl.selectedSegmentIndex = styleIndex
        }
    }
    
    @objc private func saveTapped() {
        // Save settings
        UserDefaults.standard.set(messagingToneSegmentedControl.selectedSegmentIndex, forKey: "messagingTone")
        UserDefaults.standard.set(recommendationStyleSegmentedControl.selectedSegmentIndex, forKey: "recommendationStyle")
        
        let alert = UIAlertController(title: "Saved", message: "Settings have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
