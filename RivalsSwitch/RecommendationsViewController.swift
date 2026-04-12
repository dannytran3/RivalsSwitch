//
//  RecommendationsViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Recommendations Screen
//

import UIKit

class RecommendationsViewController: UIViewController {
    
    private let switch1Card = UIView()
    private let switch1Portrait = UIImageView()
    private let switch1CrownView = UIImageView()
    private let switch1HeroRow = UIStackView()
    private let switch1HeroLabel = UILabel()
    private let switch1ReasonLabel = UILabel()
    private let switch2Card = UIView()
    private let switch2Portrait = UIImageView()
    private let switch2HeroLabel = UILabel()
    private let switch2ReasonLabel = UILabel()
    private let switch3Card = UIView()
    private let switch3Portrait = UIImageView()
    private let switch3HeroLabel = UILabel()
    private let switch3ReasonLabel = UILabel()
    private let saveMatchButton = UIButton(type: .custom)
    private let backButton = UIButton(type: .custom)
    private let potentialTeamUpButton = UIButton(type: .custom)
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        
        switch1HeroLabel.text = MatchStore.shared.recommendedHero1.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero1
        switch1ReasonLabel.text = MatchStore.shared.recommendedReason1.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason1
        
        switch2HeroLabel.text = MatchStore.shared.recommendedHero2.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero2
        switch2ReasonLabel.text = MatchStore.shared.recommendedReason2.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason2
        
        switch3HeroLabel.text = MatchStore.shared.recommendedHero3.isEmpty ? "No recommendation" : MatchStore.shared.recommendedHero3
        switch3ReasonLabel.text = MatchStore.shared.recommendedReason3.isEmpty ? "Not enough data" : MatchStore.shared.recommendedReason3
        
        refreshRecommendationPortraits()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        updateScrollViewTabBarAvoidance(scrollView)
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.appPrimaryBackground.cgColor,
            UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let topPortraitSize: CGFloat = 108
        let secondaryPortraitSize: CGFloat = 68
        
        func stylePortrait(_ iv: UIImageView) {
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 14
            iv.layer.borderWidth = 1
            iv.layer.borderColor = UIColor.appBorderColor.cgColor
            iv.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        }
        
        func styleHeroLabel(_ label: UILabel) {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.85
        }
        
        func styleReasonLabel(_ label: UILabel) {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .natural
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        [switch1Card, switch2Card, switch3Card].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            card.applyCardStyle(elevated: card == switch1Card)
            contentView.addSubview(card)
        }
        
        [switch1Portrait, switch2Portrait, switch3Portrait].forEach(stylePortrait)
        [switch1HeroLabel, switch2HeroLabel, switch3HeroLabel].forEach(styleHeroLabel)
        [switch1ReasonLabel, switch2ReasonLabel, switch3ReasonLabel].forEach(styleReasonLabel)
        
        switch1CrownView.translatesAutoresizingMaskIntoConstraints = false
        switch1CrownView.image = UIImage(systemName: "crown.fill")
        switch1CrownView.tintColor = UIColor.appPrimaryAccent
        switch1CrownView.contentMode = .scaleAspectFit
        switch1CrownView.setContentHuggingPriority(.required, for: .horizontal)
        
        switch1HeroRow.translatesAutoresizingMaskIntoConstraints = false
        switch1HeroRow.axis = .horizontal
        switch1HeroRow.spacing = 10
        switch1HeroRow.alignment = .center
        switch1HeroRow.addArrangedSubview(switch1CrownView)
        switch1HeroRow.addArrangedSubview(switch1HeroLabel)
        
        switch1Card.addSubview(switch1Portrait)
        switch1Card.addSubview(switch1HeroRow)
        switch1Card.addSubview(switch1ReasonLabel)
        switch2Card.addSubview(switch2Portrait)
        switch2Card.addSubview(switch2HeroLabel)
        switch2Card.addSubview(switch2ReasonLabel)
        switch3Card.addSubview(switch3Portrait)
        switch3Card.addSubview(switch3HeroLabel)
        switch3Card.addSubview(switch3ReasonLabel)
        
        saveMatchButton.translatesAutoresizingMaskIntoConstraints = false
        saveMatchButton.setTitle("Save Match", for: .normal)
        saveMatchButton.addTarget(self, action: #selector(saveMatchTapped), for: .touchUpInside)
        contentView.addSubview(saveMatchButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        contentView.addSubview(backButton)
        
        potentialTeamUpButton.translatesAutoresizingMaskIntoConstraints = false
        potentialTeamUpButton.setTitle("Potential Team-Up", for: .normal)
        potentialTeamUpButton.addTarget(self, action: #selector(potentialTeamUpTapped), for: .touchUpInside)
        contentView.addSubview(potentialTeamUpButton)
        
        let side: CGFloat = 20
        let topPad: CGFloat = 16
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            switch1Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch1Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch1Card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            switch1Portrait.topAnchor.constraint(equalTo: switch1Card.topAnchor, constant: topPad),
            switch1Portrait.centerXAnchor.constraint(equalTo: switch1Card.centerXAnchor),
            switch1Portrait.widthAnchor.constraint(equalToConstant: topPortraitSize),
            switch1Portrait.heightAnchor.constraint(equalToConstant: topPortraitSize),
            
            switch1CrownView.widthAnchor.constraint(equalToConstant: 28),
            switch1CrownView.heightAnchor.constraint(equalToConstant: 26),
            
            switch1HeroRow.topAnchor.constraint(equalTo: switch1Portrait.bottomAnchor, constant: 14),
            switch1HeroRow.centerXAnchor.constraint(equalTo: switch1Card.centerXAnchor),
            switch1HeroRow.leadingAnchor.constraint(greaterThanOrEqualTo: switch1Card.leadingAnchor, constant: side),
            switch1HeroRow.trailingAnchor.constraint(lessThanOrEqualTo: switch1Card.trailingAnchor, constant: -side),
            
            switch1ReasonLabel.topAnchor.constraint(equalTo: switch1HeroRow.bottomAnchor, constant: 12),
            switch1ReasonLabel.leadingAnchor.constraint(equalTo: switch1Card.leadingAnchor, constant: side),
            switch1ReasonLabel.trailingAnchor.constraint(equalTo: switch1Card.trailingAnchor, constant: -side),
            switch1ReasonLabel.bottomAnchor.constraint(equalTo: switch1Card.bottomAnchor, constant: -topPad),
            
            switch2Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch2Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch2Card.topAnchor.constraint(equalTo: switch1Card.bottomAnchor, constant: 16),
            
            switch2Portrait.topAnchor.constraint(equalTo: switch2Card.topAnchor, constant: topPad),
            switch2Portrait.centerXAnchor.constraint(equalTo: switch2Card.centerXAnchor),
            switch2Portrait.widthAnchor.constraint(equalToConstant: secondaryPortraitSize),
            switch2Portrait.heightAnchor.constraint(equalToConstant: secondaryPortraitSize),
            
            switch2HeroLabel.topAnchor.constraint(equalTo: switch2Portrait.bottomAnchor, constant: 12),
            switch2HeroLabel.leadingAnchor.constraint(equalTo: switch2Card.leadingAnchor, constant: side),
            switch2HeroLabel.trailingAnchor.constraint(equalTo: switch2Card.trailingAnchor, constant: -side),
            
            switch2ReasonLabel.topAnchor.constraint(equalTo: switch2HeroLabel.bottomAnchor, constant: 12),
            switch2ReasonLabel.leadingAnchor.constraint(equalTo: switch2Card.leadingAnchor, constant: side),
            switch2ReasonLabel.trailingAnchor.constraint(equalTo: switch2Card.trailingAnchor, constant: -side),
            switch2ReasonLabel.bottomAnchor.constraint(equalTo: switch2Card.bottomAnchor, constant: -topPad),
            
            switch3Card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            switch3Card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            switch3Card.topAnchor.constraint(equalTo: switch2Card.bottomAnchor, constant: 16),
            
            switch3Portrait.topAnchor.constraint(equalTo: switch3Card.topAnchor, constant: topPad),
            switch3Portrait.centerXAnchor.constraint(equalTo: switch3Card.centerXAnchor),
            switch3Portrait.widthAnchor.constraint(equalToConstant: secondaryPortraitSize),
            switch3Portrait.heightAnchor.constraint(equalToConstant: secondaryPortraitSize),
            
            switch3HeroLabel.topAnchor.constraint(equalTo: switch3Portrait.bottomAnchor, constant: 12),
            switch3HeroLabel.leadingAnchor.constraint(equalTo: switch3Card.leadingAnchor, constant: side),
            switch3HeroLabel.trailingAnchor.constraint(equalTo: switch3Card.trailingAnchor, constant: -side),
            
            switch3ReasonLabel.topAnchor.constraint(equalTo: switch3HeroLabel.bottomAnchor, constant: 12),
            switch3ReasonLabel.leadingAnchor.constraint(equalTo: switch3Card.leadingAnchor, constant: side),
            switch3ReasonLabel.trailingAnchor.constraint(equalTo: switch3Card.trailingAnchor, constant: -side),
            switch3ReasonLabel.bottomAnchor.constraint(equalTo: switch3Card.bottomAnchor, constant: -topPad),
            
            potentialTeamUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            potentialTeamUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            potentialTeamUpButton.topAnchor.constraint(equalTo: switch3Card.bottomAnchor, constant: 32),
            potentialTeamUpButton.heightAnchor.constraint(equalToConstant: 56),

            saveMatchButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            saveMatchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            saveMatchButton.topAnchor.constraint(equalTo: potentialTeamUpButton.bottomAnchor, constant: 16),
            saveMatchButton.heightAnchor.constraint(equalToConstant: 56),

            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            backButton.topAnchor.constraint(equalTo: saveMatchButton.bottomAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 56),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)

            
        ])
    }
    
    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Recommendations"
        
        switch1HeroLabel.applyHeading2Style()
        switch1HeroLabel.textColor = .appPrimaryAccent
        
        switch2HeroLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        switch2HeroLabel.textColor = .appPrimaryText
        
        switch3HeroLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        switch3HeroLabel.textColor = .appPrimaryText
        
        switch1ReasonLabel.applyBodyLargeStyle()
        switch1ReasonLabel.textColor = .appSecondaryText
        switch1ReasonLabel.numberOfLines = 0
        switch1ReasonLabel.lineBreakMode = .byWordWrapping
        
        switch2ReasonLabel.applyBodyMediumStyle()
        switch2ReasonLabel.textColor = .appSecondaryText
        switch2ReasonLabel.numberOfLines = 0
        switch2ReasonLabel.lineBreakMode = .byWordWrapping
        
        switch3ReasonLabel.applyBodyMediumStyle()
        switch3ReasonLabel.textColor = .appSecondaryText
        switch3ReasonLabel.numberOfLines = 0
        switch3ReasonLabel.lineBreakMode = .byWordWrapping
        
        saveMatchButton.applySolidPrimaryCTAStyle()
        backButton.applySecondaryStyle()
        potentialTeamUpButton.applySecondaryStyle()
    }
    
    private func heroDisplayName(for label: UILabel) -> String {
        let t = label.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if t.isEmpty || t == "No recommendation" { return "" }
        if t == "Stay Current Hero" {
            return MatchStore.shared.currentHero.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return t
    }
    
    private func refreshRecommendationPortraits() {
        let pairs: [(UIImageView, UILabel)] = [
            (switch1Portrait, switch1HeroLabel),
            (switch2Portrait, switch2HeroLabel),
            (switch3Portrait, switch3HeroLabel)
        ]
        for (iv, heroLabel) in pairs {
            let name = heroDisplayName(for: heroLabel)
            if name.isEmpty {
                iv.isHidden = true
                iv.image = nil
                continue
            }
            iv.isHidden = false
            HeroRegistry.shared.configurePortraitImageView(iv, heroDisplayName: name)
        }
        updateTopCrownVisibility()
    }
    
    private func updateTopCrownVisibility() {
        let name = heroDisplayName(for: switch1HeroLabel)
        let show = !name.isEmpty
        switch1CrownView.isHidden = !show
    }

    @objc private func saveMatchTapped() {
        MatchStore.shared.saveCurrentMatch()

        let alert = UIAlertController(title: "Saved", message: "Match added to history.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            _ = self.selectTabBarRoot(matching: HistoryViewController.self)
        })
        present(alert, animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func potentialTeamUpTapped() {
        let vc = PotentialTeamUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
