//
//  ConfirmMyStatsViewController.swift
//  RivalsSwitch
//
//  Layout aligned with Confirm Enemy Team: scroll, captions, hero row = portrait + field.
//

import UIKit

class ConfirmMyStatsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let subtitleLabel = UILabel()
    
    private let heroCaptionLabel = UILabel()
    private let killsLabel = UILabel()
    private let deathsLabel = UILabel()
    private let assistsLabel = UILabel()
    
    private let heroPortraitView = UIImageView()
    private let heroTextField = UITextField()
    private let killsTextField = UITextField()
    private let deathsTextField = UITextField()
    private let assistsTextField = UITextField()
    
    private let heroPicker = UIPickerView()
    private let heroNames: [String]
    
    private let doneButton = UIButton(type: .custom)
    private var gradientLayer: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

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
        
        killsTextField.text = MatchStore.shared.currentKills > 0 ? "\(MatchStore.shared.currentKills)" : ""
        deathsTextField.text = MatchStore.shared.currentDeaths > 0 ? "\(MatchStore.shared.currentDeaths)" : ""
        assistsTextField.text = MatchStore.shared.currentAssists > 0 ? "\(MatchStore.shared.currentAssists)" : ""
        
        let ocrHero = MatchStore.shared.currentHero.trimmingCharacters(in: .whitespacesAndNewlines)
        if let idx = heroNames.firstIndex(where: { $0.caseInsensitiveCompare(ocrHero) == .orderedSame }) {
            heroPicker.selectRow(idx, inComponent: 0, animated: false)
            heroTextField.text = heroNames[idx]
        } else if !ocrHero.isEmpty {
            heroTextField.text = ocrHero
            if let idx = heroNames.firstIndex(where: { $0.localizedCaseInsensitiveContains(ocrHero) }) {
                heroPicker.selectRow(idx, inComponent: 0, animated: false)
                heroTextField.text = heroNames[idx]
            }
        } else if let first = heroNames.first {
            heroTextField.text = first
            heroPicker.selectRow(0, inComponent: 0, animated: false)
        }
        refreshHeroPortrait()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        updateScrollViewTabBarAvoidance(scrollView)
        [heroTextField, killsTextField, deathsTextField, assistsTextField].forEach { $0.refreshGlassmorphismPillCorners() }
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
        subtitleLabel.text = "Check the hero and KDA from your scan. Choose your hero from the list — tap the field to change.\n\nKills, deaths, and assists use the number pad."
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
        
        heroCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCaptionLabel.text = "Your hero:"
        heroCaptionLabel.textAlignment = .natural
        contentView.addSubview(heroCaptionLabel)
        
        heroPortraitView.translatesAutoresizingMaskIntoConstraints = false
        heroPortraitView.contentMode = .scaleAspectFill
        heroPortraitView.clipsToBounds = true
        heroPortraitView.layer.cornerRadius = 26
        heroPortraitView.layer.borderWidth = 1
        heroPortraitView.layer.borderColor = UIColor.appBorderColor.cgColor
        heroPortraitView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        heroPortraitView.setContentHuggingPriority(.required, for: .horizontal)
        
        heroTextField.translatesAutoresizingMaskIntoConstraints = false
        heroTextField.placeholder = "Select hero"
        heroTextField.autocapitalizationType = .words
        heroTextField.delegate = self
        heroPicker.dataSource = self
        heroPicker.delegate = self
        heroTextField.inputView = heroPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(heroPickerDone))
        ]
        heroTextField.inputAccessoryView = toolbar
        
        let heroRowStack = UIStackView(arrangedSubviews: [heroPortraitView, heroTextField])
        heroRowStack.translatesAutoresizingMaskIntoConstraints = false
        heroRowStack.axis = .horizontal
        heroRowStack.spacing = 12
        heroRowStack.alignment = .center
        heroTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.addSubview(heroRowStack)
        
        let numberToolbar = UIToolbar()
        numberToolbar.sizeToFit()
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissNumberPad))
        ]
        
        killsLabel.translatesAutoresizingMaskIntoConstraints = false
        deathsLabel.translatesAutoresizingMaskIntoConstraints = false
        assistsLabel.translatesAutoresizingMaskIntoConstraints = false
        killsLabel.text = "Kills"
        deathsLabel.text = "Deaths"
        assistsLabel.text = "Assists"
        [killsLabel, deathsLabel, assistsLabel].forEach { contentView.addSubview($0) }
        
        killsTextField.translatesAutoresizingMaskIntoConstraints = false
        killsTextField.placeholder = "0"
        killsTextField.keyboardType = .numberPad
        killsTextField.delegate = self
        killsTextField.inputAccessoryView = numberToolbar
        contentView.addSubview(killsTextField)
        
        deathsTextField.translatesAutoresizingMaskIntoConstraints = false
        deathsTextField.placeholder = "0"
        deathsTextField.keyboardType = .numberPad
        deathsTextField.delegate = self
        deathsTextField.inputAccessoryView = numberToolbar
        contentView.addSubview(deathsTextField)
        
        assistsTextField.translatesAutoresizingMaskIntoConstraints = false
        assistsTextField.placeholder = "0"
        assistsTextField.keyboardType = .numberPad
        assistsTextField.delegate = self
        assistsTextField.inputAccessoryView = numberToolbar
        contentView.addSubview(assistsTextField)
        
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
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            heroCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            heroCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            heroCaptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            
            heroRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            heroRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            heroRowStack.topAnchor.constraint(equalTo: heroCaptionLabel.bottomAnchor, constant: 6),
            heroRowStack.heightAnchor.constraint(equalToConstant: 56),
            
            heroPortraitView.widthAnchor.constraint(equalToConstant: 52),
            heroPortraitView.heightAnchor.constraint(equalToConstant: 52),
            
            heroTextField.heightAnchor.constraint(equalToConstant: 56),
            
            killsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            killsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            killsLabel.topAnchor.constraint(equalTo: heroRowStack.bottomAnchor, constant: 20),
            
            killsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            killsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            killsTextField.topAnchor.constraint(equalTo: killsLabel.bottomAnchor, constant: 8),
            killsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            deathsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            deathsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            deathsLabel.topAnchor.constraint(equalTo: killsTextField.bottomAnchor, constant: 20),
            
            deathsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            deathsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            deathsTextField.topAnchor.constraint(equalTo: deathsLabel.bottomAnchor, constant: 8),
            deathsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            assistsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            assistsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            assistsLabel.topAnchor.constraint(equalTo: deathsTextField.bottomAnchor, constant: 20),
            
            assistsTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            assistsTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            assistsTextField.topAnchor.constraint(equalTo: assistsLabel.bottomAnchor, constant: 8),
            assistsTextField.heightAnchor.constraint(equalToConstant: 56),
            
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            doneButton.topAnchor.constraint(equalTo: assistsTextField.bottomAnchor, constant: 40),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        [killsTextField, deathsTextField, assistsTextField].forEach { textField in
            textField.addTarget(self, action: #selector(statTextFieldDidBegin(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(statTextFieldDidEnd(_:)), for: .editingDidEnd)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupStyling() {
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Confirm Your Stats"
        
        subtitleLabel.font = .appBodyMedium
        subtitleLabel.textColor = .appSecondaryText
        
        [heroCaptionLabel, killsLabel, deathsLabel, assistsLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = .appSecondaryText
        }
        
        heroTextField.applyGlassmorphismPickerFieldStyle()
        killsTextField.applyGlassmorphismStyle()
        deathsTextField.applyGlassmorphismStyle()
        assistsTextField.applyGlassmorphismStyle()
        
        doneButton.applySolidPrimaryCTAStyle()
    }
    
    private func refreshHeroPortrait() {
        HeroRegistry.shared.configurePortraitImageView(heroPortraitView, heroDisplayName: heroTextField.text ?? "")
    }
    
    @objc private func heroPickerDone() {
        heroTextField.resignFirstResponder()
    }
    
    @objc private func dismissNumberPad() {
        view.endEditing(true)
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
    
    @objc private func statTextFieldDidBegin(_ textField: UITextField) {
        textField.updateFocusState(true)
    }
    
    @objc private func statTextFieldDidEnd(_ textField: UITextField) {
        textField.updateFocusState(false)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField === heroTextField else { return }
        textField.updateFocusState(true)
        if let text = heroTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let idx = heroNames.firstIndex(where: { $0.caseInsensitiveCompare(text) == .orderedSame }) {
            heroPicker.selectRow(idx, inComponent: 0, animated: false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === heroTextField else { return }
        textField.updateFocusState(false)
        refreshHeroPortrait()
    }
    
    // MARK: - Hero picker (no typing)
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        heroNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        heroNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        heroTextField.text = heroNames[row]
        refreshHeroPortrait()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === heroTextField { return false }
        if textField === killsTextField || textField === deathsTextField || textField === assistsTextField {
            let allowed = CharacterSet.decimalDigits
            return string.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
        return true
    }

    @objc private func doneTapped() {
        let row = heroPicker.selectedRow(inComponent: 0)
        let hero = (row >= 0 && row < heroNames.count) ? heroNames[row] : (heroTextField.text ?? "")
        MatchStore.shared.currentHero = hero
        MatchStore.shared.currentKills = Int(killsTextField.text ?? "") ?? 0
        MatchStore.shared.currentDeaths = Int(deathsTextField.text ?? "") ?? 0
        MatchStore.shared.currentAssists = Int(assistsTextField.text ?? "") ?? 0

        let confirmEnemyVC = ConfirmEnemyTeamViewController()
        navigationController?.pushViewController(confirmEnemyVC, animated: true)
    }
}
