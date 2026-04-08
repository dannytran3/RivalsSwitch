//
//  AppPreferenceStore.swift
//  RivalsSwitch
//
//  UserDefaults-backed messaging tone + recommendation aggressiveness.
//

import Foundation

enum AppMessagingTone: Int, CaseIterable {
    case blunt = 0
    case neutral = 1
    case encouraging = 2
    
    static var stored: AppMessagingTone {
        let raw = UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.messagingTone)
        return AppMessagingTone(rawValue: raw) ?? .neutral
    }
}

enum AppRecommendationStyle: Int, CaseIterable {
    /// Fewer picks; only strong / urgent swaps.
    case critical = 0
    /// Current scoring + role mix.
    case balanced = 1
    /// Always surface three top scores (skip role-spread filter).
    case maxPicks = 2
    
    static var stored: AppRecommendationStyle {
        let raw = UserDefaults.standard.integer(forKey: AppPreferenceStore.Keys.recommendationStyle)
        return AppRecommendationStyle(rawValue: raw) ?? .balanced
    }
}

enum AppPreferenceStore {
    enum Keys {
        static let messagingTone = "messagingTone"
        static let recommendationStyle = "recommendationStyle"
    }
    
    /// Voices recommendation copy per messaging tone. **Slot 0** is the primary pick; **1** and **2** use different templates so alternates are not the same blunt/encouraging wrapper repeated three times.
    static func applyMessagingTone(
        to reason: String,
        slotIndex: Int,
        recommendedHero: String,
        primaryHero: String,
        secondHero: String?,
        kills: Int,
        deaths: Int,
        assists: Int,
        struggling: Bool,
        doingWell: Bool
    ) -> String {
        let tone = AppMessagingTone.stored
        let kda = "\(kills)/\(deaths)/\(assists)"
        let second = secondHero ?? "your second pick"
        
        switch tone {
        case .neutral:
            return reason
            
        case .blunt:
            if doingWell {
                return reason
            }
            // Alternates: no repeated "Zazza" line — roast/plan-B angle tied to earlier picks.
            if slotIndex == 1 {
                if primaryHero == "Stay Current Hero" {
                    return "You're glued to your hero while posting \(kda) — \(recommendedHero) is the least-delusional swap if you actually want off this ride. \(reason)"
                }
                return "\(primaryHero) is the real pick; if that's fiction (pic/ban/skill gap), \(recommendedHero) is the easier execution check. Stop cosplaying \(primaryHero). \(reason)"
            }
            if slotIndex == 2 {
                if primaryHero == "Stay Current Hero" {
                    return "Still shopping? \(recommendedHero) is another flex — not as clean as the first backup, still beats running it down. \(reason)"
                }
                return "You already saw \(primaryHero) and \(second). If both are fairy tales, \(recommendedHero) is the third chair — different kit, same 'stop feeding' energy. \(reason)"
            }
            // Slot 0 — primary recommendation: full Zazza + stats + reason.
            let zazza = "Don't Zazza out there — "
            if deaths >= 8 || (deaths - kills) >= 6 {
                return "\(zazza)That \(kda) is getting farmed; you're inting the lobby. \(reason)"
            }
            if struggling {
                return "\(zazza)You're hard-losing on \(kda) — switch before you gap harder. \(reason)"
            }
            if deaths > kills + 2 {
                return "\(zazza)Respectfully, \(kda) is ugly — you're not winning that fight. \(reason)"
            }
            if deaths >= kills && deaths >= 3 {
                return "\(zazza)Mid KDA (\(kda)) — still not it. \(reason)"
            }
            return "\(zazza)\(reason)"
            
        case .encouraging:
            if slotIndex == 1 {
                if doingWell {
                    return "Want variety? \(recommendedHero) is a fun alternate if you feel like mixing it up. \(reason)"
                }
                if primaryHero == "Stay Current Hero" {
                    return "Whenever you're ready to try a swap, \(recommendedHero) is a strong next look — no pressure. \(reason)"
                }
                return "If \(primaryHero) isn't available or doesn't fit your hands, \(recommendedHero) keeps the same game plan with a gentler curve. \(reason)"
            }
            if slotIndex == 2 {
                if doingWell {
                    return "One more option: \(recommendedHero) if you'd like a different flavor this match. \(reason)"
                }
                return "If \(primaryHero) and \(second) aren't the vibe, \(recommendedHero) still lines up with what this lobby needs — worth a shot. \(reason)"
            }
            // Slot 0
            if doingWell {
                return "You're in a good spot: \(reason)"
            }
            if struggling {
                return "No shame in trying something new — \(reason)"
            }
            return "Food for thought: \(reason)"
        }
    }
}
