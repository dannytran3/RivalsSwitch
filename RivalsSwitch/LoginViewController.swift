//
//  LoginViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic - Beautiful Login Screen
//

import UIKit
import AVFoundation

// sign-in code for returning users
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Main UI elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let usernameLabel = UILabel()
    private let passwordLabel = UILabel()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .custom)
    private let signUpLinkButton = UIButton(type: .system)
    private var gradientLayer: CAGradientLayer?
    
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var scrimLayer: CAGradientLayer?
    
    private var accentGradientLayer: CAGradientLayer?
    private var glowLayerTopRight: CAGradientLayer?
    private var glowLayerBottomLeft: CAGradientLayer?
    
    private var logoAspectConstraint: NSLayoutConstraint?
    
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
        
        // Keep all background layers sized correctly
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
        
        // Background Video and Scrim, add looping background video
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
        
        // Dark overlay on lower half (match Landing) so content is readable
        let scrim = CAGradientLayer()
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
        
        // Loop background video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player.play()
        
        // Accent overlay gradient
        let accent = CAGradientLayer()
        accent.colors = [UIColor.appSecondaryAccent.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        accent.locations = [0.0, 1.0]
        accent.startPoint = CGPoint(x: 0.5, y: 0.0)
        accent.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(accent, at: 1)
        accentGradientLayer = accent
        
        // Decorative radial glows
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
        titleLabel.text = "Sign in to RivalsSwitch"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Field Labels
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "Username"
        contentView.addSubview(usernameLabel)
        
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.text = "Password"
        contentView.addSubview(passwordLabel)
        
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
        passwordTextField.textContentType = .oneTimeCode
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)
        
        // Login Button
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Sign in", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        contentView.addSubview(loginButton)
        
        // Sign Up Link
        signUpLinkButton.translatesAutoresizingMaskIntoConstraints = false
        signUpLinkButton.setTitle("Create account", for: .normal)
        signUpLinkButton.contentHorizontalAlignment = .right
        signUpLinkButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        contentView.addSubview(signUpLinkButton)
        
        let side: CGFloat = 28
        NSLayoutConstraint.activate([
            signUpLinkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            signUpLinkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            signUpLinkButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.55),
            logoImageView.topAnchor.constraint(equalTo: signUpLinkButton.bottomAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            usernameTextField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            usernameTextField.heightAnchor.constraint(equalToConstant: 52),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            passwordLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 14),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordTextField.heightAnchor.constraint(equalToConstant: 52),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: side),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -side),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
        
        // Focus + return behavior is handled via UITextFieldDelegate
    }
    
    private func setupStyling() {
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Title Label - white and bold for visibility over video
        titleLabel.font = .appHeading2
        titleLabel.textColor = .white
        
        // Text fields with glassmorphism
        usernameTextField.applyGlassmorphismStyle()
        passwordTextField.applyGlassmorphismStyle()
        passwordTextField.enablePasswordToggle()
        
        // Lighter placeholders for visibility over video
        [usernameTextField, passwordTextField].forEach { field in
            guard let placeholderText = field.placeholder else { return }
            field.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.85)])
        }
        
        loginButton.applySolidPrimaryCTAStyle()
        
        // Sign Up Link - white for visibility over video
        signUpLinkButton.setTitleColor(.white, for: .normal)
        signUpLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        // Field Labels - white and semibold for visibility over video
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        usernameLabel.textColor = .white
        passwordLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        passwordLabel.textColor = .white
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
    
    @objc private func loginTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        UserSession.shared.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Navigate to app programmatically
                    if let windowScene = self?.view.window?.windowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = MainTabBarController()
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func signUpTapped() {
        let createAccountVC = CreateAccountViewController()
        navigationController?.pushViewController(createAccountVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
