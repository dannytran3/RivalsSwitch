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
    private let photoImageView = UIImageView()
    private let detectedHeroesLabel = UILabel()
    private let takePhotoButton = UIButton(type: .system)
    private let usePhotoButton = UIButton(type: .system)
    private let retakePhotoButton = UIButton(type: .system)
    private let imagePicker = UIImagePickerController()
    private var gradientLayer: CAGradientLayer?
    
    // Known heroes we want to detect from OCR text
    private let knownHeroes = [
        "spider-man", "iron man", "hulk", "loki",
        "punisher", "magneto", "storm", "thor"
    ]

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
        usePhotoButton.updateGradientFrame()
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
        
        // Image view used to preview the selected scoreboard photo
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.backgroundColor = .appSecondaryBackground
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = 16
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = UIColor.appBorderColor.cgColor
        view.addSubview(photoImageView)
        
        // Label that shows scan status to the user
        detectedHeroesLabel.translatesAutoresizingMaskIntoConstraints = false
        detectedHeroesLabel.text = "Take a photo of the scoreboard"
        detectedHeroesLabel.textAlignment = .center
        detectedHeroesLabel.numberOfLines = 0
        view.addSubview(detectedHeroesLabel)
        
        // Take Photo Button
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.setTitle("Take Photo", for: .normal)
        takePhotoButton.addTarget(self, action: #selector(takePhotoTapped), for: .touchUpInside)
        view.addSubview(takePhotoButton)
        
        // Use Photo Button
        usePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        usePhotoButton.setTitle("Use Photo", for: .normal)
        usePhotoButton.addTarget(self, action: #selector(usePhotoTapped), for: .touchUpInside)
        usePhotoButton.isHidden = true
        view.addSubview(usePhotoButton)
        
        // Retake Photo Button
        retakePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        retakePhotoButton.setTitle("Retake Photo", for: .normal)
        retakePhotoButton.addTarget(self, action: #selector(retakePhotoTapped), for: .touchUpInside)
        retakePhotoButton.isHidden = true
        view.addSubview(retakePhotoButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Photo Image View
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            photoImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Detected Heroes Label
            detectedHeroesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            detectedHeroesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            detectedHeroesLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            
            // Take Photo Button
            takePhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            takePhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            takePhotoButton.topAnchor.constraint(equalTo: detectedHeroesLabel.bottomAnchor, constant: 32),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Use Photo Button
            usePhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            usePhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            usePhotoButton.topAnchor.constraint(equalTo: detectedHeroesLabel.bottomAnchor, constant: 32),
            usePhotoButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Retake Photo Button
            retakePhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            retakePhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            retakePhotoButton.topAnchor.constraint(equalTo: usePhotoButton.bottomAnchor, constant: 16),
            retakePhotoButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupStyling() {
        // Navigation bar
        navigationController?.navigationBar.applyAppStyle()
        navigationItem.title = "Scan Match"
        
        // Detected heroes label
        detectedHeroesLabel.applyBodyMediumStyle()
        detectedHeroesLabel.textColor = .appSecondaryText
        
        // Take Photo Button, glassmorphism
        takePhotoButton.applyGlassmorphismStyle()
        takePhotoButton.setTitle("Take Photo", for: .normal)
        
        // Use Photo Button, gradient
        usePhotoButton.applyGradientStyle()
        
        // Retake Photo Button, secondary
        retakePhotoButton.applySecondaryStyle()
    }

    @objc private func takePhotoTapped() {
        #if targetEnvironment(simulator)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true)
        } else {
            showAlert(title: "Unavailable", message: "Photo library is not available.")
        }
        #else
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true)
        } else {
            showAlert(title: "Camera Unavailable", message: "This device does not support camera capture.")
        }
        #endif
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
        detectedHeroesLabel.text = "Take a photo of the scoreboard"
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
        
        print("OBSERVATION COUNT:", observations.count)
        
        let rows = buildRows(from: observations, in: image)
        
        print("OCR ROWS:")
        for row in rows {
            print(row.texts, "yellow:", row.yellowScore, "frame:", row.frame)
        }
        
        // Clear any previous in-progress match data before saving new OCR results
        MatchStore.shared.clearCurrentMatch()
        
        // Parse the selected player row first, then hero separately
        if let selectedRow = findSelectedPlayerRow(from: rows) {
            print("SELECTED ROW:", selectedRow.texts)
            parseSelectedPlayerData(from: selectedRow, using: observations)
        } else {
            print("NO SELECTED ROW FOUND")
        }
        
        parseHero(from: observations)
        
        print("SAVED HERO:", MatchStore.shared.currentHero)
        print("SAVED USERNAME:", MatchStore.shared.currentUsername)
        print("SAVED KDA:", MatchStore.shared.currentKills, MatchStore.shared.currentDeaths, MatchStore.shared.currentAssists)
        
        let confirmStatsVC = ConfirmMyStatsViewController()
        navigationController?.pushViewController(confirmStatsVC, animated: true)
    }

    private func buildRows(from observations: [VNRecognizedTextObservation], in image: UIImage) -> [OCRRow] {
        
        // Convert Vision observations into OCR items with helpful geometry info
        let items: [OCRItem] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            let rect = observation.boundingBox
            
            // Ignore empty OCR text
            guard !text.isEmpty else { return nil }
            
            // Ignore the top header and bottom hero stat strip
            if rect.midY > 0.86 || rect.midY < 0.28 {
                return nil
            }

            // Only use the left scoreboard when building player rows
            if rect.minX > 0.56 {
                return nil
            }
            
            return OCRItem(
                text: text,
                rect: rect,
                midY: rect.midY,
                minX: rect.minX,
                yellowScore: yellowScore(in: image, for: rect)
            )
        }
        
        let sorted = items.sorted {
            if abs($0.midY - $1.midY) > 0.03 {
                return $0.midY > $1.midY
            }
            return $0.minX < $1.minX
        }
        
        var groupedRows: [[OCRItem]] = []
        
        // Group nearby OCR items into the same logical scoreboard row
        for item in sorted {
            if let lastIndex = groupedRows.indices.last {
                let lastRowY = groupedRows[lastIndex].map(\.midY).reduce(0, +) / CGFloat(groupedRows[lastIndex].count)
                
                // If the Y value is close enough, treat it as the same row
                if abs(lastRowY - item.midY) < 0.03 {
                    groupedRows[lastIndex].append(item)
                } else {
                    groupedRows.append([item])
                }
            } else {
                groupedRows.append([item])
            }
        }
        
        // Convert grouped items into row models
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
                print("SELECTED ROW BY CLOSEST USERNAME:", bestMatch.0.texts, "distance:", bestMatch.1)
                return bestMatch.0
            }
        }

        // Otherwise, guess the selected row by looking for row-like patterns and yellow highlighting

        let candidateRows = rows.filter { row in
            let rowText = row.texts.joined(separator: " ").lowercased()
            let smallNumbers = extractSmallIntegers(from: rowText)

            guard containsUsernameLikeToken(in: row.texts) else { return false }
            guard smallNumbers.count >= 3 else { return false }
            guard row.texts.count >= 3 else { return false }

            return true
        }

        print("CANDIDATE ROWS:")
        for row in candidateRows {
            print(row.texts, "yellow:", row.yellowScore)
        }
        
        // The selected row is usually highlighted more strongly in yellow
        return candidateRows.max { $0.yellowScore < $1.yellowScore }
    }
    
    private func parseSelectedPlayerData(from selectedRow: OCRRow, using observations: [VNRecognizedTextObservation]) {
        // Save the full row text for debugging
        print("SELECTED ROW FRAME:", selectedRow.frame)
        print("SELECTED ROW YELLOW:", selectedRow.yellowScore)
        
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
        
        print("USERNAME BOX:", usernameTexts)
        print("KILLS BOX:", killTexts)
        print("DEATHS BOX:", deathTexts)
        print("ASSISTS BOX:", assistTexts)
        
        // Save the best OCR results into the shared match store
        let username = bestUsername(from: usernameTexts)
        let kills = firstInteger(in: killTexts.joined(separator: " "))
        let deaths = firstInteger(in: deathTexts.joined(separator: " "))
        let assists = firstInteger(in: assistTexts.joined(separator: " "))
        
        MatchStore.shared.currentUsername = username ?? ""
        MatchStore.shared.currentKills = kills ?? 0
        MatchStore.shared.currentDeaths = deaths ?? 0
        MatchStore.shared.currentAssists = assists ?? 0
    }
    
    private func parseHero(from observations: [VNRecognizedTextObservation]) {
        var bestHero = ""
        var bestDistance = Int.max

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }

            let text = normalizedOCRText(candidate.string)

            let rect = observation.boundingBox

            // Hero label is usually in the lower-left panel of the screenshot
            if rect.midY < 0.28 && rect.minX < 0.30 {
                for hero in knownHeroes {
                    let distance = levenshteinDistance(text, normalizedOCRText(hero))

                    if distance < bestDistance {
                        bestDistance = distance
                        bestHero = hero.capitalized
                    }
                }
            }
        }

        // Only accept close enough hero matches
        if bestDistance <= 3 {
            MatchStore.shared.currentHero = bestHero
        } else {
            MatchStore.shared.currentHero = ""
        }
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
    
    private func showAlert(title: String, message: String) {
        
        // Small helper for error/status messages
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
