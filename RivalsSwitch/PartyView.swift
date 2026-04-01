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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Enhanced background with depth
            LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "1F1F3A"),
                    Color(hex: "25203E"),
                    Color(hex: "1A1A2E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle radial glow for depth
            RadialGradient(
                colors: [
                    Color(hex: "FFD700").opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
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
        ScrollView(showsIndicators: true) {
            VStack(spacing: 32) { // Increased spacing for better hierarchy
                // Party header
                partyHeader
                
                // Member grid (3x2)
                memberGrid
                    .padding(.top, 8)
                
                // Shared recommendations
                if partyManager.currentRecommendation != nil {
                    sharedRecommendations
                        .padding(.top, 8)
                }
                
                // Action buttons
                actionButtons
                    .padding(.top, 16)
                
                // Bottom spacer to ensure last content is visible
                Color.clear.frame(height: 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 20) // Extra bottom padding to prevent cutoff
        }
    }
    
    private var partyHeader: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Party icon with glow
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFD700").opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "FFD700"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Squad")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if let party = partyManager.currentParty,
                       let leader = party.leader {
                        // Leader name in gold
                        Text("Led by \(leader.username)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "FFD700"))
                    }
                }
                
                Spacer()
                
                // Member count badge - fixed to show "1/6" on one line
                HStack(spacing: 0) {
                    Text("\(partyManager.currentParty?.members.count ?? 0)/6")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFD700").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "2A2A4C").opacity(0.6),
                            Color(hex: "1F1F3A").opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700").opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
    
    private var memberGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
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
            HeroImageView(slug: rec.heroSlug, contentMode: .fill)
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
        VStack(spacing: 14) {
            // Invite button (only for leader)
            if partyManager.isCurrentUserLeader(),
               !(partyManager.currentParty?.isFull ?? false) {
                Button(action: {
                    showInviteSheet = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Invite Player")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
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
                    .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 10, x: 0, y: 4)
                }
            }
            
            // Leave party button
            Button(action: {
                showLeaveAlert = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Leave Squad")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.red.opacity(0.5), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.05))
                        )
                )
                .foregroundColor(.red.opacity(0.9))
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
