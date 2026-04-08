//
//  LandingViewController.swift
//  RivalsSwitch
//
//  Fully Programmatic Landing Screen
//

import UIKit
import AVFoundation

// First page shown to logged-out users
// They choose between signing up or logging in
class LandingViewController: UIViewController {
    
    // UI Elements
    private let logoImageView = UIImageView()
    private let signUpButton = UIButton(type: .custom)
    private let haveAccountButton = UIButton(type: .custom)
    private var gradientLayer: CAGradientLayer?
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var scrimLayer: CAGradientLayer?
    private var logoAspectConstraint: NSLayoutConstraint?
    private var accentGradientLayer: CAGradientLayer?
    private var glowLayerTopRight: CAGradientLayer?
    private var glowLayerBottomLeft: CAGradientLayer?
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStyling()
        // If this screen somehow loads without a navigation controller, create one so push navigation still works
        if navigationController == nil, let windowScene = view.window?.windowScene, let window = windowScene.windows.first {
            let nav = UINavigationController(rootViewController: self)
            window.rootViewController = nav
        }
    }

    // Keep auth entry screen stable; allow rotation elsewhere.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var shouldAutorotate: Bool { false }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPlayer?.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Keep background layers sized correctly
        gradientLayer?.frame = view.bounds
        accentGradientLayer?.frame = view.bounds
        if let glow1 = glowLayerTopRight {
            let size = max(view.bounds.width, view.bounds.height) * 0.6
            glow1.frame = CGRect(x: view.bounds.maxX - size * 0.8, y: -size * 0.2, width: size, height: size)
        }
        if let glow2 = glowLayerBottomLeft {
            let size = max(view.bounds.width, view.bounds.height) * 0.7
            glow2.frame = CGRect(x: -size * 0.3, y: view.bounds.maxY - size * 0.7, width: size, height: size)
        }
        // Slightly larger frame so video is a bit zoomed out and we see more of it
        let inset = min(view.bounds.width, view.bounds.height) * 0.05
        playerLayer?.frame = view.bounds.insetBy(dx: -inset, dy: -inset)
        scrimLayer?.frame = view.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .appPrimaryBackground
        
        // Gradient Background, behind video so video can be seen
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.appPrimaryBackground.cgColor,
            UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Animated background video and scrim, the looping background video
        let videoURL = Bundle.main.url(forResource: "animated-background", withExtension: "mp4") ?? URL(fileURLWithPath: "/Users/danny/RivalsSwitch/RivalsSwitch/animated-background.mp4")
        let player = AVPlayer(url: videoURL)
        player.isMuted = true
        player.actionAtItemEnd = .none
        videoPlayer = player
        
        let vLayer = AVPlayerLayer(player: player)
        vLayer.videoGravity = .resizeAspectFill
        vLayer.frame = view.bounds
        view.layer.insertSublayer(vLayer, above: gradient)
        playerLayer = vLayer
        
        // Dark overlay on lower half so content is readable, gradient from mid to bottom
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
        
        // Loop the video forever
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player.play()
        
        // Accent overlay (above scrim so layer order stays predictable)
        let accent = CAGradientLayer()
        accent.colors = [
            UIColor.appSecondaryAccent.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor
        ]
        accent.locations = [0.0, 1.0]
        accent.startPoint = CGPoint(x: 0.5, y: 0.0)
        accent.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(accent, above: scrim)
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
        view.layer.insertSublayer(glowTR, above: gradientLayer!)
        view.layer.insertSublayer(glowBL, above: gradientLayer!)
        self.glowLayerTopRight = glowTR
        self.glowLayerBottomLeft = glowBL
        
        // Logo Image,  direct, no container
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        if let logoImage = UIImage(named: "Logo") {
            logoImageView.image = logoImage
        }
        view.addSubview(logoImageView)
        
        // Create aspect ratio constraint based on image
        if let img = logoImageView.image {
            let ratio = img.size.height / img.size.width
            logoAspectConstraint = logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: ratio)
            logoAspectConstraint?.isActive = true
        }
        
        // Subtitle directly under logo
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Know when to switch. Win more matches."
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        
        // Logo in top half, centered; subtitle + buttons stay in lower half
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // Sign Up Button
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        // Have Account Button
        haveAccountButton.translatesAutoresizingMaskIntoConstraints = false
        haveAccountButton.setTitle("I have an account", for: .normal)
        haveAccountButton.addTarget(self, action: #selector(haveAccountTapped), for: .touchUpInside)
        view.addSubview(haveAccountButton)
        
        // Constraints: stack in lower half, anchored above safe area bottom
        NSLayoutConstraint.activate([
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            signUpButton.widthAnchor.constraint(equalToConstant: 280),
            signUpButton.heightAnchor.constraint(equalToConstant: 56),
            haveAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            haveAccountButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            haveAccountButton.widthAnchor.constraint(equalToConstant: 280),
            haveAccountButton.heightAnchor.constraint(equalToConstant: 56),
            haveAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStyling() {
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        signUpButton.applySolidPrimaryCTAStyle()
        signUpButton.setTitle("Sign up", for: .normal)
        
        haveAccountButton.applySecondaryStyle()
        haveAccountButton.setTitle("I have an account", for: .normal)
        
        subtitleLabel.font = .appBodyLarge
        subtitleLabel.textColor = .appPrimaryText
    }
    
    //User presses signup Button
    @objc private func signUpTapped() {
        let createAccountVC = CreateAccountViewController()
        navigationController?.pushViewController(createAccountVC, animated: true)
    }
    
    //User presses have account Button
    @objc private func haveAccountTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}

