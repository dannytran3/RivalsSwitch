//
//  CreateAccountViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic - Beautiful Create Account Screen
//

import UIKit
import AVFoundation

// Handles account creation for new users
class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let usernameLabel = UILabel()
    private let passwordLabel = UILabel()
    private let confirmPasswordLabel = UILabel()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let createAccountButton = UIButton(type: .custom)
    private let signInLinkButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    private var logoAspectConstraint: NSLayoutConstraint?
    
    private var accentGradientLayer: CAGradientLayer?
    private var glowLayerTopRight: CAGradientLayer?
    private var glowLayerBottomLeft: CAGradientLayer?

    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var scrimLayer: CAGradientLayer?
    
    private weak var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
    }

    // Keep auth screens stable; allow rotation elsewhere.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var shouldAutorotate: Bool { false }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Keep layered backgrounds and button styling aligned with the view size
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
        
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Scroll container (standard iOS keyboard-safe approach)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
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

        // Keep the video looping
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player.play()
        
        // Accent overlay
        let accent = CAGradientLayer()
        accent.colors = [UIColor.appSecondaryAccent.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        accent.locations = [0.0, 1.0]
        accent.startPoint = CGPoint(x: 0.5, y: 0.0)
        accent.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(accent, at: 1)
        accentGradientLayer = accent
        
        // Background gradient
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
        
        // Logo Image, direct, no container
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        if let logoImage = UIImage(named: "Logo") {
            logoImageView.image = logoImage
        }
        contentView.addSubview(logoImageView)
        
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
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Field labels
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "Username"
        contentView.addSubview(usernameLabel)
        
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.text = "Password"
        contentView.addSubview(passwordLabel)
        
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.text = "Confirm Password"
        contentView.addSubview(confirmPasswordLabel)
        
        // Username Text Field
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Enter your username"
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .next
        usernameTextField.delegate = self
        contentView.addSubview(usernameTextField)
        
        // Password Text Field
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .next
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)
        
        // Confirm Password Text Field
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.placeholder = "Confirm your password"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.delegate = self
        contentView.addSubview(confirmPasswordTextField)
        
        // Create Account Button
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.setTitle("Sign up", for: .normal)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        contentView.addSubview(createAccountButton)
        
        // Sign In Link
        signInLinkButton.translatesAutoresizingMaskIntoConstraints = false
        signInLinkButton.setTitle("Sign in", for: .normal)
        signInLinkButton.contentHorizontalAlignment = .right
        signInLinkButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        contentView.addSubview(signInLinkButton)
        
        let side: CGFloat = 28
        NSLayoutConstraint.activate([
            signInLinkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            signInLinkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            signInLinkButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.55),
            logoImageView.topAnchor.constraint(equalTo: signInLinkButton.bottomAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            usernameTextField.heightAnchor.constraint(equalToConstant: 52),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            passwordLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordTextField.heightAnchor.constraint(equalToConstant: 52),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 6),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 52),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 22),
            createAccountButton.heightAnchor.constraint(equalToConstant: 52),
            createAccountButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
        
        // Focus + return behavior is handled via UITextFieldDelegate
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
        
        createAccountButton.applySolidPrimaryCTAStyle()
        
        // Sign In Link - white for visibility over video
        signInLinkButton.setTitleColor(.white, for: .normal)
        signInLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        textField.updateFocusState(true)
        DispatchQueue.main.async { [weak self] in
            self?.scrollFieldIntoView(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.updateFocusState(false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        if textField === passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
            return true
        }
        if textField === confirmPasswordTextField {
            textField.resignFirstResponder()
            return true
        }
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
    
    private func scrollFieldIntoView(_ textField: UITextField) {
        let rectInScroll = textField.convert(textField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rectInScroll.insetBy(dx: 0, dy: -24), animated: true)
    }
    
    @objc private func createAccountTapped() {
        
        // Make sure every field was filled in
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }
        
        // Make sure both passwords match
        guard password == confirmPassword else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return
        }

        // Register the new account
        UserSession.shared.register(username: username, password: password)
        
        // Navigate to app programmatically
        if let windowScene = view.window?.windowScene,
           let window = windowScene.windows.first {
            window.rootViewController = MainTabBarController()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    @objc private func signInTapped() {
        // Return to the login screen
        navigationController?.popViewController(animated: true)
    }

    // Reusable alert helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

