import UIKit
import Vision

class CameraScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var detectedHeroesLabel: UILabel!

    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    @IBAction func takePhotoTapped(_ sender: UIButton) {
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

    @IBAction func usePhotoTapped(_ sender: UIButton) {
        guard let image = photoImageView.image else {
            showAlert(title: "No Photo", message: "Please take or select a photo first.")
            return
        }

        runOCR(on: image)
    }

    @IBAction func retakePhotoTapped(_ sender: UIButton) {
        photoImageView.image = nil
        detectedHeroesLabel.text = "Detected Heroes: None"
        MatchStore.shared.clearCurrentMatch()
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            detectedHeroesLabel.text = "Photo Loaded"
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

        performSegue(withIdentifier: "toConfirmMyStats", sender: self)
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
