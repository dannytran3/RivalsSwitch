//
//  HeroRegistry.swift
//  RivalsSwitch
//
//  Central registry for Marvel Rivals hero data
//

import Foundation
import UIKit

class HeroRegistry {
    static let shared = HeroRegistry()
    
    private init() {}
    
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
    
    // Get hero image with fallback
    func heroImage(slug: String) -> UIImage {
        let imageName = "hero_\(slug)"
        
        // Try loading from assets
        if let image = UIImage(named: imageName) {
            return image
        }
        
        // Fallback to role-based placeholder
        if let hero = hero(slug: slug) {
            return placeholderImage(for: hero.role)
        }
        
        // Final fallback
        return UIImage(systemName: "person.fill") ?? UIImage()
    }
    
    // Get role color for styling
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
    
    // Random hero for demo/testing
    func randomHero() -> HeroData {
        allHeroes.randomElement() ?? allHeroes[0]
    }
}
