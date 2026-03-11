//
//  ConfirmEnemyTeamViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Confirm Enemy Team Screen
//

import UIKit

class ConfirmEnemyTeamViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let enemy1TextField = UITextField()
    private let enemy2TextField = UITextField()
    private let enemy3TextField = UITextField()
    private let enemy4TextField = UITextField()
    private let enemy5TextField = UITextField()
    private let enemy6TextField = UITextField()
    private let doneButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        
        // Load data
        enemy1TextField.text = MatchStore.shared.enemy1
        enemy2TextField.text = MatchStore.shared.enemy2
        enemy3TextField.text = MatchStore.shared.enemy3
        enemy4TextField.text = MatchStore.shared.enemy4
        enemy5TextField.text = MatchStore.shared.enemy5
        enemy6TextField.text = MatchStore.shared.enemy6
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
        
        // Scroll View for content
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Confirm Enemy Team"
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Enemy Text Fields
        let textFields = [enemy1TextField, enemy2TextField, enemy3TextField, 
                         enemy4TextField, enemy5TextField, enemy6TextField]
        
        textFields.forEach { textField in
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.autocapitalizationType = .words
            contentView.addSubview(textField)
        }
        
        // Done Button
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
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
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40)
        ])
        
        // Layout enemy fields
        var previousView: UIView = titleLabel
        textFields.enumerated().forEach { index, textField in
            textField.placeholder = "Enemy \(index + 1)"
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                textField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                textField.heightAnchor.constraint(equalToConstant: 56)
            ])
            previousView = textField
        }
        
        // Done Button
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            doneButton.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 40),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Text field observers
        textFields.forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        }
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Confirm Enemy Team"
        
        // Title Label
        titleLabel.font = .appHeading3
        titleLabel.textColor = .appPrimaryText
        
        // Text fields with glassmorphism
        [enemy1TextField, enemy2TextField, enemy3TextField, 
         enemy4TextField, enemy5TextField, enemy6TextField].forEach { textField in
            textField.applyGlassmorphismStyle()
        }
        
        // Done button, gradient
        doneButton.applyGradientStyle()
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.updateFocusState(true)
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
    }

    @objc private func doneTapped() {
        MatchStore.shared.enemy1 = enemy1TextField.text ?? ""
        MatchStore.shared.enemy2 = enemy2TextField.text ?? ""
        MatchStore.shared.enemy3 = enemy3TextField.text ?? ""
        MatchStore.shared.enemy4 = enemy4TextField.text ?? ""
        MatchStore.shared.enemy5 = enemy5TextField.text ?? ""
        MatchStore.shared.enemy6 = enemy6TextField.text ?? ""

        let enemyTeam = [
            MatchStore.shared.enemy1,
            MatchStore.shared.enemy2,
            MatchStore.shared.enemy3,
            MatchStore.shared.enemy4,
            MatchStore.shared.enemy5,
            MatchStore.shared.enemy6
        ]

        let recs = RecommendationEngine.generateRecommendations(
            hero: MatchStore.shared.currentHero,
            kills: MatchStore.shared.currentKills,
            deaths: MatchStore.shared.currentDeaths,
            assists: MatchStore.shared.currentAssists,
            enemyTeam: enemyTeam
        )

        if recs.count > 0 {
            MatchStore.shared.recommendedHero1 = recs[0].0
            MatchStore.shared.recommendedReason1 = recs[0].1
        }

        if recs.count > 1 {
            MatchStore.shared.recommendedHero2 = recs[1].0
            MatchStore.shared.recommendedReason2 = recs[1].1
        }

        if recs.count > 2 {
            MatchStore.shared.recommendedHero3 = recs[2].0
            MatchStore.shared.recommendedReason3 = recs[2].1
        }

        // Navigate to Recommendations
        let recommendationsVC = RecommendationsViewController()
        navigationController?.pushViewController(recommendationsVC, animated: true)
    }
}
