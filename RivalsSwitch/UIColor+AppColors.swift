//
//  UIColor+AppColors.swift
//  RivalsSwitch
//
//  App Color System Extension
//

import UIKit

extension UIColor {
    
    // Primary background color - Main app background (#1A1A2E)
    static var appPrimaryBackground: UIColor {
        return UIColor(named: "PrimaryBackground") ?? UIColor(red: 0.102, green: 0.102, blue: 0.180, alpha: 1.0)
    }
    
    // Secondary background color - Cards, containers (#32324C)
    static var appSecondaryBackground: UIColor {
        return UIColor(named: "SecondaryBackground") ?? UIColor(red: 0.196, green: 0.196, blue: 0.298, alpha: 1.0)
    }
    
    // Tertiary background color - Elevated elements (#3D3D5C)
    static var appTertiaryBackground: UIColor {
        return UIColor(named: "TertiaryBackground") ?? UIColor(red: 0.239, green: 0.239, blue: 0.361, alpha: 1.0)
    }
    
    
    // Primary accent color - Gold/Yellow (#FFD700)
    static var appPrimaryAccent: UIColor {
        return UIColor(named: "PrimaryAccent") ?? UIColor(red: 1.0, green: 0.843, blue: 0.0, alpha: 1.0)
    }
    
    // Secondary accent color - Orange-Yellow (#FFA500)
    static var appSecondaryAccent: UIColor {
        return UIColor(named: "SecondaryAccent") ?? UIColor(red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
    }
    
    
    // Primary text color - White
    static var appPrimaryText: UIColor {
        return UIColor(named: "PrimaryText") ?? UIColor.white
    }
    
    // Secondary text color - Light gray
    static var appSecondaryText: UIColor {
        return UIColor(named: "SecondaryText") ?? UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
    }
    
    // Tertiary text color - Medium gray
    static var appTertiaryText: UIColor {
        return UIColor(named: "TertiaryText") ?? UIColor(red: 0.690, green: 0.690, blue: 0.690, alpha: 1.0)
    }
    
    
    //Border color - Subtle borders
    static var appBorderColor: UIColor {
        return UIColor(named: "BorderColor") ?? UIColor(red: 0.290, green: 0.290, blue: 0.431, alpha: 1.0)
    }
    
    //Divider color - Subtle dividers
    static var appDividerColor: UIColor {
        return UIColor(named: "DividerColor") ?? UIColor(red: 0.165, green: 0.165, blue: 0.243, alpha: 1.0)
    }
    
    
    // Success color - Green
    static var appSuccessColor: UIColor {
        return UIColor(named: "SuccessColor") ?? UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0)
    }
    
    // Error color - Red
    static var appErrorColor: UIColor {
        return UIColor(named: "ErrorColor") ?? UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0)
    }
    
    // Warning color - Orange
    static var appWarningColor: UIColor {
        return UIColor(named: "WarningColor") ?? UIColor(red: 1.0, green: 0.596, blue: 0.0, alpha: 1.0)
    }
    
    // Info color - Blue
    static var appInfoColor: UIColor {
        return UIColor(named: "InfoColor") ?? UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0)
    }
    
    
    // Creates a color from hex string
    //Parameter hex: Hex color string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
