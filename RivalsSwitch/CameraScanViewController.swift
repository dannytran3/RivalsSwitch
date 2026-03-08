//
//  CameraScanViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Camera Scan Screen
//

import UIKit
import Vision

class CameraScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Elements
    private let photoImageView = UIImageView()
    private let detectedHeroesLabel = UILabel()
    private let takePhotoButton = UIButton(type: .system)
    private let usePhotoButton = UIButton(type: .system)
    private let retakePhotoButton = UIButton(type: .system)
    private let imagePicker = UIImagePickerController()
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        
        // Photo Image View
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.backgroundColor = .appSecondaryBackground
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = 16
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = UIColor.appBorderColor.cgColor
        view.addSubview(photoImageView)
        
        // Detected Heroes Label
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
        
        // Take Photo Button - glassmorphism
        takePhotoButton.applyGlassmorphismStyle()
        takePhotoButton.setTitle("Take Photo", for: .normal)
        
        // Use Photo Button - gradient
        usePhotoButton.applyGradientStyle()
        
        // Retake Photo Button - secondary
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
        guard let image = photoImageView.image else {
            showAlert(title: "No Photo", message: "Please take or select a photo first.")
            return
        }

        runOCR(on: image)
    }

    @objc private func retakePhotoTapped() {
        photoImageView.image = nil
        detectedHeroesLabel.text = "Take a photo of the scoreboard"
        MatchStore.shared.clearCurrentMatch()
        takePhotoButton.isHidden = false
        usePhotoButton.isHidden = true
        retakePhotoButton.isHidden = true
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "OCR Error", message: error.localizedDescription)
                }
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }

            DispatchQueue.main.async {
                self.handleRecognizedText(recognizedStrings)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

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

    private func handleRecognizedText(_ lines: [String]) {
        let fullText = lines.joined(separator: "\n")
        detectedHeroesLabel.text = "Scan Complete"

        parseOCRText(fullText)

        // Navigate to Confirm My Stats
        let confirmStatsVC = ConfirmMyStatsViewController()
        navigationController?.pushViewController(confirmStatsVC, animated: true)
    }

    private func parseOCRText(_ text: String) {
        // Reset old data
        MatchStore.shared.clearCurrentMatch()

        let lower = text.lowercased()

        // Try to detect hero names from OCR text
        let knownHeroes = [
            "spider-man", "iron man", "hulk", "loki",
            "punisher", "magneto", "storm"
        ]

        var foundHeroes: [String] = []

        for hero in knownHeroes {
            if lower.contains(hero) {
                foundHeroes.append(hero.capitalized)
            }
        }

        // Very simple assumption:
        // first hero found = player's hero
        // next up to 6 heroes = enemy team
        if let first = foundHeroes.first {
            MatchStore.shared.currentHero = first
        }

        let enemies = Array(foundHeroes.dropFirst().prefix(6))
        if enemies.indices.contains(0) { MatchStore.shared.enemy1 = enemies[0] }
        if enemies.indices.contains(1) { MatchStore.shared.enemy2 = enemies[1] }
        if enemies.indices.contains(2) { MatchStore.shared.enemy3 = enemies[2] }
        if enemies.indices.contains(3) { MatchStore.shared.enemy4 = enemies[3] }
        if enemies.indices.contains(4) { MatchStore.shared.enemy5 = enemies[4] }
        if enemies.indices.contains(5) { MatchStore.shared.enemy6 = enemies[5] }

        // Very simple stat extraction:
        // look for all integers in the text and use first few as K/D/A
        let numbers = text
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }

        if numbers.indices.contains(0) { MatchStore.shared.currentKills = numbers[0] }
        if numbers.indices.contains(1) { MatchStore.shared.currentDeaths = numbers[1] }
        if numbers.indices.contains(2) { MatchStore.shared.currentAssists = numbers[2] }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
