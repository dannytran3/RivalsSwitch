//
//  HeroRegistry.swift
//  RivalsSwitch
//
//  Central registry for Marvel Rivals hero data
//

import Foundation
import ObjectiveC
import UIKit
import SwiftUI

/// Associated object key for cancelling in-flight party portrait loads on `UIImageView`.
fileprivate var partyPortraitLoadTaskKey: UInt8 = 0

class HeroRegistry {
    static let shared = HeroRegistry()
    
    private init() {}
    
    /// Wiki-style avatars under `MarvalRivals-icons/` (`Hero_Icon_*`, `Lord_Icon_*`, table icons).
    private static let bundledIconsSubdirectory = "MarvalRivals-icons"
    
    private var stemToSlugLookup: [String: String]?
    
    // Base URL for remote hero images
    private let baseImageURL = "https://rivalskins.com/wp-content/uploads/marvel-assets/assets/hero-prestige-images"
    
    // Complete list of Marvel Rivals heroes
    let allHeroes: [HeroData] = [
        // Vanguards (Tanks)
        HeroData(name: "Captain America", slug: "captain-america", role: .vanguard),
        HeroData(name: "Doctor Strange", slug: "doctor-strange", role: .vanguard),
        HeroData(name: "Emma Frost", slug: "emma-frost", role: .vanguard),
        HeroData(name: "Groot", slug: "groot", role: .vanguard),
        HeroData(name: "Hulk", slug: "hulk", role: .vanguard),
        HeroData(name: "Magneto", slug: "magneto", role: .vanguard),
        HeroData(name: "Peni Parker", slug: "peni-parker", role: .vanguard),
        HeroData(name: "The Thing", slug: "the-thing", role: .vanguard),
        HeroData(name: "Thor", slug: "thor", role: .vanguard),
        HeroData(name: "Venom", slug: "venom", role: .vanguard),
        
        // Duelists (DPS)
        HeroData(name: "Angela", slug: "angela", role: .duelist),
        HeroData(name: "Black Panther", slug: "black-panther", role: .duelist),
        HeroData(name: "Black Widow", slug: "black-widow", role: .duelist),
        HeroData(name: "Blade", slug: "blade", role: .duelist),
        HeroData(name: "Daredevil", slug: "daredevil", role: .duelist),
        HeroData(name: "Deadpool", slug: "deadpool", role: .duelist),
        HeroData(name: "Elsa Bloodstone", slug: "elsa-bloodstone", role: .duelist),
        HeroData(name: "Gambit", slug: "gambit", role: .duelist),
        HeroData(name: "Hawkeye", slug: "hawkeye", role: .duelist),
        HeroData(name: "Hela", slug: "hela", role: .duelist),
        HeroData(name: "Human Torch", slug: "human-torch", role: .duelist),
        HeroData(name: "Iron Fist", slug: "iron-fist", role: .duelist),
        HeroData(name: "Iron Man", slug: "iron-man", role: .duelist),
        HeroData(name: "Magik", slug: "magik", role: .duelist),
        HeroData(name: "Mister Fantastic", slug: "mister-fantastic", role: .duelist),
        HeroData(name: "Moon Knight", slug: "moon-knight", role: .duelist),
        HeroData(name: "Namor", slug: "namor", role: .duelist),
        HeroData(name: "Phoenix", slug: "phoenix", role: .duelist),
        HeroData(name: "Psylocke", slug: "psylocke", role: .duelist),
        HeroData(name: "Rogue", slug: "rogue", role: .duelist),
        HeroData(name: "Scarlet Witch", slug: "scarlet-witch", role: .duelist),
        HeroData(name: "Spider-Man", slug: "spider-man", role: .duelist),
        HeroData(name: "Squirrel Girl", slug: "squirrel-girl", role: .duelist),
        HeroData(name: "Star-Lord", slug: "star-lord", role: .duelist),
        HeroData(name: "Storm", slug: "storm", role: .duelist),
        HeroData(name: "The Punisher", slug: "punisher", role: .duelist),
        HeroData(name: "Winter Soldier", slug: "winter-soldier", role: .duelist),
        HeroData(name: "Wolverine", slug: "wolverine", role: .duelist),
        
        // Strategists (Supports)
        HeroData(name: "Adam Warlock", slug: "adam-warlock", role: .strategist),
        HeroData(name: "Cloak & Dagger", slug: "cloak-dagger", role: .strategist),
        HeroData(name: "Invisible Woman", slug: "invisible-woman", role: .strategist),
        HeroData(name: "Jeff the Land Shark", slug: "jeff", role: .strategist),
        HeroData(name: "Loki", slug: "loki", role: .strategist),
        HeroData(name: "Luna Snow", slug: "luna-snow", role: .strategist),
        HeroData(name: "Mantis", slug: "mantis", role: .strategist),
        HeroData(name: "Rocket Raccoon", slug: "rocket-raccoon", role: .strategist),
        HeroData(name: "Ultron", slug: "ultron", role: .strategist),
        HeroData(name: "White Fox", slug: "white-fox", role: .strategist)
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
        case "the-thing":
            return "the-thing"
        case "white-fox":
            return "white-fox"
        case "elsa-bloodstone":
            return "elsa-bloodstone"
        default:
            return slug
        }
    }
    
    /// Lowercased bundle resource stem → hero slug (wiki filenames + legacy `deluxe-*` / slug-style names).
    func slugForBundledIconStem(_ stem: String) -> String? {
        let k = stem.lowercased()
        if stemToSlugLookup == nil {
            var m: [String: String] = [:]
            for hero in allHeroes {
                let p = Self.bundledIconResourceStems(forSlug: hero.slug)
                for s in p.lord + p.hero {
                    m[s.lowercased()] = hero.slug
                }
            }
            stemToSlugLookup = m
        }
        if let hit = stemToSlugLookup?[k] { return hit }
        return Self.legacySlugFromFlatAssetStem(k)
    }
    
    private static func legacySlugFromFlatAssetStem(_ k: String) -> String? {
        var s = k
        if s.hasPrefix("deluxe-") {
            s.removeFirst("deluxe-".count)
        }
        if s.hasPrefix("jeff-the-land-shark") { return "jeff" }
        if s == "the-punisher" || s == "punisher" { return "punisher" }
        if s.hasPrefix("cloak-dagger") || s == "cloak-and-dagger" { return "cloak-dagger" }
        if let r = s.range(of: #"-\d+$"#, options: .regularExpression) {
            s = String(s[..<r.lowerBound])
        }
        return HeroRegistry.shared.hero(slug: s) != nil ? s : nil
    }
    
    /// Lord (deluxe) and default avatar stems **without** file extension — filenames match the Marvel Rivals wiki.
    /// For heroes with multiple bundled portraits (Hulk forms, Magik/Darkchylde, Cloak & Dagger splits), the **first** `hero` stem is the default/base; later entries are alternate in-game states for portrait matching only.
    static func bundledIconResourceStems(forSlug slug: String) -> (lord: [String], hero: [String]) {
        let s = slug.lowercased()
        switch s {
        case "jeff":
            return (["Lord_Icon_Jeff_the_Land_Shark"], ["Hero_Icon_Jeff_the_Land_Shark"])
        case "punisher":
            return (["Lord_Icon_The_Punisher"], ["Hero_Icon_The_Punisher"])
        case "cloak-dagger":
            let lords = ["Lord_Icon_Cloak_%26_Dagger", "Lord_Icon_Cloak", "Lord_Icon_Dagger"]
            let heroes = ["Hero_Icon_Cloak_%26_Dagger", "Hero_Icon_Cloak", "Hero_Icon_Dagger"]
            return (lords, heroes)
        case "hulk":
            let v = ["Bruce_Banner", "Hero_Hulk", "Monster_Hulk"]
            return (v.map { "Lord_Icon_\($0)" }, v.map { "Hero_Icon_\($0)" })
        case "magik":
            return (["Lord_Icon_Magik", "Lord_Icon_Magik_Darkchild"], ["Hero_Icon_Magik", "Hero_Icon_Magik_Darkchild"])
        case "deadpool":
            return (["Lord_Icon_Deadpool"], ["Deadpool_DEFAULT_Table_Icon"])
        case "white-fox":
            return (["Lord_Icon_White_Fox"], ["White_Fox_DEFAULT_Table_Icon"])
        case "mantis":
            let m = ["Lord_Icon_Mantis"]
            return (m, m)
        case "loki":
            return (
                ["Lord_Icon_Loki", "Lord_Icon_Lady_Loki"],
                ["Hero_Icon_Loki", "Loki_Lady_Loki_Table_Icon"]
            )
        default:
            let wiki = wikiIconMiddle(fromSlug: s)
            return (["Lord_Icon_\(wiki)"], ["Hero_Icon_\(wiki)"])
        }
    }
    
    private static func wikiIconMiddle(fromSlug s: String) -> String {
        switch s {
        case "spider-man": return "Spider-Man"
        case "star-lord": return "Star-Lord"
        default:
            return s.split(separator: "-").map { w in w.prefix(1).uppercased() + w.dropFirst().lowercased() }.joined(separator: "_")
        }
    }
    
    private func loadBundledPortrait(slug: String, preferLord: Bool) -> UIImage? {
        let pair = Self.bundledIconResourceStems(forSlug: slug)
        let order = preferLord ? (pair.lord + pair.hero) : (pair.hero + pair.lord)
        let names = Set(order.map { $0.lowercased() })
        for name in order {
            for ext in ["webp", "png"] {
                if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: Self.bundledIconsSubdirectory),
                   let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    return img
                }
            }
        }
        for ext in ["webp", "png"] {
            guard let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) else { continue }
            for url in urls {
                let stem = url.deletingPathExtension().lastPathComponent
                guard names.contains(stem.lowercased()),
                      let data = try? Data(contentsOf: url),
                      let img = UIImage(data: data) else { continue }
                return img
            }
        }
        return nil
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
    
    /// Local bundle portrait for confirm UI / offline use (`MarvalRivals-icons` wiki filenames or flat .app).
    func bundledPortraitImage(forSlug slug: String) -> UIImage? {
        loadBundledPortrait(slug: slug.lowercased(), preferLord: false)
    }
    
    /// Prefer Lord (deluxe) avatars before default `Hero_Icon_*` / table icons.
    func bundledPortraitImagePreferringDeluxe(forSlug slug: String) -> UIImage? {
        loadBundledPortrait(slug: slug.lowercased(), preferLord: true)
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
            "emma": "Emma Frost",
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
            "lady loki": "Loki",
            "loki lady": "Loki",

            "bruce banner": "Hulk",
            "hero hulk": "Hulk",
            "monster hulk": "Hulk",
            "magik darkchild": "Magik",
            "darkchild": "Magik",
            "darkchylde": "Magik",

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
    
    /// Portrait tile for confirm screens (bundled art, placeholder, or unknown glyph).
    func configurePortraitImageView(_ imageView: UIImageView, heroDisplayName: String) {
        let t = heroDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            let sym = UIImage(systemName: "questionmark.square.dashed") ?? UIImage(systemName: "questionmark.square")
            imageView.image = sym
            imageView.tintColor = .appTertiaryText
            imageView.contentMode = .center
            return
        }
        guard let hero = hero(name: t) else {
            imageView.image = UIImage(systemName: "person.fill.questionmark")
            imageView.tintColor = .appSecondaryText
            imageView.contentMode = .center
            return
        }
        if let local = bundledPortraitImage(forSlug: hero.slug) {
            imageView.image = local
            imageView.tintColor = nil
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = placeholderImage(for: hero.role)
            imageView.tintColor = roleColor(role: hero.role)
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    /// Party / hero-selector style: same prestige art as SwiftUI `HeroImageView` (Party cards), optionally after trying bundled Lord/Hero wiki icons.
    /// - Parameter preferBundledDeluxePortrait: When `true` (default), use local `MarvalRivals-icons` (`Lord_Icon_*` first) before CDN. When `false`, skip bundle and load prestige CDN only — matches Party screen resolution/look.
    /// - Parameter loadedImageContentMode: Applied to loaded bitmaps (local + network). Use `.scaleAspectFit` to show full square art without cropping.
    /// - Parameter brandPlaceholder: When set, used while prestige loads (or when offline / no URL) instead of role SF symbols.
    func configurePartyStylePortraitImageView(
        _ imageView: UIImageView,
        heroDisplayName: String,
        loadedImageContentMode: UIView.ContentMode = .scaleAspectFill,
        brandPlaceholder: UIImage? = nil,
        preferBundledDeluxePortrait: Bool = true
    ) {
        if let existing = objc_getAssociatedObject(imageView, &partyPortraitLoadTaskKey) as? URLSessionDataTask {
            existing.cancel()
            objc_setAssociatedObject(imageView, &partyPortraitLoadTaskKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        let t = heroDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            if let brand = brandPlaceholder {
                imageView.image = brand
                imageView.tintColor = nil
                imageView.contentMode = .scaleAspectFit
            } else {
                configurePortraitImageView(imageView, heroDisplayName: t)
            }
            return
        }
        guard let hero = hero(name: t) else {
            if let brand = brandPlaceholder {
                imageView.image = brand
                imageView.tintColor = nil
                imageView.contentMode = .scaleAspectFit
            } else {
                configurePortraitImageView(imageView, heroDisplayName: t)
            }
            return
        }
        
        if preferBundledDeluxePortrait,
           let local = bundledPortraitImagePreferringDeluxe(forSlug: hero.slug) {
            imageView.image = local
            imageView.tintColor = nil
            imageView.contentMode = loadedImageContentMode
            return
        }
        
        if let brand = brandPlaceholder {
            imageView.image = brand
            imageView.tintColor = nil
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.image = placeholderImage(for: hero.role)
            imageView.tintColor = roleColor(role: hero.role)
            imageView.contentMode = .scaleAspectFit
        }
        
        guard let url = heroImageURL(slug: hero.slug) else { return }
        
        let mode = loadedImageContentMode
        let task = URLSession.shared.dataTask(with: url) { [weak imageView] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard let iv = imageView, iv.window != nil else { return }
                iv.image = img
                iv.tintColor = nil
                iv.contentMode = mode
            }
        }
        objc_setAssociatedObject(imageView, &partyPortraitLoadTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        task.resume()
    }
}

// MARK: - Match summary hero thumbnail (home recent card + history list)

enum MatchSummaryThumbnail {
    /// Prefer “Top swap: Hero”, else first-line played hero before ` | `.
    static func heroDisplayName(in summary: String) -> String? {
        if let n = topSwapHero(from: summary) { return n }
        return firstLineHero(from: summary)
    }
    
    static func thumbnailImage(for summary: String) -> UIImage? {
        guard let name = heroDisplayName(in: summary) else { return nil }
        guard let hero = HeroRegistry.shared.hero(name: name) else {
            return UIImage(systemName: "person.fill.questionmark")
        }
        if let img = HeroRegistry.shared.bundledPortraitImagePreferringDeluxe(forSlug: hero.slug) { return img }
        if let img = HeroRegistry.shared.bundledPortraitImage(forSlug: hero.slug) { return img }
        return HeroRegistry.shared.placeholderImage(for: hero.role)
    }
    
    static func configureImageView(_ imageView: UIImageView, summary: String) {
        guard let name = heroDisplayName(in: summary) else {
            imageView.image = nil
            imageView.isHidden = true
            return
        }
        HeroRegistry.shared.configurePortraitImageView(imageView, heroDisplayName: name)
        imageView.isHidden = false
    }
    
    private static func topSwapHero(from summary: String) -> String? {
        for line in summary.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard let colonIdx = trimmed.firstIndex(of: ":") else { continue }
            let head = String(trimmed[..<colonIdx]).trimmingCharacters(in: .whitespaces).lowercased()
            guard head == "top swap" else { continue }
            var rest = String(trimmed[trimmed.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
            if rest == "—" || rest == "-" { return nil }
            if rest.hasPrefix("👑") {
                rest = String(rest.dropFirst()).trimmingCharacters(in: .whitespaces)
            }
            return rest.isEmpty ? nil : rest
        }
        return nil
    }
    
    private static func firstLineHero(from summary: String) -> String? {
        guard let first = summary.components(separatedBy: .newlines).first,
              let r = first.range(of: " | ") else { return nil }
        return String(first[..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
    }
}
