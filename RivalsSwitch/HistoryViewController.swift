//
//  HistoryViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic History Screen
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // UI Elements
    private let tableView = UITableView()
    private var matches: [String] = []
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
        matches = MatchStore.shared.loadMatches()
        tableView.reloadData()
        updateEmptyState()
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        var content = cell.defaultContentConfiguration()
        content.text = "Match \(matches.count - indexPath.row)"
        content.secondaryText = matches[indexPath.row]

        content.secondaryTextProperties.numberOfLines = 0
        
        // Apply styling
        content.textProperties.font = .appHeading4
        content.textProperties.color = .appPrimaryText
        content.secondaryTextProperties.font = .appBodyMedium
        content.secondaryTextProperties.color = .appSecondaryText
        
        // Cell styling
        cell.backgroundColor = .appSecondaryBackground
        cell.contentConfiguration = content
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .appTertiaryBackground

        return cell
    }
}
