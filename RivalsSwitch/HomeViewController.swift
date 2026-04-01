//
//  HomeViewController.swift
//  RivalsSwitch
//
//  Bold Landing Page – Fully Programmatic
//

import UIKit

// Main home screen shown after login, gives quick access to match scanning, history, and party features
class HomeViewController: UIViewController {

    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var gradientLayer: CAGradientLayer?
    
    // Section Headers
    private let quickActionsHeaderLabel = UILabel()
    private let recentHeaderLabel = UILabel()
    
    // Hero Section
    private let heroCard = UIView()
    private let logoImageView = UIImageView()
    // private let appNameLabel = UILabel()  // Removed per instructions
    private let taglineLabel = UILabel()
    private let userLabel = UILabel()
    
    // Primary CTA
    private let primaryCTACard = UIButton(type: .system)
    private let ctaTitleLabel = UILabel()
    private let ctaSubtitleLabel = UILabel()
    private let ctaIconView = UIImageView()
    private let ctaStack = UIStackView()
    
    // Quick Actions
    private let quickActionsStack = UIStackView()
    private let scanPhotoCard = UIButton(type: .system)
    private let manualEntryCard = UIButton(type: .system)
    
    // Recent Match
    private let recentMatchCard = UIButton(type: .system)
    private let recentMatchTitle = UILabel()
    private let recentMatchDetail = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        loadLastMatch()
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
        
        // ScrollView & ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 1. Hero Card
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.applyCardStyle()
        contentView.addSubview(heroCard)
        
        // App Logo Image View (replace appNameLabel)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "Logo")
        heroCard.addSubview(logoImageView)
        
        // appNameLabel setup removed per instructions
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        taglineLabel.text = "Scan to generate counter picks"
        taglineLabel.textAlignment = .left
        heroCard.addSubview(taglineLabel)
        
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.textAlignment = .left
        if let username = UserSession.shared.username {
            userLabel.text = "Signed in as: \(username)"
        } else {
            userLabel.text = "Signed in as: guest"
        }
        heroCard.addSubview(userLabel)

        // Primary CTA Card
        primaryCTACard.translatesAutoresizingMaskIntoConstraints = false
        primaryCTACard.applyGradientStyle()
        primaryCTACard.layer.cornerRadius = 28
        primaryCTACard.layer.masksToBounds = true
        primaryCTACard.addTarget(self, action: #selector(startNewMatchTapped), for: .touchUpInside)
        
        // Add shadow and border to make the button more visually obvious
        primaryCTACard.layer.shadowColor = UIColor.black.cgColor
        primaryCTACard.layer.shadowOpacity = 0.18
        primaryCTACard.layer.shadowOffset = CGSize(width: 0, height: 4)
        primaryCTACard.layer.shadowRadius = 14
        primaryCTACard.layer.borderColor = UIColor.appPrimaryAccent.withAlphaComponent(0.12).cgColor
        primaryCTACard.layer.borderWidth = 1
        
        contentView.addSubview(primaryCTACard)
        // CTA content stack, fixes padding/margins and keeps layout predictable
        ctaStack.translatesAutoresizingMaskIntoConstraints = false
        ctaStack.axis = .vertical
        ctaStack.alignment = .center
        ctaStack.distribution = .fill
        ctaStack.spacing = 10
        primaryCTACard.addSubview(ctaStack)

        ctaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ctaTitleLabel.text = "Start New Match"
        ctaTitleLabel.textAlignment = .center

        ctaIconView.translatesAutoresizingMaskIntoConstraints = false
        ctaIconView.contentMode = .scaleAspectFit
        ctaIconView.image = UIImage(systemName: "camera.viewfinder")

        ctaSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ctaSubtitleLabel.text = "Scan a scoreboard photo to auto-fill stats & enemy team"
        ctaSubtitleLabel.textAlignment = .center
        ctaSubtitleLabel.numberOfLines = 2
        ctaSubtitleLabel.lineBreakMode = .byWordWrapping

        ctaStack.addArrangedSubview(ctaTitleLabel)
        ctaStack.addArrangedSubview(ctaIconView)
        ctaStack.addArrangedSubview(ctaSubtitleLabel)

        NSLayoutConstraint.activate([
            ctaIconView.heightAnchor.constraint(equalToConstant: 22),
            ctaIconView.widthAnchor.constraint(equalToConstant: 22),
        ])

        // Quick Actions Header
        quickActionsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        quickActionsHeaderLabel.text = "Quick actions"
        contentView.addSubview(quickActionsHeaderLabel)

        // Quick action buttons row
        quickActionsStack.translatesAutoresizingMaskIntoConstraints = false
        quickActionsStack.axis = .horizontal
        quickActionsStack.spacing = 16
        quickActionsStack.distribution = .fillEqually
        contentView.addSubview(quickActionsStack)

        // Party button
        scanPhotoCard.translatesAutoresizingMaskIntoConstraints = false
        scanPhotoCard.applyCardStyle()
        scanPhotoCard.setTitle("Start a Party", for: .normal)
        scanPhotoCard.addTarget(self, action: #selector(startPartyTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "person.2")
            config.imagePlacement = .leading
            config.imagePadding = 8
            scanPhotoCard.configuration = config
            scanPhotoCard.tintColor = .appPrimaryText
        }
        quickActionsStack.addArrangedSubview(scanPhotoCard)

        // History button
        manualEntryCard.translatesAutoresizingMaskIntoConstraints = false
        manualEntryCard.applyCardStyle()
        manualEntryCard.setTitle("View History", for: .normal)
        manualEntryCard.addTarget(self, action: #selector(recentMatchTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "clock.arrow.circlepath")
            config.imagePlacement = .leading
            config.imagePadding = 8
            manualEntryCard.configuration = config
            manualEntryCard.tintColor = .appPrimaryText
        }
        quickActionsStack.addArrangedSubview(manualEntryCard)

        // Recent match section header
        recentHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        recentHeaderLabel.text = "Recent"
        contentView.addSubview(recentHeaderLabel)

        // 4. Recent Match Card
        recentMatchCard.translatesAutoresizingMaskIntoConstraints = false
        recentMatchCard.applyCardStyle()
        recentMatchCard.addTarget(self, action: #selector(recentMatchTapped), for: .touchUpInside)
        contentView.addSubview(recentMatchCard)

        recentMatchTitle.translatesAutoresizingMaskIntoConstraints = false
        recentMatchTitle.text = "Last Match"
        recentMatchTitle.textAlignment = .left
        recentMatchCard.addSubview(recentMatchTitle)

        recentMatchDetail.translatesAutoresizingMaskIntoConstraints = false
        recentMatchDetail.textAlignment = .left
        recentMatchDetail.numberOfLines = 0
        recentMatchCard.addSubview(recentMatchDetail)

        // Layout all sections
        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            logoImageView.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            logoImageView.centerXAnchor.constraint(equalTo: heroCard.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 84),
            logoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300),

            taglineLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            taglineLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            taglineLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),

            userLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 8),
            userLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            userLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            userLabel.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -20),

            primaryCTACard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 48),
            primaryCTACard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            primaryCTACard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            primaryCTACard.heightAnchor.constraint(equalToConstant: 124),
            ctaStack.topAnchor.constraint(equalTo: primaryCTACard.topAnchor, constant: 18),
            ctaStack.leadingAnchor.constraint(equalTo: primaryCTACard.leadingAnchor, constant: 24),
            ctaStack.trailingAnchor.constraint(equalTo: primaryCTACard.trailingAnchor, constant: -24),
            ctaStack.bottomAnchor.constraint(equalTo: primaryCTACard.bottomAnchor, constant: -18),

            quickActionsHeaderLabel.topAnchor.constraint(equalTo: primaryCTACard.bottomAnchor, constant: 20),
            quickActionsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            quickActionsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            quickActionsStack.topAnchor.constraint(equalTo: quickActionsHeaderLabel.bottomAnchor, constant: 12),
            quickActionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            quickActionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            quickActionsStack.heightAnchor.constraint(equalToConstant: 72),

            recentHeaderLabel.topAnchor.constraint(equalTo: quickActionsStack.bottomAnchor, constant: 22),
            recentHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            recentHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            recentMatchCard.topAnchor.constraint(equalTo: recentHeaderLabel.bottomAnchor, constant: 12),
            recentMatchCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            recentMatchCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            recentMatchTitle.topAnchor.constraint(equalTo: recentMatchCard.topAnchor, constant: 20),
            recentMatchTitle.leadingAnchor.constraint(equalTo: recentMatchCard.leadingAnchor, constant: 20),
            recentMatchTitle.trailingAnchor.constraint(equalTo: recentMatchCard.trailingAnchor, constant: -20),

            recentMatchDetail.topAnchor.constraint(equalTo: recentMatchTitle.bottomAnchor, constant: 6),
            recentMatchDetail.leadingAnchor.constraint(equalTo: recentMatchCard.leadingAnchor, constant: 20),
            recentMatchDetail.trailingAnchor.constraint(equalTo: recentMatchCard.trailingAnchor, constant: -20),
            recentMatchDetail.bottomAnchor.constraint(equalTo: recentMatchCard.bottomAnchor, constant: -20),
        ])
    }

    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Home"
        
        // Hero
        // appNameLabel.font = .appHeading2
        // appNameLabel.textColor = .appPrimaryAccent  // Removed per instructions
        
        taglineLabel.font = .appBodyLarge
        taglineLabel.textColor = .appPrimaryText
        userLabel.font = .appBodySmall
        userLabel.textColor = .appSecondaryText
        
        // CTA - make title bold for emphasis
        if #available(iOS 15.0, *) {
            // Build a bold variant of appHeading3 safely
            let baseFont = UIFont.appHeading3
            if let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
                ctaTitleLabel.font = UIFont(descriptor: boldDescriptor, size: baseFont.pointSize)
            } else {
                ctaTitleLabel.font = UIFont.boldSystemFont(ofSize: baseFont.pointSize)
            }
        } else {
            ctaTitleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.appHeading3.pointSize)
        }
        ctaTitleLabel.textColor = .appPrimaryText
        ctaIconView.tintColor = .appPrimaryText
        ctaSubtitleLabel.font = .appBodyMedium
        ctaSubtitleLabel.textColor = .appSecondaryText
        
        // Quick Actions
        scanPhotoCard.setTitleColor(.appPrimaryText, for: .normal)
        scanPhotoCard.titleLabel?.font = .appBodyLarge
        manualEntryCard.setTitleColor(.appPrimaryText, for: .normal)
        manualEntryCard.titleLabel?.font = .appBodyLarge
        
        // Recent Match
        recentMatchTitle.font = .appBodyLarge
        recentMatchTitle.textColor = .appPrimaryText
        recentMatchDetail.font = .appBodyMedium
        recentMatchDetail.textColor = .appPrimaryText

        // Section headers
        [quickActionsHeaderLabel, recentHeaderLabel].forEach { label in
            label.font = .appBodyLarge
            label.textColor = .appSecondaryText
        }
    }

    // Loads the most recently saved match and shows it on the home screen
    private func loadLastMatch() {
        let matches = MatchStore.shared.loadMatches()
        guard let last = matches.last else {
            recentMatchDetail.text = "No matches yet."
            return
        }
        recentMatchDetail.text = last
    }
    
    
    @objc private func startNewMatchTapped() {
        
        // Clear old match data before starting fresh
        MatchStore.shared.clearCurrentMatch()
        let cameraVC = CameraScanViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    @objc private func scanPhotoTapped() {
        let cameraVC = CameraScanViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    @objc private func enterManuallyTapped() {
        let manualVC = ConfirmMyStatsViewController()
        navigationController?.pushViewController(manualVC, animated: true)
    }
    
    @objc private func recentMatchTapped() {
        let historyVC = HistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc private func startPartyTapped() {
        // Navigate to Party tab (index 5)
        guard let tabBarController = self.tabBarController else {
            return
        }
        
        // Switch to Party tab - user will manually create party from there
        tabBarController.selectedIndex = 5
    }
}

