//
//  ConfirmEnemyTeamViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Confirm Enemy Team Screen
//

import UIKit

class ConfirmEnemyTeamViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let subtitleLabel = UILabel()
    private let enemy1TextField = UITextField()
    private let enemy2TextField = UITextField()
    private let enemy3TextField = UITextField()
    private let enemy4TextField = UITextField()
    private let enemy5TextField = UITextField()
    private let enemy6TextField = UITextField()
    private let doneButton = UIButton(type: .custom)
    private let enemyPicker = UIPickerView()
    /// Single wrapper avoids bare UIPickerView as `inputView` (reduces keyboard/picker constraint churn on some OS versions).
    private lazy var enemyPickerInputView: UIView = {
        let h: CGFloat = 216
        let w = UIScreen.main.bounds.width
        let v = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        enemyPicker.frame = v.bounds
        enemyPicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.addSubview(enemyPicker)
        return v
    }()
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    /// Row 0 clears the slot; remaining rows are sorted hero names.
    private let noneRowTitle = "None"
    private let heroNames: [String]
    private var pickerTitles: [String] { [noneRowTitle] + heroNames }
    
    private weak var activeEnemyTextField: UITextField?
    private var enemyPortraitViews: [UIImageView] = []
    
    private lazy var enemyTextFields: [UITextField] = [
        enemy1TextField,
        enemy2TextField,
        enemy3TextField,
        enemy4TextField,
        enemy5TextField,
        enemy6TextField
    ]
    
    init() {
        self.heroNames = HeroRegistry.shared.allHeroes.map { $0.name }.sorted()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.heroNames = HeroRegistry.shared.allHeroes.map { $0.name }.sorted()
        super.init(coder: coder)
    }
    
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
        
        for i in enemyTextFields.indices {
            refreshPortrait(at: i)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        updateScrollViewTabBarAvoidance(scrollView)
        enemyTextFields.forEach { $0.refreshGlassmorphismPillCorners() }
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
        scrollView.alwaysBounceVertical = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Top → bottom to match the scoreboard. Rivals allows each hero only once per team — if OCR fills the same hero twice, the later slot is left blank.\n\nDouble-check each slot — tap the field to change the hero."
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
        
        enemyPicker.dataSource = self
        enemyPicker.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(enemyPickerDone))
        ]
        
        enemyTextFields.forEach { textField in
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.clearButtonMode = .never
            textField.delegate = self
            textField.inputView = enemyPickerInputView
            textField.inputAccessoryView = toolbar
        }
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
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
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ])
        
        var previousView: UIView = subtitleLabel
        enemyPortraitViews = []
        for index in enemyTextFields.indices {
            let portrait = UIImageView()
            portrait.translatesAutoresizingMaskIntoConstraints = false
            portrait.contentMode = .scaleAspectFill
            portrait.clipsToBounds = true
            portrait.layer.cornerRadius = 26
            portrait.layer.borderWidth = 1
            portrait.layer.borderColor = UIColor.appBorderColor.cgColor
            portrait.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            portrait.setContentHuggingPriority(.required, for: .horizontal)
            enemyPortraitViews.append(portrait)
            
            let prefixLabel = UILabel()
            prefixLabel.translatesAutoresizingMaskIntoConstraints = false
            prefixLabel.text = "Enemy hero \(index + 1):"
            prefixLabel.textAlignment = .natural
            prefixLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            prefixLabel.textColor = .appSecondaryText
            prefixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            // Same width every row so the hero field gets identical horizontal space ("1" vs "6" etc. differ in glyph width).
            let prefixColumnWidth: CGFloat = 132
            
            let textField = enemyTextFields[index]
            textField.placeholder = "None"
            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            let nameRow = UIStackView(arrangedSubviews: [prefixLabel, textField])
            nameRow.translatesAutoresizingMaskIntoConstraints = false
            nameRow.axis = .horizontal
            nameRow.spacing = 8
            nameRow.alignment = .center
            nameRow.distribution = .fill
            
            let rowStack = UIStackView(arrangedSubviews: [portrait, nameRow])
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.alignment = .center
            contentView.addSubview(rowStack)
            
            NSLayoutConstraint.activate([
                rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                rowStack.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: index == 0 ? 22 : 16),
                rowStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
                
                portrait.widthAnchor.constraint(equalToConstant: 52),
                portrait.heightAnchor.constraint(equalToConstant: 52),
                
                prefixLabel.widthAnchor.constraint(equalToConstant: prefixColumnWidth)
            ])
            previousView = rowStack
        }
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            doneButton.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 40),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Confirm Enemy Team"
        
        subtitleLabel.font = .appBodyMedium
        subtitleLabel.textColor = .appSecondaryText
        
        enemyTextFields.forEach { textField in
            textField.applyGlassmorphismPickerFieldStyle()
        }
        
        doneButton.applySolidPrimaryCTAStyle()
    }
    
    @objc private func enemyPickerDone() {
        view.endEditing(true)
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
    
    private func refreshPortrait(at index: Int) {
        guard index >= 0 && index < enemyPortraitViews.count else { return }
        HeroRegistry.shared.configurePortraitImageView(enemyPortraitViews[index], heroDisplayName: enemyTextFields[index].text ?? "")
    }
    
    private func pickerRow(forStoredHeroName text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return 0 }
        if let idx = heroNames.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            return idx + 1
        }
        return 0
    }
    
    private func heroName(forPickerRow row: Int) -> String {
        guard row > 0, row - 1 < heroNames.count else { return "" }
        return heroNames[row - 1]
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard enemyTextFields.contains(textField) else { return }
        activeEnemyTextField = textField
        textField.updateFocusState(true)
        let row = pickerRow(forStoredHeroName: textField.text ?? "")
        enemyPicker.selectRow(row, inComponent: 0, animated: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
        if let idx = enemyTextFields.firstIndex(where: { $0 === textField }) {
            refreshPortrait(at: idx)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }
    
    // MARK: - UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerTitles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = heroName(forPickerRow: row)
        activeEnemyTextField?.text = name.isEmpty ? "" : name
        if let tf = activeEnemyTextField, let idx = enemyTextFields.firstIndex(where: { $0 === tf }) {
            refreshPortrait(at: idx)
        }
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
        
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

        MatchStore.shared.recommendedHero2 = ""
        MatchStore.shared.recommendedReason2 = ""
        MatchStore.shared.recommendedHero3 = ""
        MatchStore.shared.recommendedReason3 = ""

        if recs.count > 0 {
            MatchStore.shared.recommendedHero1 = recs[0].0
            MatchStore.shared.recommendedReason1 = recs[0].1
        } else {
            MatchStore.shared.recommendedHero1 = ""
            MatchStore.shared.recommendedReason1 = ""
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
