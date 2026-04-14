import Foundation

/// One row in match history: when it was saved plus the same summary string used for thumbnails and detail.
struct SavedMatch: Codable, Equatable {
    let id: String
    let savedAt: Date
    let summary: String

    /// Parsed from `saveCurrentMatch()` summary lines: hero + KDA, enemies, top swap.
    struct ParsedSummary: Equatable {
        let playingHero: String
        let kdaLine: String
        let enemies: String
        let topSwap: String
    }

    func parsedSummary() -> ParsedSummary {
        let lines = summary.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let first = lines.first ?? "—"
        let (hero, kda): (String, String)
        if let r = first.range(of: " | ") {
            hero = String(first[..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
            kda = String(first[r.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
            hero = first
            kda = ""
        }

        var enemies = "—"
        if lines.count > 1 {
            let line = lines[1]
            if line.lowercased().hasPrefix("enemies:") {
                enemies = String(line.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            } else {
                enemies = line
            }
        }

        var topSwap = "—"
        if lines.count > 2 {
            let line = lines[2]
            if line.lowercased().hasPrefix("top swap:") {
                topSwap = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            } else {
                topSwap = line
            }
        }

        return ParsedSummary(
            playingHero: hero.isEmpty ? "—" : hero,
            kdaLine: kda.isEmpty ? "—" : kda,
            enemies: enemies,
            topSwap: topSwap
        )
    }
}

// Central store used to temporarily hold match data
// while the user moves through the scanning flow
class MatchStore {
    // Shared singleton instance used across the app
    static let shared = MatchStore()
    private init() {}

    /// Rivals allows each hero at most once per team. Preserves top→bottom order; repeats become empty slots.
    static func dedupeEnemyHeroSlotsPreservingOrder(_ slots: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for raw in slots.prefix(6) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty {
                out.append("")
                continue
            }
            let key = t.lowercased()
            if seen.contains(key) {
                out.append("")
            } else {
                seen.insert(key)
                out.append(t)
            }
        }
        if out.count < 6 {
            out.append(contentsOf: repeatElement("", count: 6 - out.count))
        }
        return Array(out.prefix(6))
    }

    // Current player information
    var currentUsername: String = ""
    var currentHero: String = ""
    var currentKills: Int = 0
    var currentDeaths: Int = 0
    var currentAssists: Int = 0

    // Enemy team heroes detected from the scoreboard
    var enemy1: String = ""
    var enemy2: String = ""
    var enemy3: String = ""
    var enemy4: String = ""
    var enemy5: String = ""
    var enemy6: String = ""

    // Friendly team heroes detected from the scoreboard
    var team1: String = ""
    var team2: String = ""
    var team3: String = ""
    var team4: String = ""
    var team5: String = ""
    var team6: String = ""

    // Top recommendations returned from the recommendation engine
    var recommendedHero1: String = ""
    var recommendedReason1: String = ""

    var recommendedHero2: String = ""
    var recommendedReason2: String = ""

    var recommendedHero3: String = ""
    var recommendedReason3: String = ""

    /// Legacy: array of summary strings only (no dates).
    private let matchesKey = "savedMatches"
    /// Current: JSON-encoded `[SavedMatch]` with timestamps.
    private let matchesV2Key = "savedMatchesV2"

    // Clears all match data when starting a new match
    func clearCurrentMatch() {
        currentUsername = ""
        currentHero = ""
        currentKills = 0
        currentDeaths = 0
        currentAssists = 0

        enemy1 = ""
        enemy2 = ""
        enemy3 = ""
        enemy4 = ""
        enemy5 = ""
        enemy6 = ""

        recommendedHero1 = ""
        recommendedReason1 = ""
        recommendedHero2 = ""
        recommendedReason2 = ""
        recommendedHero3 = ""
        recommendedReason3 = ""

        team1 = ""
        team2 = ""
        team3 = ""
        team4 = ""
        team5 = ""
        team6 = ""
    }

    var friendlyTeam: [String] {
        [team1, team2, team3, team4, team5, team6].filter { !$0.isEmpty }
    }

    // Saves the current match summary into local storage
    func saveCurrentMatch() {
        // Combine enemy heroes into string
        let enemySummary = [enemy1, enemy2, enemy3, enemy4, enemy5, enemy6]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        // Build match summary text
        let topSwapDisplay = recommendedHero1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "—"
            : "👑 \(recommendedHero1)"
        let summary = "\(currentHero) | K:\(currentKills) D:\(currentDeaths) A:\(currentAssists)\nEnemies: \(enemySummary)\nTop swap: \(topSwapDisplay)"

        let newMatch = SavedMatch(
            id: UUID().uuidString,
            savedAt: Date(),
            summary: summary
        )

        var saved = loadSavedMatches()
        saved.insert(newMatch, at: 0)
        persistSavedMatches(saved)

        FirestoreService.shared.saveMatch(newMatch)
    }

    /// Full history rows (date + summary). Prefer this for the History tab.
    func loadSavedMatches() -> [SavedMatch] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let data = UserDefaults.standard.data(forKey: matchesV2Key),
           let decoded = try? decoder.decode([SavedMatch].self, from: data) {
            return decoded.sorted { $0.savedAt > $1.savedAt }
        }

        // One-time migration from string-only storage
        if let legacy = UserDefaults.standard.stringArray(forKey: matchesKey), !legacy.isEmpty {
            let base = Date()
            let migrated = legacy.enumerated().map { index, summary in
                SavedMatch(
                    id: UUID().uuidString,
                    savedAt: base.addingTimeInterval(-TimeInterval(index * 60)),
                    summary: summary
                )
            }
            persistSavedMatches(migrated)
            UserDefaults.standard.removeObject(forKey: matchesKey)
            return migrated
        }

        return []
    }

    func replaceSavedMatches(_ matches: [SavedMatch]) {
        persistSavedMatches(matches.sorted { $0.savedAt > $1.savedAt })
    }

    func deleteSavedMatch(at index: Int) {
        var saved = loadSavedMatches()
        guard saved.indices.contains(index) else { return }

        let removed = saved.remove(at: index)
        persistSavedMatches(saved)

        FirestoreService.shared.deleteMatch(matchID: removed.id)
    }

    private func persistSavedMatches(_ matches: [SavedMatch]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(matches) {
            UserDefaults.standard.set(data, forKey: matchesV2Key)
        }
    }

    /// Summary strings only, newest first — for Home, thumbnails, and legacy call sites.
    func loadMatches() -> [String] {
        loadSavedMatches().map(\.summary)
    }

    // MARK: - Profile aggregates (from saved history only)

    /// Averages K/D/A, share of matches with a top-swap recommendation, and latest match hero — all derived from stored summaries.
    func profileHistoryStatsForDisplay() -> (
        matchCount: Int,
        avgKDALine: String,
        swapPickPercentLine: String,
        lastHeroName: String,
        lastHeroSummary: String?
    ) {
        let saved = loadSavedMatches()
        let n = saved.count
        guard n > 0 else {
            return (0, "—", "—", "—", nil)
        }

        var sumK = 0
        var sumD = 0
        var sumA = 0
        var kdaParsed = 0
        var withSwapRec = 0

        for m in saved {
            let p = m.parsedSummary()
            if let (k, d, a) = Self.parseKDAFromSummaryLine(p.kdaLine) {
                sumK += k
                sumD += d
                sumA += a
                kdaParsed += 1
            }
            if Self.topSwapLineHasRecommendation(p.topSwap) {
                withSwapRec += 1
            }
        }

        let avgLine: String
        if kdaParsed > 0 {
            let ak = Double(sumK) / Double(kdaParsed)
            let ad = Double(sumD) / Double(kdaParsed)
            let aa = Double(sumA) / Double(kdaParsed)
            avgLine = String(format: "%.1f / %.1f / %.1f", ak, ad, aa)
        } else {
            avgLine = "—"
        }

        let pct = Int((100.0 * Double(withSwapRec) / Double(n)).rounded())
        let swapLine = "\(pct)%"
        let latest = saved[0]
        let lp = latest.parsedSummary()
        let name = lp.playingHero.trimmingCharacters(in: .whitespacesAndNewlines)

        let heroTitle = (name.isEmpty || name == "—") ? "—" : name
        return (n, avgLine, swapLine, heroTitle, latest.summary)
    }

    private static func parseKDAFromSummaryLine(_ line: String) -> (Int, Int, Int)? {
        func intAfter(_ prefix: String, in s: String) -> Int? {
            guard let r = s.range(of: prefix) else { return nil }
            var i = r.upperBound
            var digits = ""
            while i < s.endIndex, s[i].isNumber {
                digits.append(s[i])
                i = s.index(after: i)
            }
            return Int(digits)
        }

        let s = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let k = intAfter("K:", in: s),
              let d = intAfter("D:", in: s),
              let a = intAfter("A:", in: s) else { return nil }
        return (k, d, a)
    }

    private static func topSwapLineHasRecommendation(_ topSwap: String) -> Bool {
        let t = topSwap.replacingOccurrences(of: "👑", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty || t == "—" { return false }
        return true
    }
}
