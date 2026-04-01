//
//  PartyPreviewData.swift
//  RivalsSwitch
//
//  Mock data for SwiftUI previews and testing
//

import Foundation

#if DEBUG

extension PartyManager {
    /// Creates a mock party manager with sample data for previews
    static func mockWithParty() -> PartyManager {
        let manager = PartyManager.shared
        
        // Create mock party
        let mockParty = Party(
            id: "mock-party-1",
            members: [
                PartyMember(
                    id: "user_1",
                    username: "IronPlayer",
                    selectedHero: "iron-man",
                    isLeader: true
                ),
                PartyMember(
                    id: "user_2",
                    username: "WebSlinger",
                    selectedHero: "spider-man",
                    isLeader: false
                ),
                PartyMember(
                    id: "user_3",
                    username: "StormRider",
                    selectedHero: "storm",
                    isLeader: false
                ),
                PartyMember(
                    id: "user_4",
                    username: "MagnetoFan",
                    selectedHero: nil,
                    isLeader: false
                )
            ]
        )
        
        Task { @MainActor in
            manager.currentParty = mockParty
            manager.isInParty = true
            
            // Add mock recommendation
            manager.currentRecommendation = PartyRecommendation(
                partyId: mockParty.id,
                scannedByUsername: "IronPlayer",
                scannedByUserId: "user_1",
                recommendations: [
                    HeroRecommendation(
                        heroName: "Luna Snow",
                        heroSlug: "luna-snow",
                        reason: "Your team needs a strong healer to sustain in teamfights",
                        priority: 1
                    ),
                    HeroRecommendation(
                        heroName: "Captain America",
                        heroSlug: "captain-america",
                        reason: "A tank would help protect your team's backline",
                        priority: 2
                    ),
                    HeroRecommendation(
                        heroName: "Scarlet Witch",
                        heroSlug: "scarlet-witch",
                        reason: "Additional DPS would increase your team's pressure",
                        priority: 3
                    )
                ],
                enemyTeam: ["Hulk", "Thor", "Black Widow", "Hawkeye", "Mantis", "Luna Snow"]
            )
        }
        
        return manager
    }
    
    /// Creates a mock party manager with pending invites
    static func mockWithInvites() -> PartyManager {
        let manager = PartyManager.shared
        
        Task { @MainActor in
            manager.pendingInvites = [
                PartyInvite(
                    partyId: "party-1",
                    fromUsername: "IronPlayer",
                    fromUserId: "user_1",
                    toUsername: "CurrentUser",
                    toUserId: "user_current",
                    status: .pending
                ),
                PartyInvite(
                    partyId: "party-2",
                    fromUsername: "WebSlinger",
                    fromUserId: "user_2",
                    toUsername: "CurrentUser",
                    toUserId: "user_current",
                    status: .pending
                )
            ]
        }
        
        return manager
    }
}

extension HeroData {
    /// Sample heroes for testing
    static let mockHeroes: [HeroData] = [
        HeroData(name: "Iron Man", slug: "iron-man", role: .duelist),
        HeroData(name: "Spider-Man", slug: "spider-man", role: .duelist),
        HeroData(name: "Captain America", slug: "captain-america", role: .vanguard),
        HeroData(name: "Thor", slug: "thor", role: .vanguard),
        HeroData(name: "Mantis", slug: "mantis", role: .strategist),
        HeroData(name: "Luna Snow", slug: "luna-snow", role: .strategist)
    ]
}

extension Party {
    /// Creates a full party for testing
    static let mockFullParty = Party(
        id: "full-party",
        members: [
            PartyMember(username: "Player1", selectedHero: "iron-man", isLeader: true),
            PartyMember(username: "Player2", selectedHero: "spider-man", isLeader: false),
            PartyMember(username: "Player3", selectedHero: "captain-america", isLeader: false),
            PartyMember(username: "Player4", selectedHero: "thor", isLeader: false),
            PartyMember(username: "Player5", selectedHero: "mantis", isLeader: false),
            PartyMember(username: "Player6", selectedHero: "luna-snow", isLeader: false)
        ]
    )
    
    /// Creates a party with available slots
    static let mockPartialParty = Party(
        id: "partial-party",
        members: [
            PartyMember(username: "Leader", selectedHero: "iron-man", isLeader: true),
            PartyMember(username: "Member2", selectedHero: nil, isLeader: false),
            PartyMember(username: "Member3", selectedHero: "captain-america", isLeader: false)
        ]
    )
}

#endif
