//
//  Match.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import Foundation

// Data model representing a completed match
// This gets saved to history so users can review past games
struct Match: Codable {
    // Date the match was played
    var date: Date
    
    // Player statistics from the match
    var hero: String
    var kills: Int
    var deaths: Int
    var assists: Int
    
    // Player statistics from the match and explaination for reason of switch
    var recommendedHero: String
    var recommendationReason: String
}
