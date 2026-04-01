//
//  PartyView.swift
//  RivalsSwitch
//
//  Main party screen with 3x2 member grid and shared recommendations
//

import SwiftUI

struct PartyView: View {
    @StateObject private var partyManager = PartyManager.shared
    @State private var showInviteSheet = false
    @State private var showHeroSelector = false
    @State private var showLeaveAlert = false
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "25203E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if partyManager.isInParty {
                partyContent
            } else {
                noPartyContent
            }
        }
        .navigationTitle("Party")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showInviteSheet) {
            InvitePlayerSheet(isPresented: $showInviteSheet)
        }
        .sheet(isPresented: $showHeroSelector) {
            HeroSelectorSheet(isPresented: $showHeroSelector)
        }
        .alert("Leave Party", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                Task {
                    await partyManager.leaveParty()
                }
            }
        } message: {
            Text("Are you sure you want to leave the party?")
        }
    }
    
    // MARK: - Party Content
    
    private var partyContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Party header
                partyHeader
                
                // Member grid (3x2)
                memberGrid
                
                // Shared recommendations
                if partyManager.currentRecommendation != nil {
                    sharedRecommendations
                }
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
    }
    
    private var partyHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "FFD700"))
                
                Text("Party")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Member count
                Text("\(partyManager.currentParty?.members.count ?? 0)/6")
                    .font(.headline)
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "FFD700").opacity(0.2))
                    )
            }
            
            if let party = partyManager.currentParty,
               let leader = party.leader {
                HStack {
                    Text("Leader: \(leader.username)")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "32324C").opacity(0.6))
        )
    }
    
    private var memberGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                let member = partyManager.currentParty?.members[safe: index]
                let isCurrentUser = member?.id == getCurrentUserId()
                
                PartyMemberCard(
                    member: member,
                    slotNumber: index + 1,
                    isCurrentUser: isCurrentUser
                ) {
                    if isCurrentUser {
                        showHeroSelector = true
                    }
                }
            }
        }
    }
    
    private var sharedRecommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(Color(hex: "FFD700"))
                
                Text("Team Recommendations")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if let recommendation = partyManager.currentRecommendation {
                // Scanned by info
                Text("Scanned by \(recommendation.scannedByUsername)")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
                
                // Enemy team
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enemy Team")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(recommendation.enemyTeam.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
                
                // Recommendations
                ForEach(recommendation.recommendations) { heroRec in
                    recommendationCard(heroRec)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "32324C").opacity(0.6))
        )
    }
    
    private func recommendationCard(_ rec: HeroRecommendation) -> some View {
        HStack(spacing: 12) {
            // Hero image
            Image(uiImage: HeroRegistry.shared.heroImage(slug: rec.heroSlug))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rec.heroName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Priority badge
                    Text("#\(rec.priority)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "FFD700"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "FFD700").opacity(0.2))
                        )
                }
                
                Text(rec.reason)
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "3D3D5C").opacity(0.6))
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Invite button (only for leader)
            if partyManager.isCurrentUserLeader(),
               !(partyManager.currentParty?.isFull ?? false) {
                Button(action: {
                    showInviteSheet = true
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .font(.headline)
                        Text("Invite Player")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "FFA500")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundColor(Color(hex: "1A1A2E"))
                }
            }
            
            // Leave party button
            Button(action: {
                showLeaveAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                    Text("Leave Party")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.6), lineWidth: 2)
                )
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - No Party Content
    
    private var noPartyContent: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "FFD700").opacity(0.6))
            
            // Title
            Text("No Active Party")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Message
            Text("Create or join a party to team up with friends and share hero recommendations!")
                .font(.body)
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Create party button
            Button(action: {
                Task {
                    await partyManager.createParty()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("Create Party")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFA500")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(Color(hex: "1A1A2E"))
                .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private func getCurrentUserId() -> String {
        guard let username = UserSession.shared.username else {
            return "unknown"
        }
        return "user_\(username)"
    }
}

// MARK: - Array Safe Subscript Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

struct PartyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PartyView()
        }
        .preferredColorScheme(.dark)
    }
}
