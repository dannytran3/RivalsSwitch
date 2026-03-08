//
//  Match.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 3/6/26.
//

import Foundation

struct Match: Codable {
    var date: Date
    var hero: String
    var kills: Int
    var deaths: Int
    var assists: Int
    var recommendedHero: String
    var recommendationReason: String
}
