//
//  ConfirmEnemyTeamViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Confirm Enemy Team Screen
//

import UIKit

class ConfirmEnemyTeamViewController: UIViewController {
    
    // UI
    private let titleLabel = UILabel()
    private let enemy1TextField = UITextField()
    private let enemy2TextField = UITextField()
    private let enemy3TextField = UITextField()
    private let enemy4TextField = UITextField()
    private let enemy5TextField = UITextField()
    private let enemy6TextField = UITextField()
    private let doneButton = UIButton(type: .system)
    private let heroSuggestionsTableView = UITableView()
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Data
    private var filteredHeroNames: [String] = []
    private weak var activeEnemyTextField: UITextField?
    private lazy var enemyTextFields: [UITextField] = [
        enemy1TextField,
        enemy2TextField,
        enemy3TextField,
        enemy4TextField,
        enemy5TextField,
        enemy6TextField
    ]
    private let allHeroNames = HeroRegistry.shared.allHeroes.map { $0.name }.sorted()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        
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
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Confirm Enemy Team"
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        enemyTextFields.forEach { textField in
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.clearButtonMode = .whileEditing
            contentView.addSubview(textField)
        }
        
        heroSuggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        heroSuggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HeroSuggestionCell")
        heroSuggestionsTableView.dataSource = self
        heroSuggestionsTableView.delegate = self
        heroSuggestionsTableView.isHidden = true
        heroSuggestionsTableView.layer.cornerRadius = 12
        heroSuggestionsTableView.clipsToBounds = true
        contentView.addSubview(heroSuggestionsTableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40)
        ])
        
        var previousView: UIView = titleLabel
        enemyTextFields.enumerated().forEach { index, textField in
            textField.placeholder = "Enemy \(index + 1)"
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                textField.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                textField.heightAnchor.constraint(equalToConstant: 56)
            ])
            previousView = textField
        }
        
        NSLayoutConstraint.activate([
            heroSuggestionsTableView.leadingAnchor.constraint(equalTo: enemy1TextField.leadingAnchor),
            heroSuggestionsTableView.trailingAnchor.constraint(equalTo: enemy1TextField.trailingAnchor),
            heroSuggestionsTableView.topAnchor.constraint(equalTo: enemy1TextField.bottomAnchor, constant: 8),
            heroSuggestionsTableView.heightAnchor.constraint(equalToConstant: 220),
            
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            doneButton.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 40),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        enemyTextFields.forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        }
    }
    
    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Confirm Enemy Team"
        
        titleLabel.font = .appHeading3
        titleLabel.textColor = .appPrimaryText
        
        enemyTextFields.forEach { textField in
            textField.applyGlassmorphismStyle()
        }
        
        doneButton.applyGradientStyle()
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        activeEnemyTextField = textField
        textField.updateFocusState(true)
        updateHeroSuggestions(for: textField.text ?? "")
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.enemyTextFields.contains(where: { $0.isFirstResponder }) == false {
                self.heroSuggestionsTableView.isHidden = true
            }
        }
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        activeEnemyTextField = textField
        updateHeroSuggestions(for: textField.text ?? "")
    }
    
    private func updateHeroSuggestions(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if trimmedQuery.isEmpty {
            filteredHeroNames = allHeroNames
        } else {
            filteredHeroNames = allHeroNames.filter { heroName in
                heroName.lowercased().contains(trimmedQuery)
            }
        }
        
        heroSuggestionsTableView.isHidden = filteredHeroNames.isEmpty || activeEnemyTextField == nil
        heroSuggestionsTableView.reloadData()
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
            friendlyTeam: MatchStore.shared.friendlyTeam,
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

        let recommendationsVC = RecommendationsViewController()
        navigationController?.pushViewController(recommendationsVC, animated: true)
    }
}

extension ConfirmEnemyTeamViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredHeroNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroSuggestionCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = filteredHeroNames[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeEnemyTextField?.text = filteredHeroNames[indexPath.row]
        heroSuggestionsTableView.isHidden = true
        activeEnemyTextField?.resignFirstResponder()
    }
}
