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
        ZStack {
            if let member = member {
                // Occupied slot - interactive
                Button(action: {
                    onTap()
                }) {
                    occupiedCard(member: member)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
                        .scaleEffect(isPressed ? 0.97 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            } else {
                // Empty slot - non-interactive
                emptyCard()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
                    .allowsHitTesting(false) // Empty slots don't capture touches
            }
        }
    }
    
    private func occupiedCard(member: PartyMember) -> some View {
        ZStack {
            // Hero background image
            if let heroSlug = member.selectedHero {
                heroBackground(slug: heroSlug)
            } else {
                defaultBackground()
            }
            
            // Premium dark gradient overlay for readability
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                // Bottom info section
                VStack(alignment: .leading, spacing: 6) {
                    // Username - gold for leader, white for others
                    Text(member.username)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(usernameColor(for: member))
                        .lineLimit(1)
                    
                    // Selected hero name
                    if let heroSlug = member.selectedHero,
                       let hero = HeroRegistry.shared.hero(slug: heroSlug) {
                        Text(hero.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                            .lineLimit(1)
                    } else {
                        Text("No hero selected")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))
                            .italic()
                    }
                    
                    // Current user indicator (subtle)
                    if isCurrentUser {
                        Text("YOU")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "FFD700"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FFD700").opacity(0.2))
                            )
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
    }
    
    private func emptyCard() -> some View {
        ZStack {
            // Subtle gradient background (lower visual weight)
            LinearGradient(
                colors: [
                    Color(hex: "2A2A4C").opacity(0.15),
                    Color(hex: "1A1A2E").opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Softer border
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
            
            // Empty slot content (more subtle)
            VStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color.white.opacity(0.2))
                
                Text("Empty")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.25))
            }
        }
    }
    
    private func heroBackground(slug: String) -> some View {
        HeroImageView(slug: slug, contentMode: .fill)
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
            return Color(hex: "FFD700").opacity(0.6) // Gold for current user
        } else if member != nil {
            return Color.white.opacity(0.15)
        } else {
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        if isCurrentUser {
            return 2
        } else if member != nil {
            return 1
        } else {
            return 0
        }
    }
    
    private var shadowColor: Color {
        if isCurrentUser {
            return Color(hex: "FFD700").opacity(0.3)
        } else if member != nil {
            return Color.black.opacity(0.4)
        } else {
            return Color.clear
        }
    }
    
    private var shadowRadius: CGFloat {
        if isCurrentUser {
            return 12
        } else if member != nil {
            return 8
        } else {
            return 0
        }
    }
    
    // Username color: gold for leader, white for others
    private func usernameColor(for member: PartyMember) -> Color {
        member.isLeader ? Color(hex: "FFD700") : Color.white
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
