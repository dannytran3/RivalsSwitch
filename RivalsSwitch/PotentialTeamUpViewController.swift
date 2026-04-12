//
//  PotentialTeamUpViewController.swift
//  RivalsSwitch
//
//  Programmatic Potential Team-Up Screen
//

import UIKit

class PotentialTeamUpViewController: UIViewController {
    
    private struct TeamUpSuggestion {
        let recommendedHero: String
        let teammateHero: String
        let chatMessage: String
        let isTopPick: Bool
    }
    
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let backButton = UIButton(type: .custom)
    
    private var gradientLayer: CAGradientLayer?
    private var suggestions: [TeamUpSuggestion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        loadSuggestions()
        renderSuggestions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        updateScrollViewTabBarAvoidance(scrollView)
    }
    
    // MARK: - UI Setup
    
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
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        view.addSubview(subtitleLabel)
        view.addSubview(scrollView)
        view.addSubview(backButton)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.heightAnchor.constraint(equalToConstant: 56),
            
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Potential Team-Up"
        
        subtitleLabel.applyBodyLargeStyle()
        subtitleLabel.textColor = .appSecondaryText
        
        backButton.applySecondaryStyle()
    }
    
    // MARK: - Data
    
    private func loadSuggestions() {
        let baseHero = primaryRecommendedHero()
        
        if baseHero.isEmpty {
            subtitleLabel.text = "No top recommendation is available yet."
            suggestions = []
            return
        }
        
        subtitleLabel.text = "Suggested teammate swaps that pair well with \(baseHero)."
        
        let normalizedBaseHero = RecommendationEngine.normalizedHeroName(baseHero)
        let normalizedTeam = Set(
            MatchStore.shared.friendlyTeam.map {
                RecommendationEngine.normalizedHeroName($0).lowercased()
            }
        )
        
        let synergyPartners = HeroSynergyMap.synergyMap[normalizedBaseHero] ?? []
        
        var seen = Set<String>()
        var built: [TeamUpSuggestion] = []
        
        for (index, rawPartner) in synergyPartners.enumerated() {
            let partner = RecommendationEngine.normalizedHeroName(rawPartner)
            let partnerKey = partner.lowercased()
            
            if partner.isEmpty { continue }
            if partnerKey == normalizedBaseHero.lowercased() { continue }
            if normalizedTeam.contains(partnerKey) { continue }
            if seen.contains(partnerKey) { continue }
            
            seen.insert(partnerKey)
            
            let message = buildChatMessage(
                recommendedHero: normalizedBaseHero,
                teammateHero: partner,
                slotIndex: index
            )
            
            built.append(
                TeamUpSuggestion(
                    recommendedHero: normalizedBaseHero,
                    teammateHero: partner,
                    chatMessage: message,
                    isTopPick: built.isEmpty
                )
            )
        }
        
        suggestions = Array(built.prefix(3))
    }
    
    private func primaryRecommendedHero() -> String {
        let raw = MatchStore.shared.recommendedHero1.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if raw.isEmpty {
            return ""
        }
        
        if raw == "Stay Current Hero" {
            return MatchStore.shared.currentHero.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return raw
    }
    
    private func buildChatMessage(recommendedHero: String, teammateHero: String, slotIndex: Int) -> String {
        switch AppMessagingTone.stored {
        case .blunt:
            if slotIndex == 0 {
                return "Can someone swap to \(teammateHero)? It pairs way better with \(recommendedHero) here."
            } else {
                return "If nobody can go \(suggestionsSafeHero(at: 0)), \(teammateHero) is another solid pair for \(recommendedHero)."
            }
            
        case .neutral:
            if slotIndex == 0 {
                return "Can someone switch to \(teammateHero)? \(teammateHero) pairs really well with \(recommendedHero) in this comp."
            } else {
                return "If anyone can swap, \(teammateHero) would also work well with \(recommendedHero)."
            }
            
        case .encouraging:
            if slotIndex == 0 {
                return "If anyone is open to swapping, \(teammateHero) would pair really well with \(recommendedHero) here."
            } else {
                return "\(teammateHero) could also be a great team-up with \(recommendedHero) if someone wants another option."
            }
        }
    }
    
    private func suggestionsSafeHero(at index: Int) -> String {
        guard suggestions.indices.contains(index) else { return "that first option" }
        return suggestions[index].teammateHero
    }
    
    // MARK: - Render
    
    private func renderSuggestions() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if suggestions.isEmpty {
            stackView.addArrangedSubview(makeEmptyStateCard())
            return
        }
        
        for suggestion in suggestions {
            let card = makeTeamUpCard(for: suggestion)
            stackView.addArrangedSubview(card)
        }
    }
    
    private func makeEmptyStateCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(elevated: true)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Team-Up Needed"
        titleLabel.applyHeading3Style()
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Your team already has the best partners for this recommendation, or there are no missing synergy picks to suggest."
        messageLabel.applyBodyLargeStyle()
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        card.addSubview(titleLabel)
        card.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
        
        return card
    }
    
    private func makeTeamUpCard(for suggestion: TeamUpSuggestion) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(elevated: suggestion.isTopPick)
        
        let sectionLabel = UILabel()
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.text = suggestion.isTopPick
            ? "Best Team-Up with \(suggestion.recommendedHero)"
            : "Good Team-Up with \(suggestion.recommendedHero)"
        sectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sectionLabel.textColor = suggestion.isTopPick ? .appPrimaryAccent : .appPrimaryText
        sectionLabel.numberOfLines = 0
        
        let portraitView = UIImageView()
        portraitView.translatesAutoresizingMaskIntoConstraints = false
        portraitView.contentMode = .scaleAspectFill
        portraitView.clipsToBounds = true
        portraitView.layer.cornerRadius = 14
        portraitView.layer.borderWidth = 1
        portraitView.layer.borderColor = UIColor.appBorderColor.cgColor
        portraitView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        HeroRegistry.shared.configurePortraitImageView(
            portraitView,
            heroDisplayName: suggestion.teammateHero
        )
        
        let heroLabel = UILabel()
        heroLabel.translatesAutoresizingMaskIntoConstraints = false
        heroLabel.text = suggestion.teammateHero
        heroLabel.applyHeading3Style()
        heroLabel.textAlignment = .center
        heroLabel.numberOfLines = 2
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = suggestion.chatMessage
        messageLabel.applyBodyLargeStyle()
        messageLabel.textAlignment = .natural
        messageLabel.numberOfLines = 0
        
        let copyButton = UIButton(type: .custom)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle("Copy Chat", for: .normal)
        copyButton.applySecondaryStyle()
        copyButton.addAction(
            UIAction { [weak self] _ in
                print("Copying message:", suggestion.chatMessage)
                UIPasteboard.general.string = suggestion.chatMessage
                self?.showCopiedAlert()
            },
            for: .touchUpInside
        )
        
        card.addSubview(sectionLabel)
        card.addSubview(portraitView)
        card.addSubview(heroLabel)
        card.addSubview(messageLabel)
        card.addSubview(copyButton)
        
        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            sectionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            sectionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            portraitView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 14),
            portraitView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            portraitView.widthAnchor.constraint(equalToConstant: 72),
            portraitView.heightAnchor.constraint(equalToConstant: 72),
            
            heroLabel.topAnchor.constraint(equalTo: portraitView.bottomAnchor, constant: 12),
            heroLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            heroLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: heroLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            copyButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            copyButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            copyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            copyButton.heightAnchor.constraint(equalToConstant: 44),
            copyButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        
        return card
    }
    
    private func showCopiedAlert() {
        let alert = UIAlertController(
            title: "Copied",
            message: "Team chat message copied.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
