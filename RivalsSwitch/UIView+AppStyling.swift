//
//  UIView+AppStyling.swift
//  RivalsSwitch
//
//  App Styling Helper Extensions
//

import UIKit
import ObjectiveC

extension UIButton {
    /// Clears configuration, blur backgrounds, and gradient/outline layers so layer-based CTA styles compose cleanly.
    fileprivate func resetForLayerCTAStyling() {
        if #available(iOS 15.0, *) {
            configuration = nil
        }
        subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        layer.sublayers?.filter { $0 is CAGradientLayer || $0.name == "gradientOutlineLayer" }.forEach { $0.removeFromSuperlayer() }
        objc_setAssociatedObject(self, "gradientLayer", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, "gradientOutlineLayer", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // Applies primary button styling (gold background, white text)
    func applyPrimaryStyle() {
        resetForLayerCTAStyling()
        backgroundColor = .appPrimaryAccent
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonText
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 0
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    /// Secondary CTA: same footprint as the gradient primary (filled muted surface, subtle border) — pairs with `applyGradientStyle()`.
    func applySecondaryStyle() {
        resetForLayerCTAStyling()
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonTextMedium
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.appBorderColor.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    /// Destructive secondary CTA (e.g. logout): same shape as `applySecondaryStyle()`, error tint.
    func applyDestructiveSecondaryStyle() {
        resetForLayerCTAStyling()
        backgroundColor = UIColor.appErrorColor.withAlphaComponent(0.12)
        setTitleColor(.appErrorColor, for: .normal)
        titleLabel?.font = .appButtonTextMedium
        tintColor = .appErrorColor
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.appErrorColor.withAlphaComponent(0.35).cgColor
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    // Applies tertiary button styling (text only)
    func applyTertiaryStyle() {
        backgroundColor = .clear
        setTitleColor(.appSecondaryText, for: .normal)
        titleLabel?.font = .appBodyMedium
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // Applies an outlined button with a horizontal gradient stroke
    func applyGradientOutlineStyle() {
        resetForLayerCTAStyling()

        backgroundColor = .clear
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonTextMedium
        layer.cornerRadius = 16
        layer.masksToBounds = false
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)

        // Gradient border layer
        let gradient = CAGradientLayer()
        gradient.name = "gradientOutlineLayer"
        gradient.colors = [UIColor.appPrimaryAccent.cgColor, UIColor.appSecondaryAccent.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds

        // Shape mask for stroke
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradient.mask = shape

        layer.addSublayer(gradient)

        // Store for later resizing
        objc_setAssociatedObject(self, "gradientOutlineLayer", gradient, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // Applies gradient button style (orange to yellow gradient)
    func applyGradientStyle() {
        resetForLayerCTAStyling()
        backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.appPrimaryAccent.cgColor,
            UIColor.appSecondaryAccent.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        
        objc_setAssociatedObject(self, "gradientLayer", gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonText
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.22).cgColor
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    /// Solid app gold fill + rounded rect + border — use with `UIButton(type: .custom)` so the control reads as a real button (not plain link text).
    func applySolidPrimaryCTAStyle() {
        resetForLayerCTAStyling()
        backgroundColor = .appPrimaryAccent
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonText
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.withAlphaComponent(0.22).cgColor
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
    
    // Updates gradient frame - call this in viewDidLayoutSubviews
    func updateGradientFrame() {
        if let gradientLayer = objc_getAssociatedObject(self, "gradientLayer") as? CAGradientLayer {
            gradientLayer.frame = bounds
            gradientLayer.cornerRadius = layer.cornerRadius
        }
        if let outline = objc_getAssociatedObject(self, "gradientOutlineLayer") as? CAGradientLayer {
            outline.frame = bounds
            if let mask = outline.mask as? CAShapeLayer {
                mask.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: layer.cornerRadius).cgPath
            }
        }
    }
    
    // Applies glassmorphism style (frosted glass effect)
    func applyGlassmorphismStyle() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false // Don't block touches
        insertSubview(blurView, at: 0)
        
        setTitleColor(.appPrimaryText, for: .normal)
        titleLabel?.font = .appButtonTextMedium
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        
        // Ensure title label is on top
        if let titleLabel = titleLabel {
            bringSubviewToFront(titleLabel)
        }
    }
    
    // Applies yellow/gold glass style – glass container with vibrant gold border to match app accent
    func applyYellowGlassStyle() {
        subviews.filter { $0 is UIVisualEffectView || $0.tag == 9001 }.forEach { $0.removeFromSuperview() }
        
        backgroundColor = UIColor.appPrimaryAccent.withAlphaComponent(0.08)
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.appPrimaryAccent.cgColor
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        insertSubview(blurView, at: 0)
        
        let tintView = UIView()
        tintView.tag = 9001
        tintView.backgroundColor = UIColor.appPrimaryAccent.withAlphaComponent(0.12)
        tintView.frame = bounds
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintView.layer.cornerRadius = 16
        tintView.isUserInteractionEnabled = false
        insertSubview(tintView, at: 1)
        
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .appButtonText
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        if let titleLabel = titleLabel {
            bringSubviewToFront(titleLabel)
        }
    }
}

extension UITextField {
    // Applies app text field styling
    func applyAppStyle() {
        backgroundColor = .appSecondaryBackground
        textColor = .appPrimaryText // White text
        font = .appInputText
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.appBorderColor.cgColor
        
        // Padding
        leftViewMode = .always
        if leftView == nil {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        }
        rightViewMode = .always
        if rightView == nil {
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        }
        
        // Placeholder styling - update if placeholder exists
        if let placeholderText = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.appTertiaryText]
            )
        }
    }
    
    // Applies glassmorphism style to text field
    func applyGlassmorphismStyle() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textColor = .appPrimaryText
        font = .appInputText
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Blur effect background
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        blurView.tag = 9101
        insertSubview(blurView, at: 0)
        
        // Padding
        leftViewMode = .always
        if leftView == nil {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        }
        rightViewMode = .always
        if rightView == nil {
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        }
        
        // Placeholder styling
        if let placeholderText = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.appTertiaryText]
            )
        }
    }
    
    /// Picker-driven fields only: full hero names scale down instead of clipping; no flashing caret.
    func applyGlassmorphismPickerFieldStyle() {
        applyGlassmorphismStyle()
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 10
        textAlignment = .natural
        tintColor = .clear
        autocorrectionType = .no
        spellCheckingType = .no
        smartDashesType = .no
        smartQuotesType = .no
        smartInsertDeleteType = .no
    }
    
    /// Call from the view controller’s `viewDidLayoutSubviews` so corners stay a true pill when height is known.
    func refreshGlassmorphismPillCorners() {
        let h = bounds.height
        guard h > 1 else { return }
        let r = h / 2
        layer.cornerRadius = r
        layer.masksToBounds = true
        if let blur = subviews.first(where: { $0.tag == 9101 }) as? UIVisualEffectView {
            blur.layer.cornerRadius = r
            blur.clipsToBounds = true
        }
    }
    
    // Updates border color when focused
    func updateFocusState(_ isFocused: Bool) {
        if isFocused {
            layer.borderColor = UIColor.appPrimaryAccent.cgColor
            layer.borderWidth = 2
        } else {
            layer.borderColor = UIColor.appBorderColor.cgColor
            layer.borderWidth = 1
        }
    }
    
    // Enables a trailing eye icon to toggle secure text entry
    func enablePasswordToggle() {
        isSecureTextEntry = true
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .appTertiaryText
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        rightView = button
        rightViewMode = .always
        objc_setAssociatedObject(self, "passwordToggleButton", button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc private func togglePasswordVisibility() {
        let wasFirstResponder = isFirstResponder
        isSecureTextEntry.toggle()
        // Fix cursor jump issue by re-assigning text when toggling
        if wasFirstResponder {
            let currentText = text
            text = nil
            insertText(currentText ?? "")
        }
        updatePasswordToggleImage()
    }

    private func updatePasswordToggleImage() {
        if let button = objc_getAssociatedObject(self, "passwordToggleButton") as? UIButton {
            let name = isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: name), for: .normal)
        }
    }
}

extension UILabel {
    // Applies heading 1 style
    func applyHeading1Style() {
        font = .appHeading1
        textColor = .appPrimaryText // White
    }
    
    // Applies heading 2 style
    func applyHeading2Style() {
        font = .appHeading2
        textColor = .appPrimaryText // White
    }
    
    // Applies heading 3 style
    func applyHeading3Style() {
        font = .appHeading3
        textColor = .appPrimaryText // White
    }
    
    // Applies body large style
    func applyBodyLargeStyle() {
        font = .appBodyLarge
        textColor = .appSecondaryText // Light gray
    }
    
    // Applies body medium style
    func applyBodyMediumStyle() {
        font = .appBodyMedium
        textColor = .appSecondaryText // Light gray
    }
    
    // Applies body small style
    func applyBodySmallStyle() {
        font = .appBodySmall
        textColor = .appTertiaryText // Medium gray
    }
}

extension UIView {
    // Applies card styling
    func applyCardStyle(elevated: Bool = false) {
        backgroundColor = elevated ? .appTertiaryBackground : .appSecondaryBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = elevated ? 8 : 4
        layer.shadowOpacity = elevated ? 0.15 : 0.1
    }
}

extension UINavigationBar {
    // Applies app navigation bar styling
    func applyAppStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appPrimaryBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.appPrimaryText,
            .font: UIFont.appHeading3
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.appPrimaryText,
            .font: UIFont.appHeading1
        ]
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        compactAppearance = appearance
        tintColor = .appPrimaryAccent
    }
}

extension UITabBar {
    // Applies app tab bar styling
    func applyAppStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appPrimaryBackground
        
        // Selected tab
        appearance.stackedLayoutAppearance.selected.iconColor = .appPrimaryAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.appPrimaryAccent,
            .font: UIFont.appTabBarText
        ]
        
        // Unselected tab
        appearance.stackedLayoutAppearance.normal.iconColor = .appTertiaryText
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.appTertiaryText,
            .font: UIFont.appTabBarText
        ]
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        tintColor = .appPrimaryAccent
    }
}

extension UIViewController {
    // Styles all buttons in the view hierarchy
    func styleAllButtons() {
        styleButtons(in: view)
    }
    
    private func styleButtons(in view: UIView) {
        for subview in view.subviews {
            if let button = subview as? UIButton {
                // Check button title to determine style
                let title = button.title(for: .normal) ?? ""
                let lowerTitle = title.lowercased()
                
                if lowerTitle.contains("login") || lowerTitle.contains("create account") || 
                   lowerTitle.contains("save") || lowerTitle.contains("done") ||
                   lowerTitle.contains("start") || lowerTitle.contains("use photo") {
                    button.applyPrimaryStyle()
                } else if lowerTitle.contains("back") || lowerTitle.contains("cancel") || 
                          lowerTitle.contains("retake") || lowerTitle.contains("edit") {
                    button.applySecondaryStyle()
                } else {
                    button.applyPrimaryStyle() // Default to primary
                }
            }
            // Recursively check nested subviews
            styleButtons(in: subview)
        }
    }
    
    // Styles all labels in the view hierarchy with default app styles
    func styleAllLabels() {
        styleLabels(in: view)
    }
    
    private func styleLabels(in view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                // Style labels that haven't been explicitly styled
                // Check if it's using system default colors (black/label color)
                let isDefaultColor = label.textColor == .label || 
                                     label.textColor == .black || 
                                     label.textColor == UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
                
                // Check if it's using default system font
                let isDefaultFont = label.font == .systemFont(ofSize: 17) || 
                                   label.font == .systemFont(ofSize: UIFont.labelFontSize)
                
                if isDefaultColor || isDefaultFont {
                    // Determine style based on font size or text content
                    let currentSize = label.font.pointSize
                    if currentSize >= 28 {
                        label.applyHeading2Style()
                    } else if currentSize >= 22 {
                        label.applyHeading3Style()
                    } else if currentSize >= 17 {
                        label.applyBodyLargeStyle()
                    } else {
                        label.applyBodyMediumStyle()
                    }
                }
            }
            // Recursively check nested subviews
            styleLabels(in: subview)
        }
    }
    
    /// Extra bottom inset so scrollable content clears the tab bar when layout still overlaps it.
    func updateScrollViewTabBarAvoidance(_ scrollView: UIScrollView) {
        let extra: CGFloat
        if let tab = tabBarController?.tabBar, !tab.isHidden {
            extra = tab.frame.height + 24
        } else {
            extra = 24
        }
        scrollView.verticalScrollIndicatorInsets.bottom = extra
        scrollView.contentInset.bottom = extra
    }
    
    func updateTableViewTabBarAvoidance(_ tableView: UITableView) {
        let extra: CGFloat
        if let tab = tabBarController?.tabBar, !tab.isHidden {
            extra = tab.frame.height + 24
        } else {
            extra = 24
        }
        tableView.verticalScrollIndicatorInsets.bottom = extra
        tableView.contentInset.bottom = extra
    }
}

