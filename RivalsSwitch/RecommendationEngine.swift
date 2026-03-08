import Foundation

class RecommendationEngine {

    static func generateRecommendations(
        hero: String,
        kills: Int,
        deaths: Int,
        assists: Int,
        enemyTeam: [String]
    ) -> [(String, String)] {

        let currentHero = hero.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let enemies = enemyTeam.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        var recommendations: [(String, String)] = []

        func addRecommendation(_ hero: String, _ reason: String) {
            if !recommendations.contains(where: { $0.0 == hero }) {
                recommendations.append((hero, reason))
            }
        }

        // Performance-based logic
        let struggling = deaths >= 5 || (deaths - kills >= 3)

        // Enemy counter logic
        if enemies.contains("hulk") {
            addRecommendation("Iron Man", "Iron Man can pressure Hulk from range and avoid close-range brawls.")
        }

        if enemies.contains("iron man") {
            addRecommendation("Magneto", "Magneto gives your team stronger frontline protection against ranged pressure like Iron Man.")
        }

        if enemies.contains("storm") {
            addRecommendation("Magneto", "Magneto helps against high ranged pressure and improves team stability.")
            addRecommendation("Punisher", "Punisher can provide reliable ranged damage against mobile enemy threats like Storm.")
        }

        if enemies.contains("loki") {
            addRecommendation("Punisher", "Punisher offers steadier ranged pressure and can punish fragile enemy backline picks like Loki.")
        }

        if enemies.contains("punisher") {
            addRecommendation("Hulk", "Hulk can absorb Punisher's pressure better and create space for your team.")
        }

        if enemies.contains("magneto") {
            addRecommendation("Iron Man", "Iron Man can avoid Magneto's close pressure and attack from safer angles.")
        }

        // If player is struggling, prioritize safer picks
        if struggling {
            addRecommendation("Punisher", "Your current stats suggest you are struggling, so a safer and more stable damage pick may help.")
            addRecommendation("Hulk", "A tankier hero like Hulk may help if you are getting punished too quickly.")
        }

        // If no strong reason to switch, recommend staying
        if recommendations.isEmpty {
            addRecommendation("Stay Current Hero", "Your current performance and the enemy team do not suggest an urgent swap.")
            addRecommendation("Magneto", "Optional team-balance pick if your team needs more frontline presence.")
            addRecommendation("Punisher", "Optional safer damage option if you want a simpler matchup.")
        }

        // Always return exactly 3 recommendations if possible
        let fallbackPool: [(String, String)] = [
            ("Magneto", "Provides stronger frontline presence."),
            ("Punisher", "Gives stable ranged damage."),
            ("Hulk", "Adds survivability and frontline pressure."),
            ("Iron Man", "Provides ranged pressure and safer positioning.")
        ]

        for item in fallbackPool {
            if recommendations.count >= 3 { break }
            if !recommendations.contains(where: { $0.0 == item.0 }) {
                recommendations.append(item)
            }
        }

        return Array(recommendations.prefix(3))
    }
}
