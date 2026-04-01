//
//  PartyMemberCard.swift
//  RivalsSwitch
//
//  Marvel Rivals-inspired party member card
//

import SwiftUI

struct PartyMemberCard: View {
    let member: PartyMember?
    let slotNumber: Int
    let isCurrentUser: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    init(member: PartyMember?, 
         slotNumber: Int, 
         isCurrentUser: Bool = false,
         onTap: @escaping () -> Void = {}) {
        self.member = member
        self.slotNumber = slotNumber
        self.isCurrentUser = isCurrentUser
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            ZStack {
                if let member = member {
                    // Occupied slot
                    occupiedCard(member: member)
                } else {
                    // Empty slot
                    emptyCard()
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isCurrentUser ? 3 : 1.5)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private func occupiedCard(member: PartyMember) -> some View {
        ZStack {
            // Hero background image
            if let heroSlug = member.selectedHero {
                heroBackground(slug: heroSlug)
            } else {
                defaultBackground()
            }
            
            // Dark gradient overlay for readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Leader badge
                    if member.isLeader {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // Current user indicator
                    if isCurrentUser {
                        Text("YOU")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "FFD700"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FFD700").opacity(0.2))
                            )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                Spacer()
                
                // Username
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.username)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Selected hero name
                    if let heroSlug = member.selectedHero,
                       let hero = HeroRegistry.shared.hero(slug: heroSlug) {
                        Text(hero.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                            .lineLimit(1)
                    } else {
                        Text("No hero selected")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                            .italic()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
    
    private func emptyCard() -> some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(hex: "32324C").opacity(0.5),
                    Color(hex: "1A1A2E").opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Dashed border effect
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                )
                .foregroundColor(Color.white.opacity(0.2))
            
            // Empty slot content
            VStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(Color.white.opacity(0.3))
                
                Text("Empty Slot")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.4))
                
                Text("Slot \(slotNumber)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.2))
            }
        }
    }
    
    private func heroBackground(slug: String) -> some View {
        Image(uiImage: HeroRegistry.shared.heroImage(slug: slug))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func defaultBackground() -> some View {
        LinearGradient(
            colors: [
                Color(hex: "3D3D5C"),
                Color(hex: "32324C"),
                Color(hex: "1A1A2E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderColor: Color {
        if isCurrentUser {
            return Color(hex: "FFD700") // Gold for current user
        } else if member != nil {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }
}

// MARK: - Preview

struct PartyMemberCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Occupied slot with hero
            PartyMemberCard(
                member: PartyMember(
                    username: "PlayerOne",
                    selectedHero: "iron-man",
                    isLeader: true
                ),
                slotNumber: 1,
                isCurrentUser: true
            ) {}
            
            // Occupied slot without hero
            PartyMemberCard(
                member: PartyMember(
                    username: "PlayerTwo",
                    selectedHero: nil,
                    isLeader: false
                ),
                slotNumber: 2,
                isCurrentUser: false
            ) {}
            
            // Empty slot
            PartyMemberCard(
                member: nil,
                slotNumber: 3,
                isCurrentUser: false
            ) {}
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
