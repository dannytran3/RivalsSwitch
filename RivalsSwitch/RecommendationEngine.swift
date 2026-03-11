import Foundation

class RecommendationEngine {

    // Handling logic for generating hero swap recommendations
    static func generateRecommendations(
        hero: String,
        kills: Int,
        deaths: Int,
        assists: Int,
        enemyTeam: [String]
    ) -> [(String, String)] {

        // Normalize hero and enemy names
        let _ = hero.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let enemies = enemyTeam.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Stores recommendation results
        var recommendations: [(String, String)] = []

        //to avoid duplicate recommendations
        func addRecommendation(_ hero: String, _ reason: String) {
            if !recommendations.contains(where: { $0.0 == hero }) {
                recommendations.append((hero, reason))
            }
        }

        // Determine if player is struggling based on performance
        let struggling = deaths >= 5 || (deaths - kills >= 3)

        // Enemy counter logic
        if struggling {
                addRecommendation("Defensive Hero", "Your current stats suggest you may be struggling, so a more defensive hero could help.")
                addRecommendation("Team Utility Hero", "A utility-focused hero may help support the team and reduce pressure.")
            }

        // If player is doing fine
        if !struggling {
            addRecommendation("Stay Current Hero", "Your performance does not indicate a strong need to switch characters.")
        }

        // Ensure  always have 3 recommendations
        if recommendations.count < 3 {

            let fallbackPool: [(String, String)] = [
                ("Alternate Hero", "Trying a different hero may provide a better matchup."),
                ("Team Balance Pick", "Switching roles could help balance your team's composition."),
                ("Flexible Option", "A flexible hero may adapt better to the current match situation.")
            ]

            //adding the fallback recommendations to the recommendations list if needed
            for item in fallbackPool {
                if recommendations.count >= 3 { break }
                if !recommendations.contains(where: { $0.0 == item.0 }) {
                    recommendations.append(item)
                }
            }
        }

        //Return exactly three recommendations
        return Array(recommendations.prefix(3))
    }
}
