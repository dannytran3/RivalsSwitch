//
//  CreateAccountViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic - Beautiful Create Account Screen
//

import UIKit
import AVFoundation

class CreateAccountViewController: UIViewController {
    
    // UI Elements
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let usernameLabel = UILabel()
    private let passwordLabel = UILabel()
    private let confirmPasswordLabel = UILabel()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let createAccountButton = UIButton(type: .system)
    private let signInLinkButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    private var logoAspectConstraint: NSLayoutConstraint?
    
    private var accentGradientLayer: CAGradientLayer?
    private var glowLayerTopRight: CAGradientLayer?
    private var glowLayerBottomLeft: CAGradientLayer?

    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var scrimLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        
        playerLayer?.frame = view.bounds
        scrimLayer?.frame = view.bounds
        
        accentGradientLayer?.frame = view.bounds
        if let glow1 = glowLayerTopRight {
            let size = max(view.bounds.width, view.bounds.height) * 0.55
            glow1.frame = CGRect(x: view.bounds.maxX - size * 0.75, y: -size * 0.25, width: size, height: size)
        }
        if let glow2 = glowLayerBottomLeft {
            let size = max(view.bounds.width, view.bounds.height) * 0.7
            glow2.frame = CGRect(x: -size * 0.35, y: view.bounds.maxY - size * 0.7, width: size, height: size)
        }
        
        createAccountButton.updateGradientFrame()
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
        
        // Animated background video (with bundle fallback)
        let videoURL = Bundle.main.url(forResource: "animated-background", withExtension: "mp4") ?? URL(fileURLWithPath: "/Users/danny/RivalsSwitch/RivalsSwitch/animated-background.mp4")
        let player = AVPlayer(url: videoURL)
        player.isMuted = true
        player.actionAtItemEnd = .none
        videoPlayer = player

        let vLayer = AVPlayerLayer(player: player)
        vLayer.videoGravity = .resizeAspectFill
        vLayer.frame = view.bounds
        if let base = gradientLayer {
            view.layer.insertSublayer(vLayer, above: base)
        } else {
            view.layer.insertSublayer(vLayer, at: 0)
        }
        playerLayer = vLayer

        // Scrim for lower half
        let scrim = CAGradientLayer()
        // Dark overlay on lower half (match Landing) so content is readable
        scrim.colors = [
            UIColor.clear.cgColor,
            UIColor.appPrimaryBackground.withAlphaComponent(0.5).cgColor,
            UIColor.appPrimaryBackground.withAlphaComponent(0.95).cgColor
        ]
        scrim.locations = [0.35, 0.65, 1.0]
        scrim.startPoint = CGPoint(x: 0.5, y: 0.0)
        scrim.endPoint = CGPoint(x: 0.5, y: 1.0)
        scrim.frame = view.bounds
        view.layer.insertSublayer(scrim, above: vLayer)
        scrimLayer = scrim

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player.play()
        
        let accent = CAGradientLayer()
        accent.colors = [UIColor.appSecondaryAccent.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        accent.locations = [0.0, 1.0]
        accent.startPoint = CGPoint(x: 0.5, y: 0.0)
        accent.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(accent, at: 1)
        accentGradientLayer = accent
        
        let makeGlow: (UIColor) -> CAGradientLayer = { color in
            let g = CAGradientLayer()
            g.type = .radial
            g.colors = [color.withAlphaComponent(0.35).cgColor, UIColor.clear.cgColor]
            g.locations = [0.0, 1.0]
            g.startPoint = CGPoint(x: 0.5, y: 0.5)
            g.endPoint = CGPoint(x: 1.0, y: 1.0)
            return g
        }
        let glowTR = makeGlow(UIColor.appSecondaryAccent)
        let glowBL = makeGlow(UIColor.appPrimaryAccent)
        view.layer.insertSublayer(glowTR, above: gradientLayer)
        view.layer.insertSublayer(glowBL, above: gradientLayer)
        self.glowLayerTopRight = glowTR
        self.glowLayerBottomLeft = glowBL
        
        // Logo Image - direct, no container
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        if let logoImage = UIImage(named: "Logo") {
            logoImageView.image = logoImage
        }
        view.addSubview(logoImageView)
        
        // Aspect ratio based on image
        if let img = logoImageView.image {
            let ratio = img.size.height / img.size.width
            logoAspectConstraint = logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: ratio)
            logoAspectConstraint?.isActive = true
        }
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Sign up for RivalsSwitch"
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "Username"
        view.addSubview(usernameLabel)
        
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.text = "Password"
        view.addSubview(passwordLabel)
        
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.text = "Confirm Password"
        view.addSubview(confirmPasswordLabel)
        
        // Username Text Field
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Enter your username"
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        view.addSubview(usernameTextField)
        
        // Password Text Field
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        
        // Confirm Password Text Field
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.placeholder = "Confirm your password"
        confirmPasswordTextField.isSecureTextEntry = true
        view.addSubview(confirmPasswordTextField)
        
        // Create Account Button
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.setTitle("Continue", for: .normal)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        view.addSubview(createAccountButton)
        
        // Sign In Link
        signInLinkButton.translatesAutoresizingMaskIntoConstraints = false
        signInLinkButton.setTitle("Sign in", for: .normal)
        signInLinkButton.contentHorizontalAlignment = .right
        signInLinkButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        view.addSubview(signInLinkButton)
        
        // Constraints: same lower-half, bottom-anchored layout as Landing and Login
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            logoImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            usernameTextField.heightAnchor.constraint(equalToConstant: 56),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 56),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 32),
            createAccountButton.heightAnchor.constraint(equalToConstant: 56),
            createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            signInLinkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            signInLinkButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            signInLinkButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Text field observers
        [usernameTextField, passwordTextField, confirmPasswordTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        }
    }
    
    private func setupStyling() {
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Title Label - white and bold for visibility over video
        titleLabel.font = .appHeading2
        titleLabel.textColor = .white
        
        // Field labels - white and semibold for visibility over video
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        usernameLabel.textColor = .white
        passwordLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        passwordLabel.textColor = .white
        confirmPasswordLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        confirmPasswordLabel.textColor = .white
        
        // Text fields with glassmorphism
        usernameTextField.applyGlassmorphismStyle()
        passwordTextField.applyGlassmorphismStyle()
        confirmPasswordTextField.applyGlassmorphismStyle()
        passwordTextField.enablePasswordToggle()
        confirmPasswordTextField.enablePasswordToggle()
        // Lighter placeholders for visibility over video
        [usernameTextField, passwordTextField, confirmPasswordTextField].forEach { field in
            guard let placeholderText = field.placeholder else { return }
            field.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.85)])
        }
        
        // Create Account button - gradient
        createAccountButton.applyGradientStyle()
        
        // Sign In Link - white for visibility over video
        signInLinkButton.setTitleColor(.white, for: .normal)
        signInLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.updateFocusState(true)
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
    }
    
    @objc private func createAccountTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return
        }

        UserSession.shared.register(username: username, password: password)
        
        // Navigate to app programmatically
        if let windowScene = view.window?.windowScene,
           let window = windowScene.windows.first {
            window.rootViewController = MainTabBarController()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    @objc private func signInTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

