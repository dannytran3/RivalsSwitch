//
//  PartyManager.swift
//  RivalsSwitch
//
//  Service for managing party state and operations
//

import Foundation
import Combine

// MARK: - Party Service Protocol (for future backend implementation)

protocol PartyServiceProtocol {
    func createParty(leaderId: String, leaderUsername: String) async throws -> Party
    func joinParty(partyId: String, member: PartyMember) async throws -> Party
    func leaveParty(partyId: String, memberId: String) async throws
    func sendInvite(partyId: String, fromUser: String, fromUserId: String, toUser: String, toUserId: String) async throws -> PartyInvite
    func acceptInvite(inviteId: String) async throws -> Party
    func declineInvite(inviteId: String) async throws
    func updateMemberHero(partyId: String, memberId: String, hero: String) async throws
    func fetchParty(partyId: String) async throws -> Party
    func fetchInvites(userId: String) async throws -> [PartyInvite]
}

// MARK: - Party Manager

@MainActor
class PartyManager: ObservableObject {
    static let shared = PartyManager()
    
    // Published state
    @Published var currentParty: Party?
    @Published var pendingInvites: [PartyInvite] = []
    @Published var currentRecommendation: PartyRecommendation?
    @Published var isInParty: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let partyKey = "currentParty"
    private let invitesKey = "pendingInvites"
    private let recommendationKey = "currentRecommendation"
    
    // Service (mock for now, can be replaced with real backend)
    private var service: PartyServiceProtocol
    
    private init(service: PartyServiceProtocol = MockPartyService()) {
        self.service = service
        loadPersistedState()
    }
    
    // MARK: - Persistence
    
    private func loadPersistedState() {
        // Load party
        if let data = userDefaults.data(forKey: partyKey),
           let party = try? JSONDecoder().decode(Party.self, from: data) {
            currentParty = party
            isInParty = true
        }
        
        // Load invites
        if let data = userDefaults.data(forKey: invitesKey),
           let invites = try? JSONDecoder().decode([PartyInvite].self, from: data) {
            pendingInvites = invites.filter { !$0.isExpired && $0.status == .pending }
        }
        
        // Load recommendation
        if let data = userDefaults.data(forKey: recommendationKey),
           let recommendation = try? JSONDecoder().decode(PartyRecommendation.self, from: data) {
            currentRecommendation = recommendation
        }
    }
    
    private func persistParty() {
        if let party = currentParty,
           let data = try? JSONEncoder().encode(party) {
            userDefaults.set(data, forKey: partyKey)
        } else {
            userDefaults.removeObject(forKey: partyKey)
        }
    }
    
    private func persistInvites() {
        if let data = try? JSONEncoder().encode(pendingInvites) {
            userDefaults.set(data, forKey: invitesKey)
        }
    }
    
    private func persistRecommendation() {
        if let recommendation = currentRecommendation,
           let data = try? JSONEncoder().encode(recommendation) {
            userDefaults.set(data, forKey: recommendationKey)
        } else {
            userDefaults.removeObject(forKey: recommendationKey)
        }
    }
    
    // MARK: - Party Operations
    
    func createParty() async {
        do {
            guard let username = UserSession.shared.username else {
                errorMessage = "No user logged in"
                return
            }
            
            let userId = getCurrentUserId()
            let leader = PartyMember(username: username, isLeader: true)
            let party = try await service.createParty(leaderId: userId, leaderUsername: username)
            
            currentParty = party
            isInParty = true
            persistParty()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to create party: \(error.localizedDescription)"
        }
    }
    
    func leaveParty() async {
        do {
            guard let party = currentParty else { return }
            let userId = getCurrentUserId()
            
            try await service.leaveParty(partyId: party.id, memberId: userId)
            
            currentParty = nil
            currentRecommendation = nil
            isInParty = false
            persistParty()
            persistRecommendation()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to leave party: \(error.localizedDescription)"
        }
    }
    
    func sendInvite(toUsername: String) async {
        do {
            guard let party = currentParty else {
                errorMessage = "Not in a party"
                return
            }
            
            guard let fromUsername = UserSession.shared.username else {
                errorMessage = "No user logged in"
                return
            }
            
            guard party.hasSpace else {
                errorMessage = "Party is full"
                return
            }
            
            let fromUserId = getCurrentUserId()
            let toUserId = "user_\(toUsername)" // Mock user ID
            
            let invite = try await service.sendInvite(
                partyId: party.id,
                fromUser: fromUsername,
                fromUserId: fromUserId,
                toUser: toUsername,
                toUserId: toUserId
            )
            
            errorMessage = nil
            // Note: In real implementation, this would notify the target user
        } catch {
            errorMessage = "Failed to send invite: \(error.localizedDescription)"
        }
    }
    
    func acceptInvite(_ invite: PartyInvite) async {
        do {
            let party = try await service.acceptInvite(inviteId: invite.id)
            
            currentParty = party
            isInParty = true
            pendingInvites.removeAll { $0.id == invite.id }
            
            persistParty()
            persistInvites()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to accept invite: \(error.localizedDescription)"
        }
    }
    
    func declineInvite(_ invite: PartyInvite) async {
        do {
            try await service.declineInvite(inviteId: invite.id)
            
            pendingInvites.removeAll { $0.id == invite.id }
            persistInvites()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to decline invite: \(error.localizedDescription)"
        }
    }
    
    func updateMyHero(_ heroSlug: String) async {
        do {
            guard let party = currentParty else { return }
            let userId = getCurrentUserId()
            
            try await service.updateMemberHero(partyId: party.id, memberId: userId, hero: heroSlug)
            
            // Update local state
            currentParty?.updateMemberHero(memberId: userId, hero: heroSlug)
            persistParty()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update hero: \(error.localizedDescription)"
        }
    }
    
    func refreshParty() async {
        do {
            guard let party = currentParty else { return }
            
            let updatedParty = try await service.fetchParty(partyId: party.id)
            currentParty = updatedParty
            persistParty()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to refresh party: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Recommendations
    
    func updatePartyRecommendation(
        recommendations: [(String, String)],
        enemyTeam: [String]
    ) async {
        guard let party = currentParty else { return }
        guard let username = UserSession.shared.username else { return }
        
        let userId = getCurrentUserId()
        
        // Convert recommendations to structured format
        let heroRecommendations = recommendations.enumerated().map { index, rec in
            HeroRecommendation(
                heroName: rec.0,
                heroSlug: rec.0.lowercased().replacingOccurrences(of: " ", with: "-"),
                reason: rec.1,
                priority: index + 1
            )
        }
        
        let partyRec = PartyRecommendation(
            partyId: party.id,
            scannedByUsername: username,
            scannedByUserId: userId,
            recommendations: heroRecommendations,
            enemyTeam: enemyTeam
        )
        
        currentRecommendation = partyRec
        persistRecommendation()
        
        // In a real implementation, this would sync to all party members
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserId() -> String {
        // In a real app, this would come from authentication
        guard let username = UserSession.shared.username else {
            return "unknown"
        }
        return "user_\(username)"
    }
    
    func getCurrentMember() -> PartyMember? {
        guard let party = currentParty else { return nil }
        let userId = getCurrentUserId()
        return party.members.first { $0.id == userId }
    }
    
    func isCurrentUserLeader() -> Bool {
        getCurrentMember()?.isLeader ?? false
    }
}

// MARK: - Mock Service Implementation

class MockPartyService: PartyServiceProtocol {
    
    func createParty(leaderId: String, leaderUsername: String) async throws -> Party {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let leader = PartyMember(
            id: leaderId,
            username: leaderUsername,
            isLeader: true
        )
        
        return Party(members: [leader])
    }
    
    func joinParty(partyId: String, member: PartyMember) async throws -> Party {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // In real implementation, fetch party from backend and add member
        var party = Party(id: partyId)
        _ = party.addMember(member)
        return party
    }
    
    func leaveParty(partyId: String, memberId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // In real implementation, remove member from backend
    }
    
    func sendInvite(partyId: String, fromUser: String, fromUserId: String, toUser: String, toUserId: String) async throws -> PartyInvite {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return PartyInvite(
            partyId: partyId,
            fromUsername: fromUser,
            fromUserId: fromUserId,
            toUsername: toUser,
            toUserId: toUserId
        )
    }
    
    func acceptInvite(inviteId: String) async throws -> Party {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // In real implementation, add user to party on backend
        return Party()
    }
    
    func declineInvite(inviteId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // In real implementation, mark invite as declined on backend
    }
    
    func updateMemberHero(partyId: String, memberId: String, hero: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        // In real implementation, update hero on backend
    }
    
    func fetchParty(partyId: String) async throws -> Party {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // In real implementation, fetch from backend
        return Party(id: partyId)
    }
    
    func fetchInvites(userId: String) async throws -> [PartyInvite] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // In real implementation, fetch from backend
        return []
    }
}
