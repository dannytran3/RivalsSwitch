import Foundation

class RecommendationEngine {
    
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
        
        // Format hero name in caps
        let heroDisplay = heroName.uppercased()
        
        if !matchedCounters.isEmpty {
            let enemyList = matchedCounters.map { $0 }.joined(separator: ", ")
            parts.append("\(heroDisplay) is a strong pick because it counters \(enemyList)")
        }
        
        if struggling {
            switch candidateRole {
            case .vanguard:
                parts.append("it gives your team a safer FRONTLINE under pressure")
            case .strategist:
                parts.append("it provides more SUPPORT and stability for your team")
            case .duelist:
                parts.append("it offers more consistent DAMAGE in this matchup")
            }
        }
        
        if givesUtility && matchedCounters.isEmpty {
            parts.append("it adds better TEAM UTILITY")
        }
        
        if helpsEscapeBadMatchup && matchedCounters.isEmpty {
            parts.append("it helps you avoid a BAD MATCHUP")
        }
        
        if parts.isEmpty {
            parts.append("\(heroDisplay) fits better into the current match")
        }
        
        return parts.joined(separator: ". ") + "."
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
        
        var scoredResults: [(hero: String, role: String, score: Int, reasons: [String])] = []

        // If player is doing well, keep "stay" as the best option
        if doingWell {
            scoredResults.append((
                hero: "Stay Current Hero",
                role: "None",
                score: 100,
                reasons: ["your performance is strong and there is no urgent need to switch"]
            ))
        }

        // Check whether current hero is in a bad matchup
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
                case .vanguard:
                    score += 1
                case .strategist:
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

            scoredResults.append((
                hero: candidateName,
                role: "\(candidate.role)",
                score: score,
                reasons: [finalReason]
            ))
        }

        scoredResults.sort { left, right in
            if left.score == right.score {
                return left.hero < right.hero
            }
            return left.score > right.score
        }

        // Prevent top 3 from always being the same exact role when possible
        var finalResults: [(hero: String, score: Int, reasons: [String], role: String)] = []
        var usedRoles: Set<String> = []

        for result in scoredResults {
            if finalResults.count < 3 {
                if !usedRoles.contains(result.role) || finalResults.count == 2 {
                    finalResults.append((
                        hero: result.hero,
                        score: result.score,
                        reasons: result.reasons,
                        role: result.role
                    ))
                    usedRoles.insert(result.role)
                }
            } else {
                break
            }
        }

        // Fallback in case role filtering skipped too many
        if finalResults.count < 3 {
            for result in scoredResults {
                if finalResults.count >= 3 { break }
                if !finalResults.contains(where: { $0.hero == result.hero }) {
                    finalResults.append((
                        hero: result.hero,
                        score: result.score,
                        reasons: result.reasons,
                        role: result.role
                    ))
                }
            }
        }

        return finalResults.prefix(3).map { result in
            let reasonText = result.reasons.joined(separator: ". ")
            return (result.hero, reasonText.capitalized + ".")
        }
    }
}
