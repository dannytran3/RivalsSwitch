//
//  HeroSynergyMap.swift
//  RivalsSwitch
//
//  Created by Carlos Olvera on 4/12/26.
//

import Foundation

struct HeroSynergyMap {
    
    // For each hero, list the teammates that usually pair well with them.
    // This is app-owned logic for RivalsSwitch, so you can tune it over time.
    static let synergyMap: [String: [String]] = [
        
        // Works With : - Vanguards
        "Captain America": ["Mantis", "Luna Snow", "Rocket Raccoon", "Storm"],
        "Doctor Strange": ["Mantis", "Luna Snow", "The Punisher", "Hela"],
        "Emma Frost": ["Loki", "Mantis", "Scarlet Witch", "Psylocke"],
        "Groot": ["Rocket Raccoon", "The Punisher", "Hela", "Mantis"],
        "Hulk": ["Mantis", "Luna Snow", "Iron Man", "Storm"],
        "Magneto": ["Scarlet Witch", "Mantis", "Luna Snow", "Hela"],
        "Peni Parker": ["Rocket Raccoon", "The Punisher", "Mantis", "Namor"],
        "The Thing": ["Mantis", "Luna Snow", "Storm", "Human Torch"],
        "Thor": ["Storm", "Mantis", "Luna Snow", "Hela"],
        "Venom": ["Spider-Man", "Mantis", "Luna Snow", "Psylocke"],
        
        // Works With: - Duelists
        "Angela": ["Mantis", "Luna Snow", "Captain America", "Doctor Strange"],
        "Black Panther": ["Mantis", "Luna Snow", "Hulk", "Thor"],
        "Black Widow": ["Rocket Raccoon", "Groot", "Doctor Strange", "Invisible Woman"],
        "Blade": ["Mantis", "Luna Snow", "Captain America", "Cloak & Dagger"],
        "Daredevil": ["Mantis", "Luna Snow", "Venom", "Captain America"],
        "Deadpool": ["Jeff the Land Shark", "Mantis", "Luna Snow", "Venom"],
        "Elsa Bloodstone": ["Rocket Raccoon", "Groot", "Doctor Strange", "Mantis"],
        "Gambit": ["Mantis", "Luna Snow", "Doctor Strange", "Magneto"],
        "Hawkeye": ["Rocket Raccoon", "Groot", "Doctor Strange", "Invisible Woman"],
        "Hela": ["Loki", "Mantis", "Doctor Strange", "Thor"],
        "Human Torch": ["Invisible Woman", "Mantis", "Doctor Strange", "The Thing"],
        "Iron Fist": ["Mantis", "Luna Snow", "Hulk", "Captain America"],
        "Iron Man": ["Hulk", "Mantis", "Luna Snow", "Doctor Strange"],
        "Magik": ["Mantis", "Luna Snow", "Doctor Strange", "Thor"],
        "Mister Fantastic": ["Invisible Woman", "Rocket Raccoon", "Mantis", "The Thing"],
        "Moon Knight": ["Mantis", "Luna Snow", "Doctor Strange", "Loki"],
        "Namor": ["Luna Snow", "Mantis", "Doctor Strange", "Storm"],
        "Phoenix": ["Magneto", "Mantis", "Luna Snow", "Doctor Strange"],
        "Psylocke": ["Mantis", "Luna Snow", "Emma Frost", "Venom"],
        "Rogue": ["Mantis", "Luna Snow", "Captain America", "Storm"],
        "Scarlet Witch": ["Magneto", "Loki", "Mantis", "Doctor Strange"],
        "Spider-Man": ["Venom", "Mantis", "Luna Snow", "Doctor Strange"],
        "Squirrel Girl": ["Rocket Raccoon", "Groot", "Mantis", "Doctor Strange"],
        "Star-Lord": ["Rocket Raccoon", "Mantis", "Luna Snow", "Groot"],
        "Storm": ["Thor", "Mantis", "Doctor Strange", "Hulk"],
        "The Punisher": ["Rocket Raccoon", "Groot", "Mantis", "Doctor Strange"],
        "Winter Soldier": ["Rocket Raccoon", "Mantis", "Luna Snow", "Captain America"],
        "Wolverine": ["Hulk", "Mantis", "Luna Snow", "Captain America"],
        
        // Works With: - Strategists
        "Adam Warlock": ["Doctor Strange", "Magneto", "Hela", "Iron Man"],
        "Cloak & Dagger": ["Captain America", "Thor", "Blade", "Black Panther"],
        "Invisible Woman": ["Doctor Strange", "Human Torch", "Mister Fantastic", "Hawkeye"],
        "Jeff the Land Shark": ["Deadpool", "Venom", "Thor", "Captain America"],
        "Loki": ["Hela", "Scarlet Witch", "Emma Frost", "Doctor Strange"],
        "Luna Snow": ["Hulk", "Thor", "Black Panther", "Spider-Man"],
        "Mantis": ["Hulk", "Thor", "Black Panther", "Magneto"],
        "Rocket Raccoon": ["Groot", "The Punisher", "Star-Lord", "Mister Fantastic"],
        "Ultron": ["Doctor Strange", "Magneto", "The Punisher", "Hela"],
        "White Fox": ["Psylocke", "Spider-Man", "Black Panther", "Doctor Strange"]
    ]
}
