import Foundation

class RecommendationEngine {
    
    private struct ScoredPick {
        let hero: String
        let role: String
        let score: Int
        let reasons: [String]
        let counterHits: Int
    }
    
    // Heroes that are strong into certain enemy heroes
    // Heroes that are strong into certain enemy heroes
    static let counterMap: [String: [String]] = [
        // Vanguards
        "Captain America": ["Hela", "Scarlet Witch"],
        "Doctor Strange": ["Magneto", "Scarlet Witch"],
        "Groot": ["Psylocke", "Spider-Man"],
        "Hulk": ["Adam Warlock", "Rocket Raccoon"],
        "Magneto": ["Iron Man", "Storm"],
        "Peni Parker": ["Winter Soldier", "Black Widow"],
        "Thor": ["Captain America", "Venom"],
        "Venom": ["Hawkeye", "Winter Soldier"],

        // Duelists
        "Black Panther": ["Hela", "Adam Warlock"],
        "Black Widow": ["Storm", "Star-Lord"],
        "Hawkeye": ["Namor", "Luna Snow"],
        "Hela": ["Groot", "Venom"],
        "Iron Fist": ["Jeff the Land Shark", "Loki"],
        "Iron Man": ["Hulk", "Squirrel Girl"],
        "Magik": ["Mantis", "Rocket Raccoon"],
        "Namor": ["Peni Parker", "Cloak & Dagger"],
        "Psylocke": ["Loki", "Doctor Strange"],
        "Scarlet Witch": ["Captain America", "Iron Fist"],
        "Spider-Man": ["The Punisher", "Rocket Raccoon"],
        "Squirrel Girl": ["Jeff the Land Shark", "Thor"],
        "Star-Lord": ["Doctor Strange", "Cloak & Dagger"],
        "Storm": ["Captain America", "Thor"],
        "The Punisher": ["Loki", "Doctor Strange"],
        "Winter Soldier": ["Doctor Strange", "Mantis"],

        // Strategists
        "Adam Warlock": ["Thor", "Magik"],
        "Cloak & Dagger": ["Hulk", "Peni Parker"],
        "Jeff the Land Shark": ["Thor", "Rocket Raccoon"],
        "Loki": ["Doctor Strange", "Magneto"],
        "Luna Snow": ["Thor", "Magik"],
        "Mantis": ["Black Panther", "Spider-Man"],
        "Rocket Raccoon": ["Peni Parker", "Doctor Strange"]
    ]
    
    // Heroes that struggle into certain enemy heroes
    static let weakAgainstMap: [String: [String]] = [
        // Vanguards
        "Captain America": ["Storm", "Scarlet Witch"],
        "Doctor Strange": ["Loki", "The Punisher"],
        "Groot": ["Hela", "Storm"],
        "Hulk": ["Iron Man", "Cloak & Dagger"],
        "Magneto": ["Doctor Strange", "Loki"],
        "Peni Parker": ["Namor", "Rocket Raccoon"],
        "Thor": ["Luna Snow", "Jeff the Land Shark"],
        "Venom": ["Hela", "Thor"],

        // Duelists
        "Black Panther": ["Mantis", "Luna Snow"],
        "Black Widow": ["Peni Parker", "Venom"],
        "Hawkeye": ["Venom", "Thor"],
        "Hela": ["Captain America", "Black Panther"],
        "Iron Fist": ["Storm", "Scarlet Witch"],
        "Iron Man": ["Magneto", "Hela"],
        "Magik": ["Winter Soldier", "Luna Snow"],
        "Namor": ["Hawkeye", "Storm"],
        "Psylocke": ["Groot", "Magneto"],
        "Scarlet Witch": ["Captain America", "Doctor Strange"],
        "Spider-Man": ["Groot", "Mantis"],
        "Squirrel Girl": ["Iron Man", "Hela"],
        "Star-Lord": ["Black Widow", "Magneto"],
        "Storm": ["Magneto", "Black Widow"],
        "The Punisher": ["Spider-Man", "Venom"],
        "Winter Soldier": ["Peni Parker", "Venom"],

        // Strategists
        "Adam Warlock": ["Hulk", "Black Panther"],
        "Cloak & Dagger": ["Namor", "Star-Lord"],
        "Jeff the Land Shark": ["Iron Fist", "Squirrel Girl"],
        "Loki": ["Iron Fist", "The Punisher"],
        "Luna Snow": ["Hawkeye", "Black Panther"],
        "Mantis": ["Magik", "Winter Soldier"],
        "Rocket Raccoon": ["Hulk", "Spider-Man"]
    ]
    
    // Safer heroes when player is struggling
    static let defensiveHeroes: Set<String> = [
        "Captain America", "Doctor Strange", "Groot",
        "Hulk", "Magneto", "Peni Parker", "Thor", "Venom"
    ]
    
    // Heroes that provide strong utility
    static let utilityHeroes: Set<String> = [
        "Adam Warlock", "Cloak & Dagger", "Jeff the Land Shark",
        "Loki", "Luna Snow", "Mantis", "Rocket Raccoon",
        "Doctor Strange", "Magneto", "Groot"
    ]
    
    static func normalizedHeroName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        switch trimmed {
        case "punisher":
            return "The Punisher"
        case "jeff":
            return "Jeff the Land Shark"
        case "cloak and dagger":
            return "Cloak & Dagger"
        default:
            if let hero = HeroRegistry.shared.hero(name: name) {
                return hero.name
            }
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    static func buildReason(
        heroName: String,
        matchedCounters: [String],
        struggling: Bool,
        givesUtility: Bool,
        helpsEscapeBadMatchup: Bool,
        candidateRole: HeroData.HeroRole
    ) -> String {
        
        var parts: [String] = []
        
        if !matchedCounters.isEmpty {
            let enemyList = matchedCounters.joined(separator: ", ")
            parts.append("\(heroName) is a strong pick here because they counter \(enemyList)")
        }
        
        if struggling {
            switch candidateRole {
            case .vanguard:
                parts.append("they give your team a safer frontline when you are under pressure")
            case .strategist:
                parts.append("they provide more support and stability for your team")
            case .duelist:
                parts.append("they offer more consistent damage in this matchup")
            }
        }
        
        if givesUtility && matchedCounters.isEmpty {
            parts.append("they add strong team utility")
        }
        
        if helpsEscapeBadMatchup && matchedCounters.isEmpty {
            parts.append("they help you steer away from a rough matchup on your current hero")
        }
        
        if parts.isEmpty {
            parts.append("\(heroName) fits this lobby better than staying on your current pick")
        }
        
        return parts.joined(separator: " ") + "."
    }
    
    /// Shorter, non-redundant copy for #2 / #3 picks (primary keeps full `buildReason` text).
    private static func reasonForSecondAlternatePick(candidate: String, primary: String) -> String {
        if primary == "Stay Current Hero" {
            return "\(candidate) is the top swap if you still want off your current hero — use this when you're hard countered or need a fresh kit."
        }
        return "If you can't play \(primary) — taken, banned, or just not your hero — \(candidate) is another strong option for this lobby."
    }
    
    private static func reasonForThirdAlternatePick(candidate: String, primary: String, secondPick: String) -> String {
        if primary == "Stay Current Hero" {
            return "Still deciding? \(candidate) is one more flex worth trying if the picks above don't fit how you want to play."
        }
        return "If \(primary) and \(secondPick) are both off the table, \(candidate) is still a solid third choice — different kit, same goal of improving your matchup."
    }
    
    
    static func generateRecommendations(
        hero: String,
        kills: Int,
        deaths: Int,
        assists: Int,
        friendlyTeam: [String],
        enemyTeam: [String]
    ) -> [(String, String)] {
        
        let normalizedCurrentHero = normalizedHeroName(hero)
        let normalizedFriendlyTeam = Set(
            friendlyTeam.map { normalizedHeroName($0).lowercased() }
        )
        let enemies = enemyTeam
            .map { normalizedHeroName($0) }
            .filter { !$0.isEmpty }

        let struggling = deaths >= 5 || (deaths - kills >= 3)
        let doingWell = kills >= 10 && deaths <= 5 && assists >= 5
        let style = AppRecommendationStyle.stored
        
        var scoredResults: [ScoredPick] = []

        if doingWell {
            scoredResults.append(ScoredPick(
                hero: "Stay Current Hero",
                role: "None",
                score: 100,
                reasons: ["your performance is strong and there is no urgent need to switch"],
                counterHits: 0
            ))
        }

        let currentHeroWeakAgainst = weakAgainstMap[normalizedCurrentHero] ?? []
        let currentHeroBadMatchups = enemies.filter { currentHeroWeakAgainst.contains($0) }

        for candidate in HeroRegistry.shared.allHeroes {
            let candidateName = candidate.name
            let candidateLower = candidateName.lowercased()

            if candidateLower == normalizedCurrentHero.lowercased() {
                continue
            }

            if normalizedFriendlyTeam.contains(candidateLower) {
                continue
            }

            var score = 0

            let counters = counterMap[candidateName] ?? []
            let matchedCounters = enemies.filter { counters.contains($0) }

            let weakAgainst = weakAgainstMap[candidateName] ?? []
            let badMatchups = enemies.filter { weakAgainst.contains($0) }

            let givesUtility = utilityHeroes.contains(candidateName)
            let helpsEscapeBadMatchup = !currentHeroBadMatchups.isEmpty

            if !matchedCounters.isEmpty {
                score += matchedCounters.count * 4
            }

            if !badMatchups.isEmpty {
                score -= badMatchups.count * 3
            }

            if helpsEscapeBadMatchup {
                score += 2
            }

            if struggling && defensiveHeroes.contains(candidateName) {
                score += 2
            }

            if (struggling || kills <= 2 || assists <= 2) && givesUtility {
                score += 1
            }

            if struggling {
                switch candidate.role {
                case .vanguard, .strategist:
                    score += 1
                case .duelist:
                    break
                }
            }

            let finalReason = buildReason(
                heroName: candidateName,
                matchedCounters: matchedCounters,
                struggling: struggling,
                givesUtility: givesUtility,
                helpsEscapeBadMatchup: helpsEscapeBadMatchup,
                candidateRole: candidate.role
            )

            scoredResults.append(ScoredPick(
                hero: candidateName,
                role: "\(candidate.role)",
                score: score,
                reasons: [finalReason],
                counterHits: matchedCounters.count
            ))
        }

        scoredResults.sort { left, right in
            if left.score == right.score {
                return left.hero < right.hero
            }
            return left.score > right.score
        }

        var pool = scoredResults
        if style == .critical {
            let filtered = pool.filter { pick in
                if pick.hero == "Stay Current Hero" { return true }
                let strong = pick.counterHits > 0 || pick.score >= (struggling ? 5 : 9)
                let escape = pick.score >= 6 && struggling
                return strong || escape
            }
            let nonStay = filtered.filter { $0.hero != "Stay Current Hero" }
            if nonStay.isEmpty {
                pool = scoredResults
            } else {
                pool = filtered
            }
        }

        var finalResults: [(hero: String, score: Int, reasons: [String], role: String)] = []

        if style == .maxPicks {
            for pick in pool where finalResults.count < 3 {
                finalResults.append((pick.hero, pick.score, pick.reasons, pick.role))
            }
        } else {
            var usedRoles: Set<String> = []
            for pick in pool {
                guard finalResults.count < 3 else { break }
                if !usedRoles.contains(pick.role) || finalResults.count == 2 {
                    finalResults.append((pick.hero, pick.score, pick.reasons, pick.role))
                    usedRoles.insert(pick.role)
                }
            }
            if finalResults.count < 3 {
                for pick in pool {
                    guard finalResults.count < 3 else { break }
                    if !finalResults.contains(where: { $0.hero == pick.hero }) {
                        finalResults.append((pick.hero, pick.score, pick.reasons, pick.role))
                    }
                }
            }
        }

        let topThree = Array(finalResults.prefix(3))
        return topThree.enumerated().map { index, result in
            let primaryName = topThree[0].hero
            let secondName = topThree.count > 1 ? topThree[1].hero : ""
            
            let reasonText: String
            switch index {
            case 0:
                let raw = result.reasons.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                reasonText = raw.hasSuffix(".") ? raw : raw + "."
            case 1:
                reasonText = reasonForSecondAlternatePick(candidate: result.hero, primary: primaryName)
            default:
                reasonText = reasonForThirdAlternatePick(
                    candidate: result.hero,
                    primary: primaryName,
                    secondPick: secondName
                )
            }
            
            let secondPickName = topThree.count > 1 ? topThree[1].hero : nil
            let voiced = AppPreferenceStore.applyMessagingTone(
                to: reasonText,
                slotIndex: index,
                recommendedHero: result.hero,
                primaryHero: primaryName,
                secondHero: secondPickName,
                kills: kills,
                deaths: deaths,
                assists: assists,
                struggling: struggling,
                doingWell: doingWell
            )
            return (result.hero, voiced)
        }
    }
}
