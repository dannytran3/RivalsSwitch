//
//  CameraScanViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Camera Scan Screen
//

import UIKit
import Vision

// Handles the full photo scanning flow, take/selects image, run OCR, extract stats, then move to confirmation screens
class CameraScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Represents one OCR text observation and some extra info that helps group text into scoreboard rows
    private struct OCRItem {
        let text: String
        let rect: CGRect
        let midY: CGFloat
        let minX: CGFloat
        let yellowScore: CGFloat
    }
    
    // Represents one grouped scoreboard row from OCR results
    private struct OCRRow {
        let texts: [String]
        let frame: CGRect
        let midY: CGFloat
        let yellowScore: CGFloat
    }
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let introTitleLabel = UILabel()
    private let tipsLabel = UILabel()
    private let examplePane = UIView()
    private let exampleImageView = UIImageView()
    private let exampleCaptionLabel = UILabel()
    private let yourPhotoCaptionLabel = UILabel()
    private let photoImageView = UIImageView()
    private let detectedHeroesLabel = UILabel()
    private let takePhotoButton = UIButton(type: .custom)
    private let usePhotoButton = UIButton(type: .custom)
    private let retakePhotoButton = UIButton(type: .custom)
    private let imagePicker = UIImagePickerController()
    private var gradientLayer: CAGradientLayer?
    
    // Known heroes we want to detect from OCR text
    private var knownHeroes: [String] {
        let heroNames = HeroRegistry.shared.allHeroes.map { $0.name.lowercased() }
        let aliases = Array(HeroRegistry.shared.ocrHeroAliases().keys)
        return heroNames + aliases
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up image picker and screen UI
        imagePicker.delegate = self
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Keep background and gradient button styling updated on layout changes
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
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        introTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        introTitleLabel.text = "Scoreboard screenshot"
        introTitleLabel.textAlignment = .natural
        introTitleLabel.numberOfLines = 0
        contentView.addSubview(introTitleLabel)
        
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.text = "Use the in-game Tab scoreboard. Your hero is read from the bottom stats bar (explicit name next to your portrait). K/D/A is taken from your team row that matches that hero — not from highlight color. Enemies are read from the right column only.\n\nBest results: capture when every portrait is visible and not covered. During respawn, large timer numbers often sit on top of faces and confuse scanning."
        tipsLabel.textAlignment = .natural
        tipsLabel.numberOfLines = 0
        contentView.addSubview(tipsLabel)
        
        examplePane.translatesAutoresizingMaskIntoConstraints = false
        examplePane.applyCardStyle()
        contentView.addSubview(examplePane)
        
        exampleImageView.translatesAutoresizingMaskIntoConstraints = false
        exampleImageView.contentMode = .scaleAspectFit
        exampleImageView.layer.cornerRadius = 12
        exampleImageView.clipsToBounds = true
        exampleImageView.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        
        func loadBundledScoreboardExample() -> UIImage? {
            if let img = UIImage(named: "ScoreboardExample") { return img }
            
            let candidates: [URL] = [
                Bundle.main.url(forResource: "ScoreboardExample", withExtension: "jpeg", subdirectory: "MarvalRivals-icons"),
                Bundle.main.url(forResource: "ScoreboardExample", withExtension: "jpg", subdirectory: "MarvalRivals-icons"),
                Bundle.main.url(forResource: "ScoreboardExample", withExtension: "jpeg", subdirectory: nil),
                Bundle.main.url(forResource: "ScoreboardExample", withExtension: "jpg", subdirectory: nil),
            ].compactMap { $0 }
            
            for url in candidates {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) { return img }
            }
            
            // Some builds flatten/sync resources differently; fall back to scanning for the filename.
            for sub in ["MarvalRivals-icons", nil] as [String?] {
                if let urls = Bundle.main.urls(forResourcesWithExtension: "jpeg", subdirectory: sub) {
                    if let url = urls.first(where: { $0.lastPathComponent.lowercased() == "scoreboardexample.jpeg" }),
                       let data = try? Data(contentsOf: url),
                       let img = UIImage(data: data) {
                        return img
                    }
                }
                if let urls = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: sub) {
                    if let url = urls.first(where: { $0.lastPathComponent.lowercased() == "scoreboardexample.jpg" }),
                       let data = try? Data(contentsOf: url),
                       let img = UIImage(data: data) {
                        return img
                    }
                }
            }
            return nil
        }
        
        let example = loadBundledScoreboardExample()
        let didLoadExample = (example != nil)
        if let example {
            exampleImageView.image = example
        } else {
            let sym = UIImage(systemName: "photo.on.rectangle.angled")
            exampleImageView.image = sym
            exampleImageView.tintColor = .appTertiaryText
        }
        examplePane.addSubview(exampleImageView)
        
        exampleCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleCaptionLabel.text = didLoadExample
            ? "Example: tab scoreboard with clear portraits."
            : "Placeholder — missing ScoreboardExample.jpeg in app bundle."
        exampleCaptionLabel.textAlignment = .center
        exampleCaptionLabel.numberOfLines = 0
        examplePane.addSubview(exampleCaptionLabel)
        
        yourPhotoCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        yourPhotoCaptionLabel.text = "Your photo"
        yourPhotoCaptionLabel.textAlignment = .natural
        contentView.addSubview(yourPhotoCaptionLabel)
        
        // Preview of the user's scoreboard photo
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.backgroundColor = .appSecondaryBackground
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = 16
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = UIColor.appBorderColor.cgColor
        contentView.addSubview(photoImageView)
        
        detectedHeroesLabel.translatesAutoresizingMaskIntoConstraints = false
        detectedHeroesLabel.text = "Tap the button below to take a photo or choose a screenshot, then we’ll scan it."
        detectedHeroesLabel.textAlignment = .center
        detectedHeroesLabel.numberOfLines = 0
        contentView.addSubview(detectedHeroesLabel)
        
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.setTitle("Take or upload photo", for: .normal)
        takePhotoButton.addTarget(self, action: #selector(takePhotoTapped), for: .touchUpInside)
        contentView.addSubview(takePhotoButton)
        
        usePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        usePhotoButton.setTitle("Use Photo", for: .normal)
        usePhotoButton.addTarget(self, action: #selector(usePhotoTapped), for: .touchUpInside)
        usePhotoButton.isHidden = true
        contentView.addSubview(usePhotoButton)
        
        retakePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        retakePhotoButton.setTitle("Retake Photo", for: .normal)
        retakePhotoButton.addTarget(self, action: #selector(retakePhotoTapped), for: .touchUpInside)
        retakePhotoButton.isHidden = true
        contentView.addSubview(retakePhotoButton)
        
        let side: CGFloat = 24
        let inset: CGFloat = 32
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            introTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            introTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            introTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            
            tipsLabel.topAnchor.constraint(equalTo: introTitleLabel.bottomAnchor, constant: 10),
            tipsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            tipsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            
            examplePane.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: 16),
            examplePane.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            examplePane.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            examplePane.heightAnchor.constraint(greaterThanOrEqualToConstant: 168),
            
            exampleImageView.topAnchor.constraint(equalTo: examplePane.topAnchor, constant: 12),
            exampleImageView.leadingAnchor.constraint(equalTo: examplePane.leadingAnchor, constant: 12),
            exampleImageView.trailingAnchor.constraint(equalTo: examplePane.trailingAnchor, constant: -12),
            exampleImageView.heightAnchor.constraint(equalToConstant: 112),
            
            exampleCaptionLabel.topAnchor.constraint(equalTo: exampleImageView.bottomAnchor, constant: 10),
            exampleCaptionLabel.leadingAnchor.constraint(equalTo: examplePane.leadingAnchor, constant: 12),
            exampleCaptionLabel.trailingAnchor.constraint(equalTo: examplePane.trailingAnchor, constant: -12),
            exampleCaptionLabel.bottomAnchor.constraint(equalTo: examplePane.bottomAnchor, constant: -12),
            
            yourPhotoCaptionLabel.topAnchor.constraint(equalTo: examplePane.bottomAnchor, constant: 22),
            yourPhotoCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            yourPhotoCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            photoImageView.topAnchor.constraint(equalTo: yourPhotoCaptionLabel.bottomAnchor, constant: 8),
            photoImageView.heightAnchor.constraint(equalToConstant: 280),
            
            detectedHeroesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            detectedHeroesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            detectedHeroesLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            
            takePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            takePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            takePhotoButton.topAnchor.constraint(equalTo: detectedHeroesLabel.bottomAnchor, constant: 24),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 56),
            
            usePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            usePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            usePhotoButton.topAnchor.constraint(equalTo: detectedHeroesLabel.bottomAnchor, constant: 24),
            usePhotoButton.heightAnchor.constraint(equalToConstant: 56),
            
            retakePhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            retakePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            retakePhotoButton.topAnchor.constraint(equalTo: usePhotoButton.bottomAnchor, constant: 16),
            retakePhotoButton.heightAnchor.constraint(equalToConstant: 56),
            retakePhotoButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Scan Match"
        
        introTitleLabel.font = .appHeading4
        introTitleLabel.textColor = .appPrimaryText
        tipsLabel.font = .appBodyMedium
        tipsLabel.textColor = .appSecondaryText
        yourPhotoCaptionLabel.font = .appBodyLarge
        yourPhotoCaptionLabel.textColor = .appSecondaryText
        exampleCaptionLabel.font = .appBodySmall
        exampleCaptionLabel.textColor = .appTertiaryText
        
        // Detected heroes label
        detectedHeroesLabel.applyBodyMediumStyle()
        detectedHeroesLabel.textColor = .appSecondaryText
        
        takePhotoButton.applySolidPrimaryCTAStyle()
        takePhotoButton.setTitle("Take or upload photo", for: .normal)
        
        usePhotoButton.applySolidPrimaryCTAStyle()
        
        retakePhotoButton.applySecondaryStyle()
    }

    @objc private func takePhotoTapped() {
        let canUseCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        let canUseLibrary = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        if canUseCamera && canUseLibrary {
            let sheet = UIAlertController(title: "Add a scoreboard image", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Use camera", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
            sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .photoLibrary)
            })
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // iPad popover anchor
            if let popover = sheet.popoverPresentationController {
                popover.sourceView = takePhotoButton
                popover.sourceRect = takePhotoButton.bounds
            }
            
            present(sheet, animated: true)
            return
        }
        
        if canUseCamera {
            presentImagePicker(sourceType: .camera)
            return
        }
        
        if canUseLibrary {
            presentImagePicker(sourceType: .photoLibrary)
            return
        }
        
        showAlert(title: "Unavailable", message: "Camera and photo library are not available.")
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }

    @objc private func usePhotoTapped() {
        // Do not continue if no image was selected
        guard let image = photoImageView.image else {
            showAlert(title: "No Photo", message: "Please take or select a photo first.")
            return
        }

        // Start OCR on the selected photo
        runOCR(on: image)
    }

    @objc private func retakePhotoTapped() {
        // Reset the screen and clear any saved match data
        photoImageView.image = nil
        detectedHeroesLabel.text = "Tap the button below to take a photo or choose a screenshot, then we’ll scan it."
        MatchStore.shared.clearCurrentMatch()
        takePhotoButton.isHidden = false
        usePhotoButton.isHidden = true
        retakePhotoButton.isHidden = true
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Load the chosen image into the preview
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            detectedHeroesLabel.text = "Photo Loaded"
            takePhotoButton.isHidden = true
            usePhotoButton.isHidden = false
            retakePhotoButton.isHidden = false
        }

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    private func runOCR(on image: UIImage) {
        guard let cgImage = image.cgImage else {
            showAlert(title: "Scan Error", message: "Could not read the selected image.")
            return
        }

        // Create Vision request for text recognition
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "OCR Error", message: error.localizedDescription)
                }
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            DispatchQueue.main.async {
                self.handleRecognizedText(observations, in: image)
            }
        }

        // Use more accurate recognition settings for scoreboard text
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Run OCR off the main thread so the UI stays responsive
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Scan Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func handleRecognizedText(_ observations: [VNRecognizedTextObservation], in image: UIImage) {
        detectedHeroesLabel.text = "Scan Complete"
        
        let splitX = scoreboardColumnSplitX(from: observations)
        let (rowMinMidY, rowMaxMidY) = scoreboardRowMidYRange(from: observations)
        
        let leftRows = buildRows(
            from: filteredYourTeamObservations(from: observations),
            in: image,
            splitX: splitX,
            minMidY: rowMinMidY,
            maxMidY: rowMaxMidY
        )
        
        // Clear any previous in-progress match data before saving new OCR results
        MatchStore.shared.clearCurrentMatch()
        
        if let bottomHero = parseBottomBarPlayingHero(from: observations), !bottomHero.isEmpty {
            MatchStore.shared.currentHero = bottomHero
        } else {
            parseHero(from: observations)
        }
        
        if let statsRow = findMyStatsRow(from: leftRows, playingHero: MatchStore.shared.currentHero) {
            parseSelectedPlayerData(from: statsRow, using: observations)
        }
        
        parseEnemyTeam(
            from: observations,
            in: image,
            splitX: splitX,
            minMidY: rowMinMidY,
            maxMidY: rowMaxMidY
        )
        parseFriendlyTeam(
            from: filteredYourTeamObservations(from: observations),
            in: image,
            splitX: splitX,
            minMidY: rowMinMidY,
            maxMidY: rowMaxMidY
        )

        // Enemy hero identity comes from portrait matching only (rows show usernames, not hero names).
        // Anchor portrait crops to YOUR TEAM row midYs — enemy rows are at the same Y positions.
        let friendlyRowMidYs = leftRows.prefix(6).map { $0.midY }

        DispatchQueue.global(qos: .userInitiated).async {
            HeroPortraitMatcher.shared.refineEnemyTeamWithPortraits(
                in: image,
                friendlyRowMidYs: Array(friendlyRowMidYs),
                splitX: splitX
            ) {
                let confirmStatsVC = ConfirmMyStatsViewController()
                self.navigationController?.pushViewController(confirmStatsVC, animated: true)
            }
        }
    }

    /// Left team column — `splitX` comes from OCR layout (gap between columns), not a fixed fraction.
    private func buildRows(from observations: [VNRecognizedTextObservation], in image: UIImage, splitX: CGFloat, minMidY: CGFloat, maxMidY: CGFloat) -> [OCRRow] {
        let margin: CGFloat = 0.008
        return buildSideRows(from: observations, in: image, includeMinX: { $0 <= splitX - margin }, minMidY: minMidY, maxMidY: maxMidY)
    }
    
    /// Enemy column — right of `splitX`.
    private func buildEnemyRows(from observations: [VNRecognizedTextObservation], in image: UIImage, splitX: CGFloat, minMidY: CGFloat, maxMidY: CGFloat) -> [OCRRow] {
        let margin: CGFloat = 0.008
        return buildSideRows(from: observations, in: image, includeMinX: { $0 >= splitX + margin }, minMidY: minMidY, maxMidY: maxMidY)
    }
    
    /// Estimate vertical band where scoreboard **rows** live from headers; wide fallback for cropped / odd aspect images.
    private func scoreboardRowMidYRange(from observations: [VNRecognizedTextObservation]) -> (CGFloat, CGFloat) {
        let fallbackMin: CGFloat = 0.08
        let fallbackMax: CGFloat = 0.96
        var maxMidY = fallbackMax
        if let e = enemyTeamHeaderMinY(from: observations) { maxMidY = min(maxMidY, e - 0.015) }
        if let y = yourTeamHeaderMinY(from: observations) { maxMidY = min(maxMidY, y - 0.015) }
        let minMidY: CGFloat = 0.10
        guard maxMidY > minMidY + 0.06 else { return (fallbackMin, fallbackMax) }
        return (minMidY, maxMidY)
    }
    
    /// Horizontal split between “your team” and “enemy” columns from OCR clusters (works when the scoreboard is cropped or full-screen).
    private func scoreboardColumnSplitX(from observations: [VNRecognizedTextObservation]) -> CGFloat {
        var leftMaxX: CGFloat = 0
        var rightMinX: CGFloat = 1
        for obs in observations {
            let r = obs.boundingBox
            let m = r.midX
            if m < 0.46 { leftMaxX = max(leftMaxX, r.maxX) }
            if m > 0.54 { rightMinX = min(rightMinX, r.minX) }
        }
        if leftMaxX > 0.18, rightMinX < 0.92, rightMinX > leftMaxX + 0.03 {
            return (leftMaxX + rightMinX) / 2
        }
        return 0.52
    }

    /// If the OCR sees the "ENEMY TEAM" header, use its bottom edge as the top bound for enemy rows.
    private func enemyTeamHeaderMinY(from observations: [VNRecognizedTextObservation]) -> CGFloat? {
        struct Hit { let minY: CGFloat; let area: CGFloat }
        var hits: [Hit] = []
        for obs in observations {
            guard let cand = obs.topCandidates(1).first else { continue }
            let t = cand.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let n = normalizedOCRText(t)
            guard !n.isEmpty else { continue }
            // Match "ENEMY TEAM" or close OCR variants (enemyteam, enem yteam, etc).
            guard n.contains("enemyteam") || (n.contains("enemy") && n.contains("team")) else { continue }
            let r = obs.boundingBox
            // Header sits near the top center/right.
            guard r.midY > 0.72 else { continue }
            hits.append(Hit(minY: r.minY, area: r.width * r.height))
        }
        guard let best = hits.max(by: { $0.area < $1.area }) else { return nil }
        return best.minY
    }

    /// If the OCR sees the "YOUR TEAM" header, use its bottom edge as the top bound for friendly rows.
    private func yourTeamHeaderMinY(from observations: [VNRecognizedTextObservation]) -> CGFloat? {
        struct Hit { let minY: CGFloat; let area: CGFloat }
        var hits: [Hit] = []
        for obs in observations {
            guard let cand = obs.topCandidates(1).first else { continue }
            let t = cand.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let n = normalizedOCRText(t)
            guard !n.isEmpty else { continue }
            guard n.contains("yourteam") || (n.contains("your") && n.contains("team")) else { continue }
            let r = obs.boundingBox
            guard r.midY > 0.72 else { continue }
            hits.append(Hit(minY: r.minY, area: r.width * r.height))
        }
        guard let best = hits.max(by: { $0.area < $1.area }) else { return nil }
        return best.minY
    }

    /// Filters OCR to the scoreboard rows only (excludes bottom HUD stats bar).
    private func filteredYourTeamObservations(from observations: [VNRecognizedTextObservation]) -> [VNRecognizedTextObservation] {
        let minMidY: CGFloat = 0.34
        let maxMidY: CGFloat = 0.86
        let topBound = yourTeamHeaderMinY(from: observations)
        return observations.filter { obs in
            let r = obs.boundingBox
            guard r.midY >= minMidY, r.midY <= maxMidY else { return false }
            if let topBound {
                guard r.maxY < topBound else { return false }
            }
            return true
        }
    }
    
    private func buildSideRows(
        from observations: [VNRecognizedTextObservation],
        in image: UIImage,
        includeMinX: (CGFloat) -> Bool,
        minMidY: CGFloat,
        maxMidY: CGFloat
    ) -> [OCRRow] {
        let items: [OCRItem] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let rect = observation.boundingBox
            
            guard !text.isEmpty else { return nil }
            if rect.midY > maxMidY || rect.midY < minMidY {
                return nil
            }
            guard includeMinX(rect.minX) else { return nil }
            
            return OCRItem(
                text: text,
                rect: rect,
                midY: rect.midY,
                minX: rect.minX,
                yellowScore: yellowScore(in: image, for: rect)
            )
        }
        
        let sorted = items.sorted {
            if abs($0.midY - $1.midY) > 0.042 {
                return $0.midY > $1.midY
            }
            return $0.minX < $1.minX
        }
        
        var groupedRows: [[OCRItem]] = []
        
        let rowYMerge: CGFloat = 0.042
        for item in sorted {
            if let lastIndex = groupedRows.indices.last {
                let lastRowY = groupedRows[lastIndex].map(\.midY).reduce(0, +) / CGFloat(groupedRows[lastIndex].count)
                
                if abs(lastRowY - item.midY) < rowYMerge {
                    groupedRows[lastIndex].append(item)
                } else {
                    groupedRows.append([item])
                }
            } else {
                groupedRows.append([item])
            }
        }
        
        return groupedRows.map { row in
            let ordered = row.sorted { $0.minX < $1.minX }
            let texts = ordered.map(\.text)
            let avgY = ordered.map(\.midY).reduce(0, +) / CGFloat(ordered.count)
            let avgYellow = ordered.map(\.yellowScore).reduce(0, +) / CGFloat(ordered.count)
            let frame = ordered.reduce(CGRect.null) { partial, item in
                partial.union(item.rect)
            }
            
            return OCRRow(
                texts: texts,
                frame: frame,
                midY: avgY,
                yellowScore: avgYellow
            )
        }
    }
    
    /// First hero name found in row text, left → right; empty if none (leave slot blank).
    private func heroNameForScoreboardRow(_ row: OCRRow) -> String {
        bestHeroNameFromScoreboardRow(row)
    }
    
    /// OCR order varies (username/KDA before hero). Consider every token plus the whole row; prefer longest matching hero name.
    private func bestHeroNameFromScoreboardRow(_ row: OCRRow) -> String {
        var candidates: [String] = []
        for text in row.texts {
            if let name = bestMatchingHeroName(from: text) {
                candidates.append(name)
            }
        }
        if candidates.isEmpty {
            let joined = row.texts.joined(separator: " ")
            return bestMatchingHeroName(from: joined) ?? ""
        }
        let unique = Array(Set(candidates))
        return unique.max(by: { $0.count < $1.count }) ?? candidates[0]
    }
    
    /// Post-match bar at the bottom names your hero explicitly (e.g. "ANGELA"); Vision `midY` is low there.
    private func parseBottomBarPlayingHero(from observations: [VNRecognizedTextObservation]) -> String? {
        let bottomMidYMax: CGFloat = 0.38
        let maxX: CGFloat = 0.58
        
        struct Hit {
            let name: String
            let area: CGFloat
            let midY: CGFloat
        }
        var hits: [Hit] = []
        
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let rect = observation.boundingBox
            guard rect.midY < bottomMidYMax, rect.minX < maxX else { continue }
            guard let hero = bestMatchingHeroName(from: text) else { continue }
            let area = rect.width * rect.height
            hits.append(Hit(name: hero, area: area, midY: rect.midY))
        }
        
        guard !hits.isEmpty else { return nil }
        return hits.max { a, b in
            if a.area != b.area { return a.area < b.area }
            return a.midY > b.midY
        }?.name
    }
    
    /// Prefer the left-column row whose OCR hero matches the bottom-bar hero; then saved username; then yellow highlight.
    private func findMyStatsRow(from rows: [OCRRow], playingHero: String) -> OCRRow? {
        let ph = playingHero.trimmingCharacters(in: .whitespacesAndNewlines)
        if !ph.isEmpty {
            for row in rows {
                let hn = heroNameForScoreboardRow(row)
                if hn.caseInsensitiveCompare(ph) == .orderedSame { return row }
            }
            let phNorm = normalizedOCRText(ph)
            var bestRow: OCRRow?
            var bestDist = Int.max
            for row in rows {
                let hn = heroNameForScoreboardRow(row)
                guard !hn.isEmpty else { continue }
                if normalizedOCRText(hn) == phNorm { return row }
                let d = levenshteinDistance(normalizedOCRText(hn), phNorm)
                let limit = phNorm.count <= 6 ? 2 : 4
                guard d <= limit, d < bestDist else { continue }
                bestDist = d
                bestRow = row
            }
            if let r = bestRow { return r }
        }
        return findSelectedPlayerRow(from: rows)
    }
    
    private func findSelectedPlayerRow(from rows: [OCRRow]) -> OCRRow? {
        // If the user has a saved username, try matching against that first
        let savedUsername = UserDefaults.standard
            .string(forKey: "username")?
            .lowercased()
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if let savedUsername, !savedUsername.isEmpty {
            let bestUsernameMatch = rows.compactMap { row -> (OCRRow, Int)? in
                guard let candidate = bestUsername(from: row.texts)?.lowercased() else { return nil }
                let distance = levenshteinDistance(savedUsername, candidate)
                return (row, distance)
            }
            .min { $0.1 < $1.1 }

            if let bestMatch = bestUsernameMatch, bestMatch.1 <= 4 {
                return bestMatch.0
            }
        }

        // Otherwise guess the selected row (yellow highlight is a weak signal — prefer bottom-bar hero + row match when possible)

        let candidateRows = rows.filter { row in
            let rowText = row.texts.joined(separator: " ").lowercased()
            let smallNumbers = extractSmallIntegers(from: rowText)

            guard containsUsernameLikeToken(in: row.texts) else { return false }
            guard smallNumbers.count >= 3 else { return false }
            guard row.texts.count >= 3 else { return false }

            return true
        }

        return candidateRows.max { $0.yellowScore < $1.yellowScore }
    }
    
    private func parseSelectedPlayerData(from selectedRow: OCRRow, using observations: [VNRecognizedTextObservation]) {
        let rowJoined = selectedRow.texts.joined(separator: " ")
        let rowKDA = extractLastKDATripleFromRowText(rowJoined)
        
        // Estimate subregions of the selected row for username and K/D/A columns
        let usernameBox = CGRect(
            x: selectedRow.frame.minX + selectedRow.frame.width * 0.22,
            y: selectedRow.frame.minY - selectedRow.frame.height * 0.15,
            width: selectedRow.frame.width * 0.40,
            height: selectedRow.frame.height * 1.30
        )
        
        let killsBox = CGRect(
            x: selectedRow.frame.minX + selectedRow.frame.width * 0.70,
            y: selectedRow.frame.minY - selectedRow.frame.height * 0.15,
            width: selectedRow.frame.width * 0.08,
            height: selectedRow.frame.height * 1.30
        )
        
        let deathsBox = CGRect(
            x: selectedRow.frame.minX + selectedRow.frame.width * 0.80,
            y: selectedRow.frame.minY - selectedRow.frame.height * 0.15,
            width: selectedRow.frame.width * 0.08,
            height: selectedRow.frame.height * 1.30
        )
        
        let assistsBox = CGRect(
            x: selectedRow.frame.minX + selectedRow.frame.width * 0.90,
            y: selectedRow.frame.minY - selectedRow.frame.height * 0.15,
            width: selectedRow.frame.width * 0.08,
            height: selectedRow.frame.height * 1.30
        )
        
        // Pull OCR text found inside each estimated region
        let usernameTexts = texts(in: usernameBox, from: observations)
        let killTexts = texts(in: killsBox, from: observations)
        let deathTexts = texts(in: deathsBox, from: observations)
        let assistTexts = texts(in: assistsBox, from: observations)
        
        // Save the best OCR results into the shared match store
        let username = bestUsername(from: usernameTexts)
        let kills = rowKDA?.0 ?? firstInteger(in: killTexts.joined(separator: " "))
        let deaths = rowKDA?.1 ?? firstInteger(in: deathTexts.joined(separator: " "))
        let assists = rowKDA?.2 ?? firstInteger(in: assistTexts.joined(separator: " "))
        
        MatchStore.shared.currentUsername = username ?? ""
        MatchStore.shared.currentKills = kills ?? 0
        MatchStore.shared.currentDeaths = deaths ?? 0
        MatchStore.shared.currentAssists = assists ?? 0
    }
    
    /// Fallback when the bottom stats bar does not OCR a hero (scan lower-left for the largest hero-shaped title).
    private func parseHero(from observations: [VNRecognizedTextObservation]) {
        var bestHero = ""
        var bestArea: CGFloat = 0
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let rect = observation.boundingBox
            guard rect.midY < 0.40, rect.minX < 0.45 else { continue }
            guard let matchedHero = bestMatchingHeroName(from: text) else { continue }
            let area = rect.width * rect.height
            if area >= bestArea {
                bestArea = area
                bestHero = matchedHero
            }
        }
        MatchStore.shared.currentHero = bestHero
    }
    
    /// K/D/A usually appears as three adjacent small ints in the scoreboard row.
    /// We take the *last* three small ints (rightmost) to avoid grabbing rank/level earlier in the row.
    private func extractLastKDATripleFromRowText(_ text: String) -> (Int, Int, Int)? {
        let nums = extractSmallIntegers(from: text)
        guard nums.count >= 3 else { return nil }
        let last3 = Array(nums.suffix(3))
        let k = last3[0], d = last3[1], a = last3[2]
        guard (0...199).contains(k), (0...199).contains(d), (0...999).contains(a) else { return nil }
        return (k, d, a)
    }
    
    /// Returns up to six enemy **row frames** (Vision normalized) for portrait matching — empty rects are ignored by the matcher.
    @discardableResult
    private func parseEnemyTeam(from observations: [VNRecognizedTextObservation], in image: UIImage, splitX: CGFloat, minMidY: CGFloat, maxMidY: CGFloat) -> [CGRect] {
        // Prefer text strictly *below* the ENEMY TEAM title (midY below header bottom). Fallback if that strips too much OCR.
        let filtered: [VNRecognizedTextObservation]
        if let headerBottom = enemyTeamHeaderMinY(from: observations) {
            let cut = headerBottom - 0.012
            let belowHeader = observations.filter { $0.boundingBox.midY < cut }
            filtered = belowHeader.count >= 12 ? belowHeader : observations
        } else {
            filtered = observations
        }
        var rows = buildEnemyRows(from: filtered, in: image, splitX: splitX, minMidY: minMidY, maxMidY: maxMidY)
        if rows.count < 4 {
            rows = buildEnemyRows(from: observations, in: image, splitX: splitX, minMidY: minMidY, maxMidY: maxMidY)
        }
        let fromRows = rows.prefix(6).map { bestHeroNameFromScoreboardRow($0) }
        let frames = Array(rows.prefix(6).map(\.frame))
        let padded = Array(fromRows) + Array(repeating: "", count: max(0, 6 - fromRows.count))
        let deduped = MatchStore.dedupeEnemyHeroSlotsPreservingOrder(padded)
        saveEnemyTeam(deduped)
        return frames
    }
    
    private func parseFriendlyTeam(from observations: [VNRecognizedTextObservation], in image: UIImage, splitX: CGFloat, minMidY: CGFloat, maxMidY: CGFloat) {
        let rows = buildRows(from: observations, in: image, splitX: splitX, minMidY: minMidY, maxMidY: maxMidY)
        let fromRows = rows.prefix(6).map { heroNameForScoreboardRow($0) }
        let padded = Array(fromRows) + Array(repeating: "", count: max(0, 6 - fromRows.count))
        saveFriendlyTeam(padded)
    }
    
    private func texts(in region: CGRect, from observations: [VNRecognizedTextObservation]) -> [String] {
        
        // Return OCR strings whose bounding boxes overlap the requested region
        observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            
            let rect = observation.boundingBox
            
            guard region.intersects(rect) else { return nil }
            
            return candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func bestUsername(from texts: [String]) -> String? {
        
        // Choose the longest reasonable OCR token that is not a hero name
        let cleaned = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { text in
                let lower = text.lowercased()
                return !knownHeroes.contains(lower)
            }
            .sorted { $0.count > $1.count }
        
        return cleaned.first
    }
    
    private func firstInteger(in text: String) -> Int? {
        
        // Extract the first integer found in a text blob
        let numbers = text
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        
        return numbers.first
    }
    
    private func extractSmallIntegers(from text: String) -> [Int] {
        
        // Useful for identifying scoreboard rows that contain K/D/A-like values
        text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
            .filter { $0 >= 0 && $0 <= 99 }
    }
    
    private func containsUsernameLikeToken(in texts: [String]) -> Bool {
        
        // Heuristic for whether a row likely contains a username
        for token in texts {
            let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = trimmed.lowercased()
            
            if trimmed.count < 3 { continue }
            if knownHeroes.contains(lower) { continue }
            if Int(trimmed) != nil { continue }
            
            let hasLetters = lower.rangeOfCharacter(from: .letters) != nil
            if hasLetters {
                return true
            }
        }
        
        return false
    }
    
    private func yellowScore(in image: UIImage, for normalizedRect: CGRect) -> CGFloat {
        guard let cgImage = image.cgImage else { return 0 }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Convert normalized Vision coordinates into pixel coordinates
        let pixelRect = CGRect(
            x: normalizedRect.minX * imageWidth,
            y: (1.0 - normalizedRect.maxY) * imageHeight,
            width: normalizedRect.width * imageWidth,
            height: normalizedRect.height * imageHeight
        ).integral
        
        // Sample the average color of this OCR region
        guard pixelRect.width > 0, pixelRect.height > 0 else { return 0 }
        guard let cropped = cgImage.cropping(to: pixelRect) else { return 0 }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        var rawData = [UInt8](repeating: 0, count: 4)
        
        // Sample the average color of this OCR region
        guard let context = CGContext(
            data: &rawData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return 0
        }
        
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let red = CGFloat(rawData[0]) / 255.0
        let green = CGFloat(rawData[1]) / 255.0
        let blue = CGFloat(rawData[2]) / 255.0
        
        // Selected scoreboard text tends to have strong yellow values
        return (red + green) - blue
    }

    private func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        
        // Standard edit distance used to compare OCR results to known text
        let a = Array(lhs)
        let b = Array(rhs)

        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count {
            dp[i][0] = i
        }

        for j in 0...b.count {
            dp[0][j] = j
        }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(
                        dp[i - 1][j] + 1,
                        dp[i][j - 1] + 1,
                        dp[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dp[a.count][b.count]
    }
    
    private func normalizedOCRText(_ text: String) -> String {
        
        // Normalize OCR text for easier fuzzy matching
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
    
    private func bestMatchingHeroName(from rawText: String) -> String? {
        let normalizedText = normalizedOCRText(rawText)
        guard !normalizedText.isEmpty else { return nil }

        var candidates: [String: String] = [:]

        for hero in HeroRegistry.shared.allHeroes {
            candidates[normalizedOCRText(hero.name)] = hero.name
        }

        for (alias, heroName) in HeroRegistry.shared.ocrHeroAliases() {
            candidates[normalizedOCRText(alias)] = heroName
        }

        if let exact = candidates[normalizedText] {
            return exact
        }

        for (candidate, heroName) in candidates {
            if normalizedText.contains(candidate) || candidate.contains(normalizedText) {
                return heroName
            }
        }

        var bestHeroName: String?
        var bestDistance = Int.max

        for (candidate, heroName) in candidates {
            let distance = levenshteinDistance(normalizedText, candidate)
            if distance < bestDistance {
                bestDistance = distance
                bestHeroName = heroName
            }
        }

        if normalizedText.count <= 4 {
            return bestDistance <= 1 ? bestHeroName : nil
        } else if normalizedText.count <= 8 {
            return bestDistance <= 2 ? bestHeroName : nil
        } else {
            return bestDistance <= 4 ? bestHeroName : nil
        }
    }

    private func saveFriendlyTeam(_ heroes: [String]) {
        MatchStore.shared.team1 = heroes.count > 0 ? heroes[0] : ""
        MatchStore.shared.team2 = heroes.count > 1 ? heroes[1] : ""
        MatchStore.shared.team3 = heroes.count > 2 ? heroes[2] : ""
        MatchStore.shared.team4 = heroes.count > 3 ? heroes[3] : ""
        MatchStore.shared.team5 = heroes.count > 4 ? heroes[4] : ""
        MatchStore.shared.team6 = heroes.count > 5 ? heroes[5] : ""
    }

    private func saveEnemyTeam(_ heroes: [String]) {
        MatchStore.shared.enemy1 = heroes.count > 0 ? heroes[0] : ""
        MatchStore.shared.enemy2 = heroes.count > 1 ? heroes[1] : ""
        MatchStore.shared.enemy3 = heroes.count > 2 ? heroes[2] : ""
        MatchStore.shared.enemy4 = heroes.count > 3 ? heroes[3] : ""
        MatchStore.shared.enemy5 = heroes.count > 4 ? heroes[4] : ""
        MatchStore.shared.enemy6 = heroes.count > 5 ? heroes[5] : ""
    }
    
    private func showAlert(title: String, message: String) {
        
        // Small helper for error/status messages
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
