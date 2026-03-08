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
    private let winRateStatChip = UIView()
    private let mostPlayedStatChip = UIView()
    private let lastPlayedStatChip = UIView()
    
    // Quick Actions
    private let quickActionsHeaderLabel = UILabel()
    private let quickActionsCard = UIView()
    private let historyButton = UIButton(type: .system)
    private let exportButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)
    
    // Preferences
    private let preferencesHeaderLabel = UILabel()
    private let preferencesCard = UIView()
    private let autoSaveRow = UIView()
    private let autoSaveLabel = UILabel()
    private let autoSaveToggle = UISwitch()
    private let hapticsRow = UIView()
    private let hapticsLabel = UILabel()
    private let hapticsToggle = UISwitch()
    
    // Account
    private let accountHeaderLabel = UILabel()
    private let accountCard = UIView()
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        loadUserData()
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
        
        // 1. Compact Header Card
        setupHeaderCard()
        
        // 2. Stats Grid
        setupStatsGrid()
        
        // 3. Quick Actions
        setupQuickActions()
        
        // 4. Preferences
        setupPreferences()
        
        // 5. Account / Logout
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
        
        winRateStatChip.translatesAutoresizingMaskIntoConstraints = false
        winRateStatChip.applyCardStyle()
        row1.addArrangedSubview(winRateStatChip)
        
        statsGrid.addArrangedSubview(row1)
        
        // Row 2
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.spacing = 12
        row2.distribution = .fillEqually
        
        mostPlayedStatChip.translatesAutoresizingMaskIntoConstraints = false
        mostPlayedStatChip.applyCardStyle()
        row2.addArrangedSubview(mostPlayedStatChip)
        
        lastPlayedStatChip.translatesAutoresizingMaskIntoConstraints = false
        lastPlayedStatChip.applyCardStyle()
        row2.addArrangedSubview(lastPlayedStatChip)
        
        statsGrid.addArrangedSubview(row2)
        
        // Add labels to each chip
        addStatChipLabels(to: matchesStatChip, title: "Matches", value: "0")
        addStatChipLabels(to: winRateStatChip, title: "Win Rate", value: "—")
        addStatChipLabels(to: mostPlayedStatChip, title: "Most Played", value: "—")
        addStatChipLabels(to: lastPlayedStatChip, title: "Last Played", value: "—")
    }
    
    private func addStatChipLabels(to chip: UIView, title: String, value: String) {
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
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .appBodySmall
        titleLabel.textColor = .appSecondaryText
        titleLabel.textAlignment = .center
        
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(titleLabel)
        
        chip.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: chip.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: chip.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupQuickActions() {
        quickActionsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        quickActionsHeaderLabel.text = "Quick actions"
        contentView.addSubview(quickActionsHeaderLabel)
        
        quickActionsCard.translatesAutoresizingMaskIntoConstraints = false
        quickActionsCard.applyCardStyle()
        contentView.addSubview(quickActionsCard)
        
        // Stack for action buttons
        let actionsStack = UIStackView()
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.axis = .vertical
        actionsStack.spacing = 0
        quickActionsCard.addSubview(actionsStack)
        
        // View History
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.contentHorizontalAlignment = .leading
        historyButton.setTitle("  View Match History", for: .normal)
        historyButton.addTarget(self, action: #selector(viewHistoryTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "clock.arrow.circlepath")
            config.imagePlacement = .leading
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            historyButton.configuration = config
        }
        actionsStack.addArrangedSubview(historyButton)
        
        // Divider 1
        let divider1 = createDivider()
        actionsStack.addArrangedSubview(divider1)
        
        // Export / Share
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.contentHorizontalAlignment = .leading
        exportButton.setTitle("  Export / Share", for: .normal)
        exportButton.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "square.and.arrow.up")
            config.imagePlacement = .leading
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            exportButton.configuration = config
        }
        actionsStack.addArrangedSubview(exportButton)
        
        // Divider 2
        let divider2 = createDivider()
        actionsStack.addArrangedSubview(divider2)
        
        // Help
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.contentHorizontalAlignment = .leading
        helpButton.setTitle("  Help / How it works", for: .normal)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "questionmark.circle")
            config.imagePlacement = .leading
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            helpButton.configuration = config
        }
        actionsStack.addArrangedSubview(helpButton)
        
        NSLayoutConstraint.activate([
            actionsStack.topAnchor.constraint(equalTo: quickActionsCard.topAnchor),
            actionsStack.leadingAnchor.constraint(equalTo: quickActionsCard.leadingAnchor),
            actionsStack.trailingAnchor.constraint(equalTo: quickActionsCard.trailingAnchor),
            actionsStack.bottomAnchor.constraint(equalTo: quickActionsCard.bottomAnchor),
            
            historyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            exportButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            helpButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
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
        
        // Logout button - now smaller and within a card
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.contentHorizontalAlignment = .leading
        logoutButton.setTitle("  Logout", for: .normal)
        logoutButton.setTitleColor(.appErrorColor, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            config.imagePlacement = .leading
            config.imagePadding = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            config.baseForegroundColor = .appErrorColor
            logoutButton.configuration = config
        }
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
            statsGrid.heightAnchor.constraint(equalToConstant: 168), // 2 rows * 78 + 12 spacing
            
            // Quick Actions Header
            quickActionsHeaderLabel.topAnchor.constraint(equalTo: statsGrid.bottomAnchor, constant: 28),
            quickActionsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Quick Actions Card
            quickActionsCard.topAnchor.constraint(equalTo: quickActionsHeaderLabel.bottomAnchor, constant: 12),
            quickActionsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            quickActionsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Preferences Header
            preferencesHeaderLabel.topAnchor.constraint(equalTo: quickActionsCard.bottomAnchor, constant: 28),
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
            accountCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
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
        [statsHeaderLabel, quickActionsHeaderLabel, preferencesHeaderLabel, accountHeaderLabel].forEach { label in
            label.font = .appBodyLarge
            label.textColor = .appSecondaryText
        }
        
        // Quick action buttons
        historyButton.tintColor = .appPrimaryText
        historyButton.titleLabel?.font = .appBodyLarge
        
        exportButton.tintColor = .appPrimaryText
        exportButton.titleLabel?.font = .appBodyLarge
        
        helpButton.tintColor = .appPrimaryText
        helpButton.titleLabel?.font = .appBodyLarge
        
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
        
        // Update match count in stats grid
        let matchCount = MatchStore.shared.loadMatches().count
        if let matchesChip = matchesStatChip.subviews.first as? UIStackView,
           let valueLabel = matchesChip.arrangedSubviews.first as? UILabel {
            valueLabel.text = "\(matchCount)"
        }
    }
    
    // MARK: - Actions
    
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
            // TODO: Clear stored photo data
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
        // Navigate to History tab
        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 1 // Assuming History is at index 1
        }
    }
    
    @objc private func exportTapped() {
        // TODO: Implement export/share functionality
        let alert = UIAlertController(
            title: "Export / Share",
            message: "This feature will allow you to share your match summaries. Coming soon!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func helpTapped() {
        // TODO: Show help/tutorial screen
        let alert = UIAlertController(
            title: "How it works",
            message: "1. Tap 'Start New Match' on the home screen\n2. Scan your scoreboard photo\n3. Confirm your stats\n4. Get counter-pick recommendations\n5. Review your match history",
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

// MARK: - UIImagePickerControllerDelegate

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
        
        // TODO: Save the image to UserDefaults or file system
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

