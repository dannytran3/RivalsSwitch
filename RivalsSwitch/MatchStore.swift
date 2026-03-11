import Foundation

// Central store used to temporarily hold match data
// while the user moves through the scanning flow
class MatchStore {
    // Shared singleton instance used across the app
    static let shared = MatchStore()
    private init() {}
    
    // Current player information
    var currentUsername: String = ""
    var currentHero: String = ""
    var currentKills: Int = 0
    var currentDeaths: Int = 0
    var currentAssists: Int = 0

    // Enemy team heroes detected from the scoreboard
    var enemy1: String = ""
    var enemy2: String = ""
    var enemy3: String = ""
    var enemy4: String = ""
    var enemy5: String = ""
    var enemy6: String = ""

    // Top recommendations returned from the recommendation engine
    var recommendedHero1: String = ""
    var recommendedReason1: String = ""

    var recommendedHero2: String = ""
    var recommendedReason2: String = ""

    var recommendedHero3: String = ""
    var recommendedReason3: String = ""
    
    
    // Key used to store match history in UserDefaults
    private let matchesKey = "savedMatches"

    // Clears all match data when starting a new match
    func clearCurrentMatch() {
        currentUsername = ""
        currentHero = ""
        currentKills = 0
        currentDeaths = 0
        currentAssists = 0

        enemy1 = ""
        enemy2 = ""
        enemy3 = ""
        enemy4 = ""
        enemy5 = ""
        enemy6 = ""

        recommendedHero1 = ""
        recommendedReason1 = ""
        recommendedHero2 = ""
        recommendedReason2 = ""
        recommendedHero3 = ""
        recommendedReason3 = ""
    }

    // Saves the current match summary into local storage
    func saveCurrentMatch() {
        // Combine enemy heroes into string
        let enemySummary = [enemy1, enemy2, enemy3, enemy4, enemy5, enemy6]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        // Build match summary text
        let summary = "\(currentHero) | K:\(currentKills) D:\(currentDeaths) A:\(currentAssists)\nEnemies: \(enemySummary)\nTop swap: \(recommendedHero1)"

        // Insert newest match at the top
        var saved = loadMatches()
        saved.insert(summary, at: 0)

        // Save updated history to UserDefaults
        UserDefaults.standard.set(saved, forKey: matchesKey)
    }

    // Loads saved match history
    func loadMatches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: matchesKey) ?? []
    }
}
