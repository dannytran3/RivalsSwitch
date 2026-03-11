//
//  UIFont+AppFonts.swift
//  RivalsSwitch
//
//  App Typography System Extension
//

import UIKit

extension UIFont {
    // MARK: - Headings
    
    // Heading 1 - Screen titles (34pt, Bold)
    static var appHeading1: UIFont {
        return UIFont.systemFont(ofSize: 34, weight: .bold)
    }
    
    /// Heading 2 - Section headers (28pt, Bold)
    static var appHeading2: UIFont {
        return UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    /// Heading 3 - Card titles (22pt, Semibold)
    static var appHeading3: UIFont {
        return UIFont.systemFont(ofSize: 22, weight: .semibold)
    }
    
    /// Heading 4 - Subsection headers (20pt, Semibold)
    static var appHeading4: UIFont {
        return UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    // MARK: - Body Text
    
    /// Body Large - Primary body text (17pt, Regular)
    static var appBodyLarge: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    /// Body Medium - Secondary body text (15pt, Regular)
    static var appBodyMedium: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    /// Body Small - Captions, hints (13pt, Regular)
    static var appBodySmall: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    // MARK: - UI Elements
    
    /// Button Text - Button labels (17pt, Semibold)
    static var appButtonText: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    /// Button Text Medium - Secondary button labels (17pt, Medium)
    static var appButtonTextMedium: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }
    
    /// Tab Bar Text - Tab bar labels (10pt, Medium)
    static var appTabBarText: UIFont {
        return UIFont.systemFont(ofSize: 10, weight: .medium)
    }
    
    /// Input Text - Text field input (16pt, Regular)
    static var appInputText: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    // MARK: - Convenience Methods
    
    /// Creates a font with a specific size and weight
    /// - Parameters:
    ///   - size: Font size in points
    ///   - weight: Font weight
    /// - Returns: Configured UIFont
    static func appFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
