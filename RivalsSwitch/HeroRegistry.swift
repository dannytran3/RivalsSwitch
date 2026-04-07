//
//  HeroRegistry.swift
//  RivalsSwitch
//
//  Central registry for Marvel Rivals hero data
//

import Foundation
import UIKit
import SwiftUI

class HeroRegistry {
    static let shared = HeroRegistry()
    
    private init() {}
    
    // Base URL for remote hero images
    private let baseImageURL = "https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images"
    
    // Complete list of Marvel Rivals heroes
    let allHeroes: [HeroData] = [
        // Vanguards (Tanks)
        HeroData(name: "Captain America", slug: "captain-america", role: .vanguard),
        HeroData(name: "Doctor Strange", slug: "doctor-strange", role: .vanguard),
        HeroData(name: "Groot", slug: "groot", role: .vanguard),
        HeroData(name: "Hulk", slug: "hulk", role: .vanguard),
        HeroData(name: "Magneto", slug: "magneto", role: .vanguard),
        HeroData(name: "Peni Parker", slug: "peni-parker", role: .vanguard),
        HeroData(name: "Thor", slug: "thor", role: .vanguard),
        HeroData(name: "Venom", slug: "venom", role: .vanguard),
        
        // Duelists (DPS)
        HeroData(name: "Black Panther", slug: "black-panther", role: .duelist),
        HeroData(name: "Black Widow", slug: "black-widow", role: .duelist),
        HeroData(name: "Hawkeye", slug: "hawkeye", role: .duelist),
        HeroData(name: "Hela", slug: "hela", role: .duelist),
        HeroData(name: "Iron Fist", slug: "iron-fist", role: .duelist),
        HeroData(name: "Iron Man", slug: "iron-man", role: .duelist),
        HeroData(name: "Magik", slug: "magik", role: .duelist),
        HeroData(name: "Namor", slug: "namor", role: .duelist),
        HeroData(name: "Psylocke", slug: "psylocke", role: .duelist),
        HeroData(name: "Scarlet Witch", slug: "scarlet-witch", role: .duelist),
        HeroData(name: "Spider-Man", slug: "spider-man", role: .duelist),
        HeroData(name: "Squirrel Girl", slug: "squirrel-girl", role: .duelist),
        HeroData(name: "Star-Lord", slug: "star-lord", role: .duelist),
        HeroData(name: "Storm", slug: "storm", role: .duelist),
        HeroData(name: "The Punisher", slug: "punisher", role: .duelist),
        HeroData(name: "Winter Soldier", slug: "winter-soldier", role: .duelist),
        
        // Strategists (Supports)
        HeroData(name: "Adam Warlock", slug: "adam-warlock", role: .strategist),
        HeroData(name: "Cloak & Dagger", slug: "cloak-dagger", role: .strategist),
        HeroData(name: "Jeff the Land Shark", slug: "jeff", role: .strategist),
        HeroData(name: "Loki", slug: "loki", role: .strategist),
        HeroData(name: "Luna Snow", slug: "luna-snow", role: .strategist),
        HeroData(name: "Mantis", slug: "mantis", role: .strategist),
        HeroData(name: "Rocket Raccoon", slug: "rocket-raccoon", role: .strategist)
    ]
    
    // Get hero by slug
    func hero(slug: String) -> HeroData? {
        allHeroes.first { $0.slug.lowercased() == slug.lowercased() }
    }
    
    // Get hero by name
    func hero(name: String) -> HeroData? {
        allHeroes.first { $0.name.lowercased() == name.lowercased() }
    }
    
    // Get heroes by role
    func heroes(role: HeroData.HeroRole) -> [HeroData] {
        allHeroes.filter { $0.role == role }
    }
    
    // MARK: - Remote Image URLs
    
    // Get remote image URL for hero
    // Returns URL in format: https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images/<slug>_prestige.png
    // Examples:
    //   - spider-man -> https://rivalskins.com/.../spider-man_prestige.png
    //   - jeff -> https://rivalskins.com/.../jeff-the-land-shark_prestige.png
    //   - punisher -> https://rivalskins.com/.../the-punisher_prestige.png
    func heroImageURL(slug: String) -> URL? {
        // Map internal slugs to Rivalskins naming convention
        let urlSlug = mapSlugForURL(slug)
        let urlString = "\(baseImageURL)/\(urlSlug)_prestige.png"
        return URL(string: urlString)
    }
    
    // Map internal slugs to match Rivalskins URL naming
    private func mapSlugForURL(_ slug: String) -> String {
        // Special cases where our slug differs from Rivalskins naming
        // Test URLs:
        // - "jeff" -> https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images/jeff-the-land-shark_prestige.png
        // - "punisher" -> https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images/the-punisher_prestige.png
        // - "cloak-dagger" -> https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images/cloak-and-dagger_prestige.png
        // - "spider-man" -> https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images/spider-man_prestige.png
        switch slug.lowercased() {
        case "punisher":
            return "the-punisher"
        case "cloak-dagger":
            return "cloak-and-dagger"
        case "jeff":
            return "jeff-the-land-shark"
        default:
            return slug
        }
    }
    
    // Get placeholder image for missing assets
    func placeholderImage(for role: HeroData.HeroRole) -> UIImage {
        let iconName: String
        switch role {
        case .vanguard:
            iconName = "shield.fill"
        case .duelist:
            iconName = "burst.fill"
        case .strategist:
            iconName = "cross.circle.fill"
        }
        
        return UIImage(systemName: iconName) ?? UIImage()
    }
    
    // Get hero image with fallback (for UIKit compatibility)
    @available(*, deprecated, message: "Use heroImageURL(slug:) with AsyncImage in SwiftUI instead")
    func heroImage(slug: String) -> UIImage {
        // Fallback to role-based placeholder for UIKit views
        if let hero = hero(slug: slug) {
            return placeholderImage(for: hero.role)
        }
        
        // Final fallback
        return UIImage(systemName: "person.fill") ?? UIImage()
    }
    
    // Get role color for styling (UIKit)
    func roleColor(role: HeroData.HeroRole) -> UIColor {
        switch role {
        case .vanguard:
            return UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0) // Blue
        case .duelist:
            return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0) // Red
        case .strategist:
            return UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0) // Green
        }
    }
    
    // Get role color for styling (SwiftUI)
    func roleColorSwiftUI(role: HeroData.HeroRole) -> Color {
        switch role {
        case .vanguard:
            return Color.blue
        case .duelist:
            return Color.red
        case .strategist:
            return Color.green
        }
    }
    
    // Random hero for demo/testing
    func randomHero() -> HeroData {
        allHeroes.randomElement() ?? allHeroes[0]
    }
    
    func ocrHeroAliases() -> [String: String] {
        [
            "angela": "Angela",
            "blade": "Blade",
            "daredevil": "Daredevil",
            "deadpool": "Deadpool",
            "elsa bloodstone": "Elsa Bloodstone",
            "elsa": "Elsa Bloodstone",
            "emma frost": "Emma Frost",
            "gambit": "Gambit",
            "human torch": "Human Torch",
            "invisible woman": "Invisible Woman",
            "mister fantastic": "Mister Fantastic",
            "mr fantastic": "Mister Fantastic",
            "mr. fantastic": "Mister Fantastic",
            "moon knight": "Moon Knight",
            "phoenix": "Phoenix",
            "rogue": "Rogue",
            "the thing": "The Thing",
            "thing": "The Thing",
            "ultron": "Ultron",
            "white fox": "White Fox",
            "wolverine": "Wolverine",

            "spider man": "Spider-Man",
            "spiderman": "Spider-Man",
            "spider-man": "Spider-Man",

            "iron man": "Iron Man",
            "ironman": "Iron Man",

            "iron fist": "Iron Fist",
            "ironfist": "Iron Fist",

            "black widow": "Black Widow",
            "blackwidow": "Black Widow",

            "black panther": "Black Panther",
            "blackpanther": "Black Panther",

            "doctor strange": "Doctor Strange",
            "dr strange": "Doctor Strange",
            "dr. strange": "Doctor Strange",

            "captain america": "Captain America",
            "capt america": "Captain America",

            "star lord": "Star-Lord",
            "starlord": "Star-Lord",
            "star-lord": "Star-Lord",

            "winter soldier": "Winter Soldier",
            "wintersoldier": "Winter Soldier",

            "cloak and dagger": "Cloak & Dagger",
            "cloak dagger": "Cloak & Dagger",
            "cloak & dagger": "Cloak & Dagger",

            "rocket raccoon": "Rocket Raccoon",
            "rocket": "Rocket Raccoon",

            "jeff the land shark": "Jeff the Land Shark",
            "jeff": "Jeff the Land Shark"
        ]
    }
}
