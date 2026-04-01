//
//  HeroImageView.swift
//  RivalsSwitch
//
//  Reusable SwiftUI component for loading hero images from remote URLs
//

import SwiftUI

struct HeroImageView: View {
    let slug: String
    let contentMode: ContentMode
    
    init(slug: String, contentMode: ContentMode = .fill) {
        self.slug = slug
        self.contentMode = contentMode
    }
    
    var body: some View {
        if let imageURL = HeroRegistry.shared.heroImageURL(slug: slug),
           let hero = HeroRegistry.shared.hero(slug: slug) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    // Loading state
                    ZStack {
                        placeholderBackground(for: hero.role)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                case .success(let image):
                    // Successfully loaded image
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                    
                case .failure:
                    // Failed to load - show placeholder
                    placeholderView(for: hero.role)
                    
                @unknown default:
                    // Fallback for future cases
                    placeholderView(for: hero.role)
                }
            }
        } else {
            // No hero found - show generic placeholder
            placeholderView(for: .duelist)
        }
    }
    
    // Placeholder view with role-based icon
    private func placeholderView(for role: HeroData.HeroRole) -> some View {
        ZStack {
            placeholderBackground(for: role)
            
            Image(systemName: iconName(for: role))
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    // Background gradient for placeholder
    private func placeholderBackground(for role: HeroData.HeroRole) -> some View {
        LinearGradient(
            colors: [
                HeroRegistry.shared.roleColorSwiftUI(role: role).opacity(0.3),
                HeroRegistry.shared.roleColorSwiftUI(role: role).opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Icon name for role
    private func iconName(for role: HeroData.HeroRole) -> String {
        switch role {
        case .vanguard:
            return "shield.fill"
        case .duelist:
            return "burst.fill"
        case .strategist:
            return "cross.circle.fill"
        }
    }
}

// MARK: - Preview

struct HeroImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Example with Spider-Man
            HeroImageView(slug: "spider-man")
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Example with Jeff
            HeroImageView(slug: "jeff")
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Example with aspect fit
            HeroImageView(slug: "iron-man", contentMode: .fit)
                .frame(width: 200, height: 200)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(hex: "1A1A2E"))
        .preferredColorScheme(.dark)
    }
}
