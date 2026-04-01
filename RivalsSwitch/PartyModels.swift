//
//  PartyModels.swift
//  RivalsSwitch
//
//  Models for multiplayer party system
//

import Foundation

// MARK: - Party Member

struct PartyMember: Identifiable, Codable, Equatable {
    let id: String
    let username: String
    var selectedHero: String? // Hero slug (e.g., "iron-man", "spider-man")
    var isLeader: Bool
    let joinedAt: Date
    
    init(id: String = UUID().uuidString, 
         username: String, 
         selectedHero: String? = nil, 
         isLeader: Bool = false,
         joinedAt: Date = Date()) {
        self.id = id
        self.username = username
        self.selectedHero = selectedHero
        self.isLeader = isLeader
        self.joinedAt = joinedAt
    }
    
    static func == (lhs: PartyMember, rhs: PartyMember) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Party

struct Party: Identifiable, Codable {
    let id: String
    var members: [PartyMember]
    let createdAt: Date
    var lastUpdated: Date
    
    var maxMembers: Int { 6 }
    var isFull: Bool { members.count >= maxMembers }
    var hasSpace: Bool { members.count < maxMembers }
    
    var leader: PartyMember? {
        members.first(where: { $0.isLeader })
    }
    
    init(id: String = UUID().uuidString,
         members: [PartyMember] = [],
         createdAt: Date = Date(),
         lastUpdated: Date = Date()) {
        self.id = id
        self.members = members
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
    
    mutating func addMember(_ member: PartyMember) -> Bool {
        guard hasSpace, !members.contains(where: { $0.id == member.id }) else {
            return false
        }
        members.append(member)
        lastUpdated = Date()
        return true
    }
    
    mutating func removeMember(_ memberId: String) {
        members.removeAll { $0.id == memberId }
        lastUpdated = Date()
        
        // If leader left, assign new leader
        if !members.contains(where: { $0.isLeader }), let firstMember = members.first {
            if let index = members.firstIndex(where: { $0.id == firstMember.id }) {
                members[index].isLeader = true
            }
        }
    }
    
    mutating func updateMemberHero(memberId: String, hero: String) {
        if let index = members.firstIndex(where: { $0.id == memberId }) {
            members[index].selectedHero = hero
            lastUpdated = Date()
        }
    }
}

// MARK: - Party Invite

struct PartyInvite: Identifiable, Codable {
    let id: String
    let partyId: String
    let fromUsername: String
    let fromUserId: String
    let toUsername: String
    let toUserId: String
    let createdAt: Date
    var status: InviteStatus
    
    enum InviteStatus: String, Codable {
        case pending
        case accepted
        case declined
        case expired
    }
    
    init(id: String = UUID().uuidString,
         partyId: String,
         fromUsername: String,
         fromUserId: String,
         toUsername: String,
         toUserId: String,
         createdAt: Date = Date(),
         status: InviteStatus = .pending) {
        self.id = id
        self.partyId = partyId
        self.fromUsername = fromUsername
        self.fromUserId = fromUserId
        self.toUsername = toUsername
        self.toUserId = toUserId
        self.createdAt = createdAt
        self.status = status
    }
    
    var isExpired: Bool {
        // Invites expire after 24 hours
        Date().timeIntervalSince(createdAt) > 86400
    }
}

// MARK: - Shared Party Recommendation

struct PartyRecommendation: Identifiable, Codable {
    let id: String
    let partyId: String
    let scannedByUsername: String
    let scannedByUserId: String
    let recommendations: [HeroRecommendation]
    let enemyTeam: [String]
    let timestamp: Date
    
    init(id: String = UUID().uuidString,
         partyId: String,
         scannedByUsername: String,
         scannedByUserId: String,
         recommendations: [HeroRecommendation],
         enemyTeam: [String],
         timestamp: Date = Date()) {
        self.id = id
        self.partyId = partyId
        self.scannedByUsername = scannedByUsername
        self.scannedByUserId = scannedByUserId
        self.recommendations = recommendations
        self.enemyTeam = enemyTeam
        self.timestamp = timestamp
    }
}

struct HeroRecommendation: Identifiable, Codable {
    let id: String
    let heroName: String
    let heroSlug: String
    let reason: String
    let priority: Int // 1 = highest priority
    
    init(id: String = UUID().uuidString,
         heroName: String,
         heroSlug: String,
         reason: String,
         priority: Int) {
        self.id = id
        self.heroName = heroName
        self.heroSlug = heroSlug
        self.reason = reason
        self.priority = priority
    }
}

// MARK: - Hero Data

struct HeroData: Identifiable, Codable {
    let id: String
    let name: String
    let slug: String // For image asset lookup (e.g., "iron-man")
    let role: HeroRole
    
    enum HeroRole: String, Codable {
        case vanguard
        case duelist
        case strategist
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         slug: String,
         role: HeroRole) {
        self.id = id
        self.name = name
        self.slug = slug
        self.role = role
    }
    
    // Image asset name
    var imageName: String {
        "hero_\(slug)"
    }
}
