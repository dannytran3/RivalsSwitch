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
    private let welcomeLabel = UILabel()
    private let homeSubtitleLabel = UILabel()
    
    // Primary CTA (custom so gradient + subviews don’t eat touches like a system button)
    private let primaryCTACard = UIButton(type: .custom)
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
    private let recentMatchThumb = UIImageView()
    private let recentMatchTitle = UILabel()
    private let recentMatchDetail = UILabel()
    private let recentMatchTextStack = UIStackView()
    private let recentMatchRowStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        loadLastMatch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshWelcomeHeader()
        loadLastMatch()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        primaryCTACard.updateGradientFrame()
        updateScrollViewTabBarAvoidance(scrollView)
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
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true

        // 1. Hero Card
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.applyCardStyle()
        contentView.addSubview(heroCard)
        
        // App Logo Image View (replace appNameLabel)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "Logo")
        heroCard.addSubview(logoImageView)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 0
        heroCard.addSubview(welcomeLabel)
        
        homeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        homeSubtitleLabel.text = "Counter-picks, scoreboard scans, and party tools for Marvel Rivals."
        homeSubtitleLabel.textAlignment = .center
        homeSubtitleLabel.numberOfLines = 0
        heroCard.addSubview(homeSubtitleLabel)
        refreshWelcomeHeader()

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
        [ctaStack, ctaTitleLabel, ctaSubtitleLabel, ctaIconView].forEach { $0.isUserInteractionEnabled = false }

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
        scanPhotoCard.layer.cornerRadius = 16
        scanPhotoCard.layer.masksToBounds = true
        scanPhotoCard.addTarget(self, action: #selector(startPartyTapped), for: .touchUpInside)
        styleQuickActionButton(scanPhotoCard, title: "Party", subtitle: "Party tab", systemImage: "person.2.fill")
        quickActionsStack.addArrangedSubview(scanPhotoCard)

        // History button
        manualEntryCard.translatesAutoresizingMaskIntoConstraints = false
        manualEntryCard.layer.cornerRadius = 16
        manualEntryCard.layer.masksToBounds = true
        manualEntryCard.addTarget(self, action: #selector(recentMatchTapped), for: .touchUpInside)
        styleQuickActionButton(manualEntryCard, title: "History", subtitle: "Past matches", systemImage: "clock.fill")
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

        recentMatchThumb.translatesAutoresizingMaskIntoConstraints = false
        recentMatchThumb.contentMode = .scaleAspectFill
        recentMatchThumb.clipsToBounds = true
        recentMatchThumb.layer.cornerRadius = 10
        recentMatchThumb.layer.borderWidth = 1
        recentMatchThumb.layer.borderColor = UIColor.appBorderColor.cgColor
        recentMatchThumb.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        recentMatchThumb.isHidden = true

        recentMatchTitle.translatesAutoresizingMaskIntoConstraints = false
        recentMatchTitle.text = "Last Match"
        recentMatchTitle.textAlignment = .left

        recentMatchDetail.translatesAutoresizingMaskIntoConstraints = false
        recentMatchDetail.textAlignment = .left
        recentMatchDetail.numberOfLines = 0

        recentMatchTextStack.translatesAutoresizingMaskIntoConstraints = false
        recentMatchTextStack.axis = .vertical
        recentMatchTextStack.spacing = 6
        recentMatchTextStack.alignment = .leading
        recentMatchTextStack.addArrangedSubview(recentMatchTitle)
        recentMatchTextStack.addArrangedSubview(recentMatchDetail)

        recentMatchRowStack.axis = .horizontal
        recentMatchRowStack.spacing = 14
        recentMatchRowStack.alignment = .top
        recentMatchRowStack.translatesAutoresizingMaskIntoConstraints = false
        recentMatchRowStack.addArrangedSubview(recentMatchThumb)
        recentMatchRowStack.addArrangedSubview(recentMatchTextStack)
        recentMatchCard.addSubview(recentMatchRowStack)
        [recentMatchRowStack, recentMatchTextStack, recentMatchTitle, recentMatchDetail, recentMatchThumb].forEach { $0.isUserInteractionEnabled = false }

        // Layout all sections
        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            logoImageView.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            logoImageView.centerXAnchor.constraint(equalTo: heroCard.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 84),
            logoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 300),

            welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            welcomeLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            welcomeLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),

            homeSubtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            homeSubtitleLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            homeSubtitleLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            homeSubtitleLabel.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -20),

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
            quickActionsStack.heightAnchor.constraint(equalToConstant: 96),

            recentHeaderLabel.topAnchor.constraint(equalTo: quickActionsStack.bottomAnchor, constant: 22),
            recentHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            recentHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            recentMatchCard.topAnchor.constraint(equalTo: recentHeaderLabel.bottomAnchor, constant: 12),
            recentMatchCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            recentMatchCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            recentMatchRowStack.topAnchor.constraint(equalTo: recentMatchCard.topAnchor, constant: 18),
            recentMatchRowStack.leadingAnchor.constraint(equalTo: recentMatchCard.leadingAnchor, constant: 18),
            recentMatchRowStack.trailingAnchor.constraint(equalTo: recentMatchCard.trailingAnchor, constant: -18),
            recentMatchRowStack.bottomAnchor.constraint(equalTo: recentMatchCard.bottomAnchor, constant: -18),

            recentMatchThumb.widthAnchor.constraint(equalToConstant: 58),
            recentMatchThumb.heightAnchor.constraint(equalToConstant: 58),
            
            recentMatchCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Home"
        
        // Hero
        // appNameLabel.font = .appHeading2
        // appNameLabel.textColor = .appPrimaryAccent  // Removed per instructions
        
        welcomeLabel.font = .appHeading3
        welcomeLabel.textColor = .appPrimaryText
        homeSubtitleLabel.font = .appBodyMedium
        homeSubtitleLabel.textColor = .appSecondaryText
        
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

    /// Glass-style quick action tiles (iOS 15+ uses `UIButton.Configuration`).
    private func styleQuickActionButton(_ button: UIButton, title: String, subtitle: String, systemImage: String) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: systemImage)
            config.imagePlacement = .top
            config.imagePadding = 6
            config.titleAlignment = .center
            config.titleLineBreakMode = .byTruncatingTail
            config.subtitleLineBreakMode = .byTruncatingTail
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
            var titleAttr = AttributeContainer()
            titleAttr.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            titleAttr.foregroundColor = UIColor.appPrimaryText
            var subAttr = AttributeContainer()
            subAttr.font = UIFont.appBodySmall
            subAttr.foregroundColor = UIColor.appSecondaryText
            config.attributedTitle = AttributedString(title, attributes: titleAttr)
            config.attributedSubtitle = AttributedString(subtitle, attributes: subAttr)
            button.configuration = config
            button.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appBorderColor.cgColor
        } else {
            button.applyCardStyle()
            button.setTitle("\(title)\n\(subtitle)", for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(.appPrimaryText, for: .normal)
            button.setImage(UIImage(systemName: systemImage), for: .normal)
            button.tintColor = .appPrimaryAccent
        }
    }
    
    
    private func updateRecentMatchThumbnail(for summary: String) {
        MatchSummaryThumbnail.configureImageView(recentMatchThumb, summary: summary)
    }
    
    // Loads the most recently saved match and shows it on the home screen
    private func refreshWelcomeHeader() {
        let name = UserSession.shared.username?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty {
            welcomeLabel.text = "Welcome to RivalsSwitch"
        } else {
            welcomeLabel.text = "Welcome back, \(name)"
        }
    }
    
    private func loadLastMatch() {
        let matches = MatchStore.shared.loadMatches()
        guard let newest = matches.first else {
            recentMatchDetail.text = "No matches yet."
            recentMatchThumb.isHidden = true
            recentMatchThumb.image = nil
            return
        }
        recentMatchDetail.text = newest
        updateRecentMatchThumbnail(for: newest)
    }
    
    
    @objc private func startNewMatchTapped() {
        MatchStore.shared.clearCurrentMatch()
        if selectTabBarRoot(matching: CameraScanViewController.self) {
            return
        }
        let cameraVC = CameraScanViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    @objc private func scanPhotoTapped() {
        MatchStore.shared.clearCurrentMatch()
        if selectTabBarRoot(matching: CameraScanViewController.self) {
            return
        }
        navigationController?.pushViewController(CameraScanViewController(), animated: true)
    }
    
    @objc private func enterManuallyTapped() {
        let manualVC = ConfirmMyStatsViewController()
        navigationController?.pushViewController(manualVC, animated: true)
    }
    
    @objc private func recentMatchTapped() {
        if selectTabBarRoot(matching: HistoryViewController.self) {
            return
        }
        let historyVC = HistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc private func startPartyTapped() {
        openPartyScreen()
    }
}

extension UIViewController {
    /// Selects the tab whose navigation root matches `type`. Only pops to root when switching from another tab (keeps Party / SwiftUI state).
    @discardableResult
    func selectTabBarRoot(matching type: UIViewController.Type) -> Bool {
        guard let tabBar = tabBarController, let controllers = tabBar.viewControllers else { return false }
        for (index, vc) in controllers.enumerated() {
            guard let nav = vc as? UINavigationController else { continue }
            if nav.viewControllers.first.map({ $0.isKind(of: type) }) == true {
                let alreadyHere = (tabBar.selectedIndex == index)
                tabBar.selectedIndex = index
                if !alreadyHere {
                    nav.popToRootViewController(animated: false)
                }
                return true
            }
        }
        return false
    }
    
    /// Opens Party from a tab root, or pushes it if the Party tab was removed.
    func openPartyScreen() {
        if selectTabBarRoot(matching: PartyViewController.self) {
            return
        }
        navigationController?.pushViewController(PartyViewController(), animated: true)
    }
}

