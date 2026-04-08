//
//  HistoryViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic History Screen
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let historyDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    
    private static let historyTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
    
    // UI Elements
    private let tableView = UITableView()
    private var matches: [SavedMatch] = []
    private var gradientLayer: CAGradientLayer?
    
    // Empty State
    private let emptyStateView = UIView()
    private let emptyIconView = UIImageView()
    private let emptyTitleLabel = UILabel()
    private let emptyMessageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        setupEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        matches = MatchStore.shared.loadSavedMatches()
        tableView.reloadData()
        updateEmptyState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        updateTableViewTabBarAvoidance(tableView)
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
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "History"
        
        // Table view
        tableView.backgroundColor = .clear
        tableView.separatorColor = .appDividerColor
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupEmptyState() {
        // Empty State Container
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        // Icon
        emptyIconView.translatesAutoresizingMaskIntoConstraints = false
        emptyIconView.image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle")
        emptyIconView.tintColor = .appPrimaryAccent.withAlphaComponent(0.6)
        emptyIconView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyIconView)
        
        // Title
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTitleLabel.text = "No matches yet"
        emptyTitleLabel.font = .appHeading3
        emptyTitleLabel.textColor = .appPrimaryText
        emptyTitleLabel.textAlignment = .center
        emptyStateView.addSubview(emptyTitleLabel)
        
        // Message
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyMessageLabel.text = "Your match history will appear here\nonce you scan some games! 🎮"
        emptyMessageLabel.font = .appBodyLarge
        emptyMessageLabel.textColor = .appSecondaryText
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.numberOfLines = 0
        emptyStateView.addSubview(emptyMessageLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Icon
            emptyIconView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIconView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconView.widthAnchor.constraint(equalToConstant: 80),
            emptyIconView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconView.bottomAnchor, constant: 24),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            // Message
            emptyMessageLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 12),
            emptyMessageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyMessageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyMessageLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = matches.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let entry = matches[indexPath.row]
        let summary = entry.summary
        let dateLine = Self.historyDateFormatter.string(from: entry.savedAt)
        let timeLine = Self.historyTimeFormatter.string(from: entry.savedAt)

        var content = cell.defaultContentConfiguration()
        content.text = dateLine
        content.secondaryText = "\(timeLine)\n\(summary)"

        content.secondaryTextProperties.numberOfLines = 0
        
        content.textProperties.font = .appHeading4
        content.textProperties.color = .appPrimaryText
        content.secondaryTextProperties.font = .appBodyMedium
        content.secondaryTextProperties.color = .appSecondaryText
        
        if let thumb = MatchSummaryThumbnail.thumbnailImage(for: summary) {
            content.image = thumb
            content.imageProperties.maximumSize = CGSize(width: 52, height: 52)
            content.imageProperties.cornerRadius = 8
        } else {
            content.image = nil
        }
        
        cell.backgroundColor = .appSecondaryBackground
        cell.contentConfiguration = content
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .appTertiaryBackground

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = matches[indexPath.row]
        let detail = MatchHistoryDetailSheetViewController(entry: entry)
        let nav = UINavigationController(rootViewController: detail)
        nav.modalPresentationStyle = .pageSheet
        nav.view.backgroundColor = MatchHistoryDetailSheetViewController.partySheetBackground
        styleMatchHistorySheetNavigationBar(nav.navigationBar)
        if let pres = nav.sheetPresentationController {
            // Large-only avoids the medium “floating card” width; matches Party-style full-width sheets.
            pres.detents = [.large()]
            pres.prefersGrabberVisible = true
            pres.prefersEdgeAttachedInCompactHeight = true
        }
        present(nav, animated: true)
    }
    
    private func styleMatchHistorySheetNavigationBar(_ bar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = MatchHistoryDetailSheetViewController.partySheetBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.appPrimaryText,
            .font: UIFont.appHeading3
        ]
        appearance.shadowColor = .clear
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.tintColor = .appPrimaryAccent
    }
    
    /// System swipe-to-delete fills the full row height (unlike a standalone `UIContextualAction` chip).
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        MatchStore.shared.deleteSavedMatch(at: indexPath.row)
        matches = MatchStore.shared.loadSavedMatches()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        updateEmptyState()
    }
}

// MARK: - Match detail bottom sheet (Party hero sheet–style: nav, cards, icons)

private final class MatchHistoryDetailSheetViewController: UIViewController {
    
    /// Same base as `PartySheets` hero / invite backgrounds (#1A1A2E).
    static let partySheetBackground = UIColor(red: 26 / 255, green: 26 / 255, blue: 46 / 255, alpha: 1)
    /// Hero grid card fill: `Color(hex: "32324C").opacity(0.6)`
    private static let partyCardFill = UIColor(red: 50 / 255, green: 50 / 255, blue: 76 / 255, alpha: 0.6)
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
    
    private static let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    private let entry: SavedMatch
    
    init(entry: SavedMatch) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.partySheetBackground
        
        navigationItem.title = "Match details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .appPrimaryAccent
        
        let parsed = entry.parsedSummary()
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        
        stack.addArrangedSubview(makeHeroHeaderCard(heroName: parsed.playingHero))
        
        let whenText = "\(Self.dateFormatter.string(from: entry.savedAt))\n\(Self.timeFormatter.string(from: entry.savedAt))"
        stack.addArrangedSubview(makeInfoCard(symbolName: "clock.fill", title: "When", value: whenText))
        stack.addArrangedSubview(makeInfoCard(symbolName: "chart.bar.doc.horizontal.fill", title: "KDA", value: parsed.kdaLine))
        stack.addArrangedSubview(makeInfoCard(symbolName: "person.3.fill", title: "Enemies", value: parsed.enemies))
        stack.addArrangedSubview(makeTopSwapCard(displayText: parsed.topSwap))
        
        let shareButton = makeShareButton()
        stack.addArrangedSubview(shareButton)
        stack.setCustomSpacing(22, after: stack.arrangedSubviews[stack.arrangedSubviews.count - 2])
        
        scrollView.addSubview(stack)
        
        let hMargin: CGFloat = 20
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: hMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -hMargin),
            // Padding below Share so it stays above the home indicator and is easy to tap.
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 36),
            // Lock content width to the visible scroll view so labels wrap instead of growing the viewport horizontally.
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * hMargin)
        ])
    }
    
    private func makeHeroHeaderCard(heroName: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.backgroundColor = Self.partyCardFill
        
        let portrait = UIImageView()
        portrait.translatesAutoresizingMaskIntoConstraints = false
        portrait.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        portrait.layer.cornerRadius = 12
        portrait.clipsToBounds = true
        HeroRegistry.shared.configurePartyStylePortraitImageView(
            portrait,
            heroDisplayName: heroName,
            loadedImageContentMode: .scaleAspectFit,
            brandPlaceholder: UIImage(named: "Logo"),
            preferBundledDeluxePortrait: false
        )
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = heroName
        nameLabel.font = .appHeading3
        nameLabel.textColor = .appPrimaryText
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        var arranged: [UIView] = [portrait, nameLabel]
        if let hero = HeroRegistry.shared.hero(name: heroName) {
            arranged.append(makeRoleCapsule(role: hero.role))
        }
        
        let inner = UIStackView(arrangedSubviews: arranged)
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.axis = .vertical
        inner.spacing = 12
        inner.alignment = .center
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            portrait.leadingAnchor.constraint(equalTo: inner.layoutMarginsGuide.leadingAnchor),
            portrait.trailingAnchor.constraint(equalTo: inner.layoutMarginsGuide.trailingAnchor),
            portrait.heightAnchor.constraint(equalTo: portrait.widthAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: inner.layoutMarginsGuide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: inner.layoutMarginsGuide.trailingAnchor)
        ])
        return card
    }
    
    private func makeRoleCapsule(role: HeroData.HeroRole) -> UIView {
        let tint = roleUIColor(role)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = role.rawValue.capitalized
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = tint
        
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        wrap.backgroundColor = tint.withAlphaComponent(0.22)
        wrap.layer.cornerRadius = 10
        wrap.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -10)
        ])
        return wrap
    }
    
    private func roleUIColor(_ role: HeroData.HeroRole) -> UIColor {
        switch role {
        case .vanguard: return .systemBlue
        case .duelist: return .systemRed
        case .strategist: return .systemGreen
        }
    }
    
    private func makeInfoCard(symbolName: String, title: String, value: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.backgroundColor = Self.partyCardFill
        
        let icon = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: Self.symbolConfig))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .appPrimaryAccent
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = title.uppercased()
        titleLbl.font = .systemFont(ofSize: 11, weight: .bold)
        titleLbl.textColor = UIColor.appSecondaryText
        titleLbl.numberOfLines = 0
        titleLbl.lineBreakMode = .byWordWrapping
        titleLbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.text = value
        valueLbl.font = .appBodyLarge
        valueLbl.textColor = .appPrimaryText
        valueLbl.numberOfLines = 0
        valueLbl.lineBreakMode = .byWordWrapping
        valueLbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let textStack = UIStackView(arrangedSubviews: [titleLbl, valueLbl])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .fill
        
        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.distribution = .fill
        row.spacing = 14
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: 30)
        ])
        return card
    }
    
    private func makeTopSwapCard(displayText: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.backgroundColor = Self.partyCardFill
        
        let icon = UIImageView(image: UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: Self.symbolConfig))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .appPrimaryAccent
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "TOP SWAP"
        titleLbl.font = .systemFont(ofSize: 11, weight: .bold)
        titleLbl.textColor = UIColor.appSecondaryText
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.text = displayText
        valueLbl.font = .appBodyLarge
        valueLbl.textColor = .appPrimaryText
        valueLbl.numberOfLines = 0
        valueLbl.lineBreakMode = .byWordWrapping
        valueLbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let textStack = UIStackView(arrangedSubviews: [titleLbl, valueLbl])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .fill
        titleLbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let swapName = displayText.replacingOccurrences(of: "👑", with: "").trimmingCharacters(in: .whitespaces)
        let miniPortrait = UIImageView()
        miniPortrait.translatesAutoresizingMaskIntoConstraints = false
        miniPortrait.layer.cornerRadius = 8
        miniPortrait.clipsToBounds = true
        miniPortrait.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        miniPortrait.widthAnchor.constraint(equalToConstant: 48).isActive = true
        miniPortrait.heightAnchor.constraint(equalToConstant: 48).isActive = true
        if swapName != "—", HeroRegistry.shared.hero(name: swapName) != nil {
            HeroRegistry.shared.configurePartyStylePortraitImageView(
                miniPortrait,
                heroDisplayName: swapName,
                loadedImageContentMode: .scaleAspectFit,
                brandPlaceholder: UIImage(named: "Logo"),
                preferBundledDeluxePortrait: false
            )
        } else {
            if let logo = UIImage(named: "Logo") {
                miniPortrait.image = logo
                miniPortrait.tintColor = nil
            } else {
                miniPortrait.image = UIImage(systemName: "person.fill.questionmark")
                miniPortrait.tintColor = .appTertiaryText
            }
            miniPortrait.contentMode = .scaleAspectFit
        }
        
        let centerStack = UIStackView(arrangedSubviews: [textStack, miniPortrait])
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        centerStack.axis = .horizontal
        centerStack.alignment = .center
        centerStack.distribution = .fill
        centerStack.spacing = 12
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let row = UIStackView(arrangedSubviews: [icon, centerStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 14
        centerStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: 30)
        ])
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        miniPortrait.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return card
    }
    
    private func makeShareButton() -> UIButton {
        let shareButton = UIButton(type: .custom)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        let shareTitle = " Share match"
        shareButton.setTitle(shareTitle, for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.semanticContentAttribute = .forceLeftToRight
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.applySolidPrimaryCTAStyle()
        shareButton.tintColor = .appPrimaryText
        shareButton.contentHorizontalAlignment = .center
        shareButton.titleLabel?.lineBreakMode = .byTruncatingTail
        shareButton.titleLabel?.adjustsFontSizeToFitWidth = true
        shareButton.titleLabel?.minimumScaleFactor = 0.85
        shareButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return shareButton
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    private var shareText: String {
        let d = Self.dateFormatter.string(from: entry.savedAt)
        let t = Self.timeFormatter.string(from: entry.savedAt)
        return "RivalsSwitch — \(d) \(t)\n\n\(entry.summary)"
    }
    
    @objc private func shareTapped() {
        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        av.popoverPresentationController?.sourceView = view
        av.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 1, width: 1, height: 1)
        present(av, animated: true)
    }
}
    