//
//  InvitePlayerSheet.swift
//  RivalsSwitch
//
//  Sheet for inviting players to party
//

import SwiftUI

struct InvitePlayerSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var partyManager = PartyManager.shared
    @State private var username: String = ""
    @State private var isInviting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FFD700"))
                        
                        Text("Invite Player")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Enter a username to invite them to your party")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    
                    // Input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        TextField("Enter username", text: $username)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal)
                    
                    // Error message
                    if let error = partyManager.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Send invite button - Coming Soon
                        Button(action: {
                            sendInvite()
                        }) {
                            HStack {
                                Image(systemName: "clock.badge.exclamationmark")
                                Text("Coming Soon")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.5))
                            )
                            .foregroundColor(Color.white.opacity(0.7))
                        }
                        .disabled(true)
                        
                        // Cancel button
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func sendInvite() {
        // Show "Coming Soon" message instead of actually sending invite
        isPresented = false
        
        // You could add a toast/alert here if desired
        // For now, just close the sheet
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "32324C"))
            )
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Hero Selector Sheet

struct HeroSelectorSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var partyManager = PartyManager.shared
    @State private var selectedRole: HeroData.HeroRole? = nil
    @State private var isUpdating = false
    
    private let roles: [HeroData.HeroRole] = [.vanguard, .duelist, .strategist]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Role selector
                    roleSelector
                    
                    // Hero grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(filteredHeroes) { hero in
                                HeroSelectCard(hero: hero) {
                                    selectHero(hero)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Hero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(Color(hex: "FFD700"))
                }
            }
        }
    }
    
    private var roleSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All heroes option
                RoleFilterButton(
                    title: "All",
                    isSelected: selectedRole == nil
                ) {
                    selectedRole = nil
                }
                
                ForEach(roles, id: \.self) { role in
                    RoleFilterButton(
                        title: role.rawValue.capitalized,
                        isSelected: selectedRole == role
                    ) {
                        selectedRole = role
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "32324C").opacity(0.6))
    }
    
    private var filteredHeroes: [HeroData] {
        if let role = selectedRole {
            return HeroRegistry.shared.heroes(role: role)
        }
        return HeroRegistry.shared.allHeroes
    }
    
    private func selectHero(_ hero: HeroData) {
        isUpdating = true
        
        Task {
            await partyManager.updateMyHero(hero.slug)
            
            await MainActor.run {
                isUpdating = false
                isPresented = false
            }
        }
    }
}

// MARK: - Role Filter Button

struct RoleFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "FFD700") : Color.clear)
                )
                .foregroundColor(isSelected ? Color(hex: "1A1A2E") : .white)
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "FFD700"), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Hero Select Card

struct HeroSelectCard: View {
    let hero: HeroData
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HeroImageView(slug: hero.slug, contentMode: .fill)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)
            
            Text(hero.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(hero.role.rawValue.capitalized)
                .font(.caption2)
                .foregroundColor(roleColor(hero.role))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(roleColor(hero.role).opacity(0.2))
                )
            
            Button(action: action) {
                Text("Select")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "FFD700"))
                    )
                    .foregroundColor(Color(hex: "1A1A2E"))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "32324C").opacity(0.6))
        )
    }
    
    private func roleColor(_ role: HeroData.HeroRole) -> Color {
        switch role {
        case .vanguard:
            return Color.blue
        case .duelist:
            return Color.red
        case .strategist:
            return Color.green
        }
    }
}

// MARK: - Previews

struct InvitePlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        InvitePlayerSheet(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

struct HeroSelectorSheet_Previews: PreviewProvider {
    static var previews: some View {
        HeroSelectorSheet(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}
