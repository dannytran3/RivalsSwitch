//
//  ProfileViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Profile Screen
//

import UIKit

class ProfileViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var gradientLayer: CAGradientLayer?
    
    // Compact Header
    private let headerCard = UIView()
    private let avatarImageView = UIImageView()
    private let headerStack = UIStackView()
    private let usernameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)
    
    // Stats Grid
    private let statsHeaderLabel = UILabel()
    private let statsGrid = UIStackView()
    private let matchesStatChip = UIView()
    private let avgKdaStatChip = UIView()
    private let swapPicksStatChip = UIView()
    private let lastHeroStatChip = UIView()
    
    private var matchesValueLabel: UILabel?
    private var avgKdaValueLabel: UILabel?
    private var swapPicksValueLabel: UILabel?
    private var lastHeroPortraitView: UIImageView?
    private var lastHeroNameLabel: UILabel?
    
    // Quick Actions (each row is its own card, like separate preference tiles)
    private let quickActionsHeaderLabel = UILabel()
    private let quickActionsStack = UIStackView()
    private let historyButton = UIButton(type: .custom)
    private let partyQuickButton = UIButton(type: .custom)
    private let exportButton = UIButton(type: .custom)
    private let helpButton = UIButton(type: .custom)
    
    // Preferences
    private let preferencesHeaderLabel = UILabel()
    private let preferencesCard = UIView()
    private let autoSaveRow = UIView()
    private let autoSaveLabel = UILabel()
    private let autoSaveToggle = UISwitch()
    private let hapticsRow = UIView()
    private let hapticsLabel = UILabel()
    private let hapticsToggle = UISwitch()
    
    /// Messaging tone + pick count (formerly on the More tab); saved when you tap an option.
    private let recommendationsHeaderLabel = UILabel()
    private let messagingCard = UIView()
    private let messagingTitleLabel = UILabel()
    private let messagingStack = UIStackView()
    private var messagingOptionButtons: [UIButton] = []
    private let recommendationCard = UIView()
    private let recommendationTitleLabel = UILabel()
    private let recommendationStack = UIStackView()
    private var recommendationOptionButtons: [UIButton] = []
    private let toneChoices: [(title: String, subtitle: String)] = [
        ("Blunt", "Full roast, \"Don't Zazza\" energy — you asked"),
        ("Neutral", "Straight facts, normal wording"),
        ("Chill", "Softer, encouraging phrasing")
    ]
    private let styleChoices: [(title: String, subtitle: String)] = [
        ("Critical", "Only urgent / strong swap suggestions"),
        ("Normal", "Balanced variety of picks"),
        ("Max", "Always show three top picks")
    ]
    private var selectedToneIndex = 1
    private var selectedStyleIndex = 1
    
    // Account
    private let accountHeaderLabel = UILabel()
    private let accountCard = UIView()
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecommendationPreferencesFromDefaults()
        refreshRecommendationOptionUI()
        setupStyling()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
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
        
        // ScrollView and ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.alwaysBounceVertical = true
        
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
        
        // 1. Compact Header Card
        setupHeaderCard()
        
        // 2. Stats Grid
        setupStatsGrid()
        
        // 3. Quick Actions
        setupQuickActions()
        
        // 4. Recommendations (tone + picks — persisted on selection)
        setupRecommendationPreferences()
        
        // 5. Preferences
        setupPreferences()
        
        // 6. Account / Logout
        setupAccount()
        
        // Layout all sections
        layoutSections()
    }
    
    private func setupHeaderCard() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.applyCardStyle()
        contentView.addSubview(headerCard)
        
        // Avatar (smaller, on the left)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .appPrimaryAccent
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.clipsToBounds = true
        headerCard.addSubview(avatarImageView)
        
        // Stack for username + subtitle
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.alignment = .leading
        headerCard.addSubview(headerStack)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "Username"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerStack.addArrangedSubview(usernameLabel)
        headerStack.addArrangedSubview(subtitleLabel)
        
        // Edit Profile Button
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.setTitle("Edit", for: .normal)
        editProfileButton.titleLabel?.font = .appBodyLarge
        editProfileButton.tintColor = .appPrimaryAccent
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        headerCard.addSubview(editProfileButton)
    }
    
    private func setupStatsGrid() {
        statsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        statsHeaderLabel.text = "Stats"
        contentView.addSubview(statsHeaderLabel)
        
        // Grid container (2x2)
        statsGrid.translatesAutoresizingMaskIntoConstraints = false
        statsGrid.axis = .vertical
        statsGrid.spacing = 12
        statsGrid.distribution = .fillEqually
        contentView.addSubview(statsGrid)
        
        // Row 1
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.spacing = 12
        row1.distribution = .fillEqually
        
        matchesStatChip.translatesAutoresizingMaskIntoConstraints = false
        matchesStatChip.applyCardStyle()
        row1.addArrangedSubview(matchesStatChip)
        
        avgKdaStatChip.translatesAutoresizingMaskIntoConstraints = false
        avgKdaStatChip.applyCardStyle()
        row1.addArrangedSubview(avgKdaStatChip)
        
        statsGrid.addArrangedSubview(row1)
        
        // Row 2
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually
        
        swapPicksStatChip.translatesAutoresizingMaskIntoConstraints = false
        swapPicksStatChip.applyCardStyle()
        row2.addArrangedSubview(swapPicksStatChip)
        
        lastHeroStatChip.translatesAutoresizingMaskIntoConstraints = false
        lastHeroStatChip.applyCardStyle()
        row2.addArrangedSubview(lastHeroStatChip)
        
        statsGrid.addArrangedSubview(row2)
        
        matchesValueLabel = addStatChipLabels(to: matchesStatChip, title: "Matches", value: "0")
        avgKdaValueLabel = addStatChipLabels(to: avgKdaStatChip, title: "Avg K/D/A", value: "—")
        swapPicksValueLabel = addStatChipLabels(to: swapPicksStatChip, title: "Switch rate", value: "—")
        addLastHeroStatChip(to: lastHeroStatChip)
    }
    
    @discardableResult
    private func addStatChipLabels(to chip: UIView, title: String, value: String) -> UILabel {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .appHeading3
        valueLabel.textColor = .appPrimaryAccent
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75
        valueLabel.numberOfLines = 2
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .appBodySmall
        titleLabel.textColor = .appSecondaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(titleLabel)
        
        chip.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: chip.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: chip.trailingAnchor, constant: -8)
        ])
        return valueLabel
    }
    
    private func addLastHeroStatChip(to chip: UIView) {
        let portrait = UIImageView()
        portrait.translatesAutoresizingMaskIntoConstraints = false
        portrait.contentMode = .scaleAspectFit
        portrait.layer.cornerRadius = 8
        portrait.clipsToBounds = true
        portrait.image = UIImage(systemName: "person.fill")
        portrait.tintColor = .appTertiaryText
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = .appPrimaryAccent
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.text = "—"
        
        let caption = UILabel()
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.text = "Last match"
        caption.font = .appBodySmall
        caption.textColor = .appSecondaryText
        caption.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [portrait, nameLabel, caption])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        
        chip.addSubview(stack)
        NSLayoutConstraint.activate([
            portrait.widthAnchor.constraint(equalToConstant: 40),
            portrait.heightAnchor.constraint(equalToConstant: 40),
            stack.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: chip.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: chip.trailingAnchor, constant: -6)
        ])
        lastHeroPortraitView = portrait
        lastHeroNameLabel = nameLabel
    }
    
    private func setupQuickActions() {
        quickActionsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        quickActionsHeaderLabel.text = "Quick actions"
        contentView.addSubview(quickActionsHeaderLabel)
        
        quickActionsStack.translatesAutoresizingMaskIntoConstraints = false
        quickActionsStack.axis = .vertical
        quickActionsStack.spacing = 12
        contentView.addSubview(quickActionsStack)
        
        configureProfileQuickAction(historyButton, title: "View Match History", symbol: "clock.arrow.circlepath", action: #selector(viewHistoryTapped))
        configureProfileQuickAction(partyQuickButton, title: "Party", symbol: "person.2.fill", action: #selector(openPartyTabTapped))
        configureProfileQuickAction(exportButton, title: "Export / Share", symbol: "square.and.arrow.up", action: #selector(exportTapped))
        configureProfileQuickAction(helpButton, title: "Help / How it works", symbol: "questionmark.circle", action: #selector(helpTapped))
        
        for button in [historyButton, partyQuickButton, exportButton, helpButton] {
            let card = UIView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.applyCardStyle()
            card.addSubview(button)
            quickActionsStack.addArrangedSubview(card)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: card.topAnchor),
                button.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                button.bottomAnchor.constraint(equalTo: card.bottomAnchor),
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
            ])
        }
    }
    
    private func configureProfileQuickAction(_ button: UIButton, title: String, symbol: String, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = title
            config.image = UIImage(systemName: symbol)
            config.imagePlacement = .leading
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            config.baseForegroundColor = .appPrimaryText
            config.titleAlignment = .leading
            config.background.backgroundColor = .clear
            button.configuration = config
        } else {
            button.contentHorizontalAlignment = .leading
            button.setImage(UIImage(systemName: symbol), for: .normal)
            button.setTitle("  \(title)", for: .normal)
            button.setTitleColor(.appPrimaryText, for: .normal)
            button.titleLabel?.font = .appBodyLarge
            button.tintColor = .appPrimaryAccent
        }
    }
    
    private func setupRecommendationPreferences() {
        recommendationsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationsHeaderLabel.text = "Recommendations"
        contentView.addSubview(recommendationsHeaderLabel)
        
        messagingCard.translatesAutoresizingMaskIntoConstraints = false
        messagingCard.applyCardStyle()
        contentView.addSubview(messagingCard)
        
        messagingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        messagingTitleLabel.text = "Messaging tone"
        messagingCard.addSubview(messagingTitleLabel)
        
        messagingStack.axis = .vertical
        messagingStack.spacing = 10
        messagingStack.translatesAutoresizingMaskIntoConstraints = false
        messagingCard.addSubview(messagingStack)
        
        messagingOptionButtons = toneChoices.enumerated().map { i, choice in
            let b = makeRecommendationChoiceButton(title: choice.title, subtitle: choice.subtitle)
            b.tag = i
            b.addTarget(self, action: #selector(recommendationToneTapped(_:)), for: .touchUpInside)
            messagingStack.addArrangedSubview(b)
            return b
        }
        
        recommendationCard.translatesAutoresizingMaskIntoConstraints = false
        recommendationCard.applyCardStyle()
        contentView.addSubview(recommendationCard)
        
        recommendationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationTitleLabel.text = "How many picks"
        recommendationCard.addSubview(recommendationTitleLabel)
        
        recommendationStack.axis = .vertical
        recommendationStack.spacing = 10
        recommendationStack.translatesAutoresizingMaskIntoConstraints = false
        recommendationCard.addSubview(recommendationStack)
        
        recommendationOptionButtons = styleChoices.enumerated().map { i, choice in
            let b = makeRecommendationChoiceButton(title: choice.title, subtitle: choice.subtitle)
            b.tag = i
            b.addTarget(self, action: #selector(recommendationStyleTapped(_:)), for: .touchUpInside)
            recommendationStack.addArrangedSubview(b)
            return b
        }
        
        messagingOptionButtons.forEach { $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true }
        recommendationOptionButtons.forEach { $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true }
    }
    
    private func loadRecommendationPreferencesFromDefaults() {
        let t = UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.messagingTone)
        if t >= 0 && t < toneChoices.count { selectedToneIndex = t }
        let s = UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.recommendationStyle)
        if s >= 0 && s < styleChoices.count { selectedStyleIndex = s }
    }
    
    private func makeRecommendationChoiceButton(title: String, subtitle: String) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 12
        b.clipsToBounds = true
        b.contentHorizontalAlignment = .leading
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            var titleAttr = AttributeContainer()
            titleAttr.foregroundColor = UIColor.appPrimaryText
            var subAttr = AttributeContainer()
            subAttr.foregroundColor = UIColor.appTertiaryText
            config.attributedTitle = AttributedString(title, attributes: titleAttr)
            config.attributedSubtitle = AttributedString(subtitle, attributes: subAttr)
            config.titleAlignment = .leading
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
            config.titleLineBreakMode = .byWordWrapping
            config.subtitleLineBreakMode = .byWordWrapping
            b.configuration = config
        } else {
            b.setTitle("\(title)\n\(subtitle)", for: .normal)
            b.titleLabel?.numberOfLines = 0
        }
        return b
    }
    
    private func refreshRecommendationOptionUI() {
        for (i, b) in messagingOptionButtons.enumerated() {
            applyRecommendationSelectedAppearance(b, selected: i == selectedToneIndex)
        }
        for (i, b) in recommendationOptionButtons.enumerated() {
            applyRecommendationSelectedAppearance(b, selected: i == selectedStyleIndex)
        }
    }
    
    private func applyRecommendationSelectedAppearance(_ button: UIButton, selected: Bool) {
        if selected {
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.appPrimaryAccent.cgColor
            if #available(iOS 15.0, *) {
                var config = button.configuration ?? .plain()
                config.background.backgroundColor = UIColor.appPrimaryAccent.withAlphaComponent(0.15)
                button.configuration = config
            } else {
                button.backgroundColor = UIColor.appPrimaryAccent.withAlphaComponent(0.15)
            }
        } else {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appBorderColor.cgColor
            if #available(iOS 15.0, *) {
                var config = button.configuration ?? .plain()
                config.background.backgroundColor = UIColor.white.withAlphaComponent(0.07)
                button.configuration = config
            } else {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.07)
            }
        }
    }
    
    @objc private func recommendationToneTapped(_ sender: UIButton) {
        selectedToneIndex = sender.tag
        refreshRecommendationOptionUI()
        UserDefaults.standard.set(selectedToneIndex, forKey: AppPreferenceStore.Keys.messagingTone)
    }
    
    @objc private func recommendationStyleTapped(_ sender: UIButton) {
        selectedStyleIndex = sender.tag
        refreshRecommendationOptionUI()
        UserDefaults.standard.set(selectedStyleIndex, forKey: AppPreferenceStore.Keys.recommendationStyle)
    }
    
    private func setupPreferences() {
        preferencesHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        preferencesHeaderLabel.text = "Preferences"
        contentView.addSubview(preferencesHeaderLabel)
        
        preferencesCard.translatesAutoresizingMaskIntoConstraints = false
        preferencesCard.applyCardStyle()
        contentView.addSubview(preferencesCard)
        
        // Stack for preference rows
        let prefStack = UIStackView()
        prefStack.translatesAutoresizingMaskIntoConstraints = false
        prefStack.axis = .vertical
        prefStack.spacing = 0
        preferencesCard.addSubview(prefStack)
        
        // Auto-save row
        autoSaveRow.translatesAutoresizingMaskIntoConstraints = false
        
        autoSaveLabel.translatesAutoresizingMaskIntoConstraints = false
        autoSaveLabel.text = "Auto-save scans"
        autoSaveRow.addSubview(autoSaveLabel)
        
        autoSaveToggle.translatesAutoresizingMaskIntoConstraints = false
        autoSaveToggle.isOn = true
        autoSaveRow.addSubview(autoSaveToggle)
        
        NSLayoutConstraint.activate([
            autoSaveLabel.leadingAnchor.constraint(equalTo: autoSaveRow.leadingAnchor, constant: 16),
            autoSaveLabel.centerYAnchor.constraint(equalTo: autoSaveRow.centerYAnchor),
            autoSaveToggle.trailingAnchor.constraint(equalTo: autoSaveRow.trailingAnchor, constant: -16),
            autoSaveToggle.centerYAnchor.constraint(equalTo: autoSaveRow.centerYAnchor),
            autoSaveRow.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        prefStack.addArrangedSubview(autoSaveRow)
        
        // Divider
        let divider = createDivider()
        prefStack.addArrangedSubview(divider)
        
        // Haptics row
        hapticsRow.translatesAutoresizingMaskIntoConstraints = false
        
        hapticsLabel.translatesAutoresizingMaskIntoConstraints = false
        hapticsLabel.text = "Haptics"
        hapticsRow.addSubview(hapticsLabel)
        
        hapticsToggle.translatesAutoresizingMaskIntoConstraints = false
        hapticsToggle.isOn = true
        hapticsRow.addSubview(hapticsToggle)
        
        NSLayoutConstraint.activate([
            hapticsLabel.leadingAnchor.constraint(equalTo: hapticsRow.leadingAnchor, constant: 16),
            hapticsLabel.centerYAnchor.constraint(equalTo: hapticsRow.centerYAnchor),
            hapticsToggle.trailingAnchor.constraint(equalTo: hapticsRow.trailingAnchor, constant: -16),
            hapticsToggle.centerYAnchor.constraint(equalTo: hapticsRow.centerYAnchor),
            hapticsRow.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        prefStack.addArrangedSubview(hapticsRow)
        
        NSLayoutConstraint.activate([
            prefStack.topAnchor.constraint(equalTo: preferencesCard.topAnchor),
            prefStack.leadingAnchor.constraint(equalTo: preferencesCard.leadingAnchor),
            prefStack.trailingAnchor.constraint(equalTo: preferencesCard.trailingAnchor),
            prefStack.bottomAnchor.constraint(equalTo: preferencesCard.bottomAnchor)
        ])
    }
    
    private func setupAccount() {
        accountHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        accountHeaderLabel.text = "Account"
        contentView.addSubview(accountHeaderLabel)
        
        accountCard.translatesAutoresizingMaskIntoConstraints = false
        accountCard.applyCardStyle()
        contentView.addSubview(accountCard)
        
        // Logout button, now smaller and within a card
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.contentHorizontalAlignment = .leading
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logoutButton.semanticContentAttribute = .forceLeftToRight
        logoutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        logoutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.applyDestructiveSecondaryStyle()
        accountCard.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: accountCard.topAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: accountCard.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: accountCard.trailingAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: accountCard.bottomAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func layoutSections() {
        NSLayoutConstraint.activate([
            // Header Card
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            avatarImageView.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 56),
            avatarImageView.heightAnchor.constraint(equalToConstant: 56),
            
            headerStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: editProfileButton.leadingAnchor, constant: -12),
            headerStack.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            headerStack.topAnchor.constraint(greaterThanOrEqualTo: headerCard.topAnchor, constant: 20),
            headerStack.bottomAnchor.constraint(lessThanOrEqualTo: headerCard.bottomAnchor, constant: -20),
            
            editProfileButton.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            editProfileButton.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            
            // Add minimum height constraint for the header card
            headerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 96),
            
            // Stats Header
            statsHeaderLabel.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 28),
            statsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Stats Grid
            statsGrid.topAnchor.constraint(equalTo: statsHeaderLabel.bottomAnchor, constant: 12),
            statsGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            statsGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            statsGrid.heightAnchor.constraint(equalToConstant: 184), // 2 rows + last-hero portrait
            
            // Quick Actions Header
            quickActionsHeaderLabel.topAnchor.constraint(equalTo: statsGrid.bottomAnchor, constant: 28),
            quickActionsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Quick Actions (stack of separate cards)
            quickActionsStack.topAnchor.constraint(equalTo: quickActionsHeaderLabel.bottomAnchor, constant: 12),
            quickActionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            quickActionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Recommendations
            recommendationsHeaderLabel.topAnchor.constraint(equalTo: quickActionsStack.bottomAnchor, constant: 28),
            recommendationsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            messagingCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            messagingCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            messagingCard.topAnchor.constraint(equalTo: recommendationsHeaderLabel.bottomAnchor, constant: 12),
            
            messagingTitleLabel.topAnchor.constraint(equalTo: messagingCard.topAnchor, constant: 18),
            messagingTitleLabel.leadingAnchor.constraint(equalTo: messagingCard.leadingAnchor, constant: 18),
            messagingTitleLabel.trailingAnchor.constraint(equalTo: messagingCard.trailingAnchor, constant: -18),
            
            messagingStack.topAnchor.constraint(equalTo: messagingTitleLabel.bottomAnchor, constant: 14),
            messagingStack.leadingAnchor.constraint(equalTo: messagingCard.leadingAnchor, constant: 14),
            messagingStack.trailingAnchor.constraint(equalTo: messagingCard.trailingAnchor, constant: -14),
            messagingStack.bottomAnchor.constraint(equalTo: messagingCard.bottomAnchor, constant: -16),
            
            recommendationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            recommendationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            recommendationCard.topAnchor.constraint(equalTo: messagingCard.bottomAnchor, constant: 16),
            
            recommendationTitleLabel.topAnchor.constraint(equalTo: recommendationCard.topAnchor, constant: 18),
            recommendationTitleLabel.leadingAnchor.constraint(equalTo: recommendationCard.leadingAnchor, constant: 18),
            recommendationTitleLabel.trailingAnchor.constraint(equalTo: recommendationCard.trailingAnchor, constant: -18),
            
            recommendationStack.topAnchor.constraint(equalTo: recommendationTitleLabel.bottomAnchor, constant: 14),
            recommendationStack.leadingAnchor.constraint(equalTo: recommendationCard.leadingAnchor, constant: 14),
            recommendationStack.trailingAnchor.constraint(equalTo: recommendationCard.trailingAnchor, constant: -14),
            recommendationStack.bottomAnchor.constraint(equalTo: recommendationCard.bottomAnchor, constant: -16),
            
            // Preferences Header
            preferencesHeaderLabel.topAnchor.constraint(equalTo: recommendationCard.bottomAnchor, constant: 28),
            preferencesHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Preferences Card
            preferencesCard.topAnchor.constraint(equalTo: preferencesHeaderLabel.bottomAnchor, constant: 12),
            preferencesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            preferencesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Account Header
            accountHeaderLabel.topAnchor.constraint(equalTo: preferencesCard.bottomAnchor, constant: 28),
            accountHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Account Card
            accountCard.topAnchor.constraint(equalTo: accountHeaderLabel.bottomAnchor, constant: 12),
            accountCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            accountCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            accountCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48)
        ])
    }
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .appDividerColor
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Profile"
        
        // Header
        usernameLabel.font = .appHeading3
        usernameLabel.textColor = .appPrimaryText
        
        subtitleLabel.font = .appBodySmall
        subtitleLabel.textColor = .appSecondaryText
        
        // Section headers
        [statsHeaderLabel, quickActionsHeaderLabel, recommendationsHeaderLabel, preferencesHeaderLabel, accountHeaderLabel].forEach { label in
            label.font = .appBodyLarge
            label.textColor = .appSecondaryText
        }
        
        messagingTitleLabel.font = .appHeading4
        messagingTitleLabel.textColor = .appPrimaryText
        recommendationTitleLabel.font = .appHeading4
        recommendationTitleLabel.textColor = .appPrimaryText
        
        if #available(iOS 15.0, *) {
            [historyButton, partyQuickButton, exportButton, helpButton].forEach { b in
                var config = b.configuration ?? .plain()
                config.background.backgroundColor = .clear
                b.configuration = config
            }
        }
        
        // Preference labels
        autoSaveLabel.font = .appBodyLarge
        autoSaveLabel.textColor = .appPrimaryText
        
        hapticsLabel.font = .appBodyLarge
        hapticsLabel.textColor = .appPrimaryText
        
        // Toggles
        autoSaveToggle.onTintColor = .appPrimaryAccent
        hapticsToggle.onTintColor = .appPrimaryAccent
    }
    
    private func loadUserData() {
        // Update username
        usernameLabel.text = UserSession.shared.username ?? "User"
        
        // Load saved profile image
        if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let savedImage = UIImage(data: imageData) {
            avatarImageView.image = savedImage
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.tintColor = nil
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .appPrimaryAccent
            avatarImageView.contentMode = .scaleAspectFit
        }
        
        let stats = MatchStore.shared.profileHistoryStatsForDisplay()
        matchesValueLabel?.text = "\(stats.matchCount)"
        avgKdaValueLabel?.text = stats.avgKDALine
        swapPicksValueLabel?.text = stats.swapPickPercentLine
        lastHeroNameLabel?.text = stats.lastHeroName
        if let summary = stats.lastHeroSummary, let thumb = MatchSummaryThumbnail.thumbnailImage(for: summary) {
            lastHeroPortraitView?.image = thumb
            lastHeroPortraitView?.tintColor = nil
        } else {
            lastHeroPortraitView?.image = UIImage(systemName: "person.fill")
            lastHeroPortraitView?.tintColor = .appTertiaryText
        }
    }
    
    @objc private func editProfileTapped() {
        let alert = UIAlertController(
            title: "Edit Profile",
            message: "Update your profile information",
            preferredStyle: .alert
        )
        
        // Add text field for username
        alert.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = UserSession.shared.username
            textField.autocapitalizationType = .none
        }
        
        // Add action buttons for profile picture selection
        let changePhotoAction = UIAlertAction(title: "Change Photo", style: .default) { [weak self] _ in
            self?.presentPhotoOptions()
        }
        alert.addAction(changePhotoAction)
        
        // Save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let newUsername = textField.text,
                  !newUsername.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            // Update username
            UserSession.shared.username = newUsername
            self?.usernameLabel.text = newUsername
            
            // Show success feedback
            let haptic = UIImpactFeedbackGenerator(style: .medium)
            haptic.impactOccurred()
        }
        alert.addAction(saveAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func presentPhotoOptions() {
        let alert = UIAlertController(
            title: "Change Profile Photo",
            message: "Choose a photo source",
            preferredStyle: .actionSheet
        )
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        // Photo library option
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            })
        }
        
        // Remove photo option
        alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { [weak self] _ in
            self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
            self?.avatarImageView.tintColor = .appPrimaryAccent
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func viewHistoryTapped() {
        if selectTabBarRoot(matching: HistoryViewController.self) {
            return
        }
        let historyVC = HistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc private func openPartyTabTapped() {
        openPartyScreen()
    }
    
    @objc private func exportTapped() {
        let alert = UIAlertController(
            title: "Export / Share",
            message: "This feature will allow you to share your match summaries. Coming soon!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func helpTapped() {
        let message = """
        RivalsSwitch is a companion for Marvel Rivals — it helps you read the scoreboard, think about swaps, and coordinate with Party. It does not teach how to play the game itself.

        Flow: Home → Match → scan or pick a scoreboard screenshot → confirm stats → get suggestions → History saves your runs.

        Scan tip: use the Tab scoreboard when hero portraits are fully visible. Avoid shots taken while you’re respawning — countdown numbers over portraits often break text recognition.
        """
        let alert = UIAlertController(
            title: "How to use RivalsSwitch",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Get the edited image (or original if editing wasn't used)
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        
        guard let selectedImage = image else { return }
        
        // Update the avatar image
        avatarImageView.image = selectedImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.tintColor = nil // Remove tint since we're using a real image
        
        // Example: Save to UserDefaults
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "userProfileImage")
        }
        
        // Haptic feedback
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

