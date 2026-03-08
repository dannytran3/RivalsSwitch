//
//  ConfirmMyStatsViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Confirm Stats Screen
//

import UIKit

class ConfirmMyStatsViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let heroTextField = UITextField()
    private let killsTextField = UITextField()
    private let deathsTextField = UITextField()
    private let assistsTextField = UITextField()
    private let doneButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        
        // Load data
        heroTextField.text = MatchStore.shared.currentHero
        killsTextField.text = MatchStore.shared.currentKills > 0 ? "\(MatchStore.shared.currentKills)" : ""
        deathsTextField.text = MatchStore.shared.currentDeaths > 0 ? "\(MatchStore.shared.currentDeaths)" : ""
        assistsTextField.text = MatchStore.shared.currentAssists > 0 ? "\(MatchStore.shared.currentAssists)" : ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        doneButton.updateGradientFrame()
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
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Confirm Your Stats"
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Hero Text Field
        heroTextField.translatesAutoresizingMaskIntoConstraints = false
        heroTextField.placeholder = "Hero Name"
        heroTextField.autocapitalizationType = .words
        view.addSubview(heroTextField)
        
        // Kills Text Field
        killsTextField.translatesAutoresizingMaskIntoConstraints = false
        killsTextField.placeholder = "Kills"
        killsTextField.keyboardType = .numberPad
        view.addSubview(killsTextField)
        
        // Deaths Text Field
        deathsTextField.translatesAutoresizingMaskIntoConstraints = false
        deathsTextField.placeholder = "Deaths"
        deathsTextField.keyboardType = .numberPad
        view.addSubview(deathsTextField)
        
        // Assists Text Field
        assistsTextField.translatesAutoresizingMaskIntoConstraints = false
        assistsTextField.placeholder = "Assists"
        assistsTextField.keyboardType = .numberPad
        view.addSubview(assistsTextField)
        
        // Done Button
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // Hero Field
            heroTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            heroTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            heroTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            heroTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Kills Field
            killsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            killsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            killsTextField.topAnchor.constraint(equalTo: heroTextField.bottomAnchor, constant: 20),
            killsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Deaths Field
            deathsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            deathsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            deathsTextField.topAnchor.constraint(equalTo: killsTextField.bottomAnchor, constant: 20),
            deathsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Assists Field
            assistsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            assistsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            assistsTextField.topAnchor.constraint(equalTo: deathsTextField.bottomAnchor, constant: 20),
            assistsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Done Button
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            doneButton.topAnchor.constraint(equalTo: assistsTextField.bottomAnchor, constant: 40),
            doneButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Text field observers
        [heroTextField, killsTextField, deathsTextField, assistsTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        }
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Confirm Stats"
        
        // Title Label
        titleLabel.font = .appHeading3
        titleLabel.textColor = .appPrimaryText
        
        // Text fields with glassmorphism
        heroTextField.applyGlassmorphismStyle()
        killsTextField.applyGlassmorphismStyle()
        deathsTextField.applyGlassmorphismStyle()
        assistsTextField.applyGlassmorphismStyle()
        
        // Done button - gradient
        doneButton.applyGradientStyle()
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.updateFocusState(true)
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
    }

    @objc private func doneTapped() {
        MatchStore.shared.currentHero = heroTextField.text ?? ""
        MatchStore.shared.currentKills = Int(killsTextField.text ?? "") ?? 0
        MatchStore.shared.currentDeaths = Int(deathsTextField.text ?? "") ?? 0
        MatchStore.shared.currentAssists = Int(assistsTextField.text ?? "") ?? 0

        // Navigate to Confirm Enemy Team
        let confirmEnemyVC = ConfirmEnemyTeamViewController()
        navigationController?.pushViewController(confirmEnemyVC, animated: true)
    }
}
