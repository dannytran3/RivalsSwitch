import Foundation

class MatchStore {
    static let shared = MatchStore()
    private init() {}
    
    var currentUsername: String = ""
    var currentHero: String = ""
    var currentKills: Int = 0
    var currentDeaths: Int = 0
    var currentAssists: Int = 0

    var enemy1: String = ""
    var enemy2: String = ""
    var enemy3: String = ""
    var enemy4: String = ""
    var enemy5: String = ""
    var enemy6: String = ""

    var recommendedHero1: String = ""
    var recommendedReason1: String = ""

    var recommendedHero2: String = ""
    var recommendedReason2: String = ""

    var recommendedHero3: String = ""
    var recommendedReason3: String = ""

    private let matchesKey = "savedMatches"

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

    func saveCurrentMatch() {
        let enemySummary = [enemy1, enemy2, enemy3, enemy4, enemy5, enemy6]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        let summary = "\(currentHero) | K:\(currentKills) D:\(currentDeaths) A:\(currentAssists)\nEnemies: \(enemySummary)\nTop swap: \(recommendedHero1)"

        var saved = loadMatches()
        saved.insert(summary, at: 0)

        UserDefaults.standard.set(saved, forKey: matchesKey)
    }

    func loadMatches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: matchesKey) ?? []
    }
}
