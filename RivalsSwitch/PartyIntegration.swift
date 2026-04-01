//
//  PartyIntegration.swift
//  RivalsSwitch
//
//  Helper for integrating party system with scan flow
//

import Foundation

class PartyIntegration {
    static let shared = PartyIntegration()
    
    private init() {}
    
    /// Call this after recommendations are generated to update party state
    /// This should be called from the RecommendationsViewController or wherever
    /// recommendations are finalized
    @MainActor
    func updatePartyRecommendations() async {
        let partyManager = PartyManager.shared
        
        // Only update if user is in a party
        guard partyManager.isInParty else { return }
        
        // Get current match data from MatchStore
        let matchStore = MatchStore.shared
        
        // Extract recommendations
        let recommendations: [(String, String)] = [
            (matchStore.recommendedHero1, matchStore.recommendedReason1),
            (matchStore.recommendedHero2, matchStore.recommendedReason2),
            (matchStore.recommendedHero3, matchStore.recommendedReason3)
        ].filter { !$0.0.isEmpty }
        
        // Extract enemy team
        let enemyTeam = [
            matchStore.enemy1,
            matchStore.enemy2,
            matchStore.enemy3,
            matchStore.enemy4,
            matchStore.enemy5,
            matchStore.enemy6
        ].filter { !$0.isEmpty }
        
        // Update party recommendations
        await partyManager.updatePartyRecommendation(
            recommendations: recommendations,
            enemyTeam: enemyTeam
        )
    }
    
    /// Helper to check if user is in a party
    func isInParty() -> Bool {
        return PartyManager.shared.isInParty
    }
    
    /// Get current party member count
    func partyMemberCount() -> Int {
        return PartyManager.shared.currentParty?.members.count ?? 0
    }
}

// MARK: - MatchStore Extension for Party Integration

extension MatchStore {
    /// Saves match and updates party recommendations if in a party
    @MainActor
    func saveMatchWithPartyUpdate() async {
        // Save match locally as usual
        saveCurrentMatch()
        
        // Update party recommendations
        await PartyIntegration.shared.updatePartyRecommendations()
    }
}
