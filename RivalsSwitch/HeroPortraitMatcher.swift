//
//  HeroPortraitMatcher.swift
//  RivalsSwitch
//
//  Vision feature-print matching: compare scoreboard portrait crops to bundled reference avatars.
//

import Foundation
import UIKit
import Vision

/// Result for one enemy column slot (top → bottom).
struct PortraitSlotMatch {
    let heroName: String?
    /// Lower is more similar; nil if no print was produced.
    let bestDistance: Float?
}

final class HeroPortraitMatcher {
    
    static let shared = HeroPortraitMatcher()
    
    private let buildQueue = DispatchQueue(label: "com.rivalsswitch.portraitmatcher.build", qos: .userInitiated)
    private var referencePrints: [String: [VNFeaturePrintObservation]] = [:]
    private var didBuildReferences = false
    
    private static let scoreboardRefSubdirectory = "ScoreboardPortraitRefs"
    
    /// Feature-print distance threshold (lower = more similar).
    /// Tuned empirically using `debugRunCalibrationOnBundledSamples()`.
    private let maxDistanceToAccept: Float = 1.05
    
    /// Require a clear winner: if #1 and #2 are too close, leave the slot blank.
    private let minDistanceSeparationToAccept: Float = 0.02
    
    /// If the best match is *very* close, accept even if #2 is nearby.
    private let strongMatchDistanceToAccept: Float = 0.80
    
    private init() {}
    
    // MARK: - Public
    
    /// After OCR has filled enemy slots, fills only **empty** slots from portrait matching (never replaces OCR text).
    /// Performs Vision work on the current queue; updates `MatchStore` and calls `completion` on the main queue.
    func refineEnemyTeamWithPortraits(in image: UIImage, completion: @escaping () -> Void) {
        let slots = matchEnemyColumn(in: image)
        let ocr = [
            MatchStore.shared.enemy1, MatchStore.shared.enemy2, MatchStore.shared.enemy3,
            MatchStore.shared.enemy4, MatchStore.shared.enemy5, MatchStore.shared.enemy6
        ]
        var merged: [String] = []
        for (i, s) in slots.enumerated() {
            let distStr = s.bestDistance.map { String(format: "%.2f", $0) } ?? "—"
            let ocrSlot = (i < ocr.count ? ocr[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
            let cv = s.heroName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let cvDist = s.bestDistance
            
            let best = cvDist ?? .greatestFiniteMagnitude
            
            let picked: String
            if ocrSlot.isEmpty, !cv.isEmpty, best <= maxDistanceToAccept {
                picked = cv
            } else {
                picked = ocrSlot
            }
            merged.append(picked)
            print("Portrait CV slot \(i + 1): \(s.heroName ?? "nil")  bestDist=\(distStr)  OCR=\"\(ocrSlot)\" -> using \"\(picked)\"")
        }
        merged = MatchStore.dedupeEnemyHeroSlotsPreservingOrder(merged)
        let cvCount = zip(slots, ocr).filter { slot, ocrText in
            ocrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && slot.heroName != nil
        }.count
        DispatchQueue.main.async {
            self.saveEnemyTeam(merged)
            print("Portrait CV: merged \(cvCount)/6 slots from vision; final enemy team (deduped) ->", merged)
            completion()
        }
    }
    
    /// Debug helper: run portrait matching against bundled sample scoreboards and print a scored report.
    /// Call from anywhere (e.g. after a scan) to tune crop constants and thresholds.
    func debugRunCalibrationOnBundledSamples() {
        struct Sample {
            let filename: String
            let ext: String
            let expectedTopDown: [String] // 6 entries
        }
        
        let samples: [Sample] = [
            Sample(
                filename: "scoreboard-sample-1",
                ext: "jpeg",
                expectedTopDown: ["Hulk", "Venom", "Spider-Man", "Winter Soldier", "Invisible Woman", "Deadpool"]
            ),
            Sample(
                filename: "scoreboard-sample-2",
                ext: "jpg",
                expectedTopDown: ["Groot", "Magneto", "Scarlet Witch", "Iron Fist", "Loki", "Luna Snow"]
            ),
            Sample(
                filename: "scoreboard-sample-3",
                ext: "webp",
                expectedTopDown: ["Moon Knight", "Winter Soldier", "Star-Lord", "Luna Snow", "Jeff the Land Shark", "Invisible Woman"]
            ),
            Sample(
                filename: "scoreboard-sample-4",
                ext: "webp",
                expectedTopDown: ["Magneto", "Thor", "Scarlet Witch", "Psylocke", "Mantis", "Invisible Woman"]
            ),
        ]
        
        func loadImage(_ s: Sample) -> UIImage? {
            let sub = "MarvelRivals-scoreboards"
            if let url = Bundle.main.url(forResource: s.filename, withExtension: s.ext, subdirectory: sub),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                return img
            }
            // Flattened bundle fallback.
            if let url = Bundle.main.url(forResource: s.filename, withExtension: s.ext, subdirectory: nil),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                return img
            }
            return nil
        }
        
        print("=== Portrait calibration report ===")
        for s in samples {
            guard let img = loadImage(s) else {
                print("[\(s.filename).\(s.ext)] MISSING from app bundle")
                continue
            }
            let slots = debugMatchEnemyColumnWithDiagnostics(in: img)
            var correct = 0
            for i in 0..<6 {
                let exp = s.expectedTopDown[i]
                let got = slots[i].name ?? "—"
                if got.caseInsensitiveCompare(exp) == .orderedSame {
                    correct += 1
                }
                let d1 = slots[i].best.map { String(format: "%.2f", $0) } ?? "—"
                let d2 = slots[i].secondBest.map { String(format: "%.2f", $0) } ?? "—"
                let sep: String
                if let b = slots[i].best, let s2 = slots[i].secondBest {
                    sep = String(format: "%.2f", (s2 - b))
                } else {
                    sep = "—"
                }
                print("[\(s.filename)] slot \(i + 1): exp=\(exp) got=\(got)  d1=\(d1) d2=\(d2) sep=\(sep)")
            }
            print("[\(s.filename)] correct \(correct)/6")
        }
        print("=== End calibration report ===")
    }

    /// Prefer row-anchored crops (more accurate on cropped/zoomed screenshots), fall back to the fixed column rects.
    func refineEnemyTeamWithPortraits(in image: UIImage, enemyRowFrames: [CGRect], completion: @escaping () -> Void) {
        let slots: [PortraitSlotMatch]
        if enemyRowFrames.count >= 6 {
            slots = matchEnemyColumn(in: image, enemyRowFrames: enemyRowFrames)
        } else {
            slots = matchEnemyColumn(in: image)
        }
        let ocr = [
            MatchStore.shared.enemy1, MatchStore.shared.enemy2, MatchStore.shared.enemy3,
            MatchStore.shared.enemy4, MatchStore.shared.enemy5, MatchStore.shared.enemy6
        ]
        var merged: [String] = []
        for (i, s) in slots.enumerated() {
            let distStr = s.bestDistance.map { String(format: "%.2f", $0) } ?? "—"
            let ocrSlot = (i < ocr.count ? ocr[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
            let picked: String
            if ocrSlot.isEmpty, let cv = s.heroName, !cv.isEmpty {
                picked = cv
            } else {
                picked = ocrSlot
            }
            merged.append(picked)
            print("Portrait CV(slot,row-anchored) \(i + 1): \(s.heroName ?? "nil")  bestDist=\(distStr)  OCR=\"\(ocrSlot)\" -> using \"\(picked)\"")
        }
        merged = MatchStore.dedupeEnemyHeroSlotsPreservingOrder(merged)
        let cvCount = zip(slots, ocr).filter { slot, ocrText in
            ocrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && slot.heroName != nil
        }.count
        DispatchQueue.main.async {
            self.saveEnemyTeam(merged)
            print("Portrait CV: merged \(cvCount)/6 slots from vision; final enemy team (deduped) ->", merged)
            completion()
        }
    }
    
    /// Six slots from top of enemy column to bottom (Vision normalized coords).
    func matchEnemyColumn(in image: UIImage) -> [PortraitSlotMatch] {
        buildReferencesIfNeeded()
        guard let (cgImage, imageSize) = uprightPixelCGImage(from: image) else {
            return (0..<6).map { _ in PortraitSlotMatch(heroName: nil, bestDistance: nil) }
        }
        var results: [PortraitSlotMatch] = []
        
        for slotRect in enemySlotNormalizedRects() {
            let candidates = candidateRects(forEnemySlot: slotRect)
            var bestName: String?
            var bestDist: Float?
            for r in candidates {
                guard let crop = cropCGImage(cgImage, visionNormalizedRect: r, imageSize: imageSize) else { continue }
                guard let printObs = featurePrint(for: crop) else { continue }
                let (name, dist) = bestMatchingHero(for: printObs)
                guard let d = dist else { continue }
                if bestDist == nil || d < bestDist! {
                    bestDist = d
                    bestName = name
                }
            }
            results.append(PortraitSlotMatch(heroName: bestName, bestDistance: bestDist))
        }
        
        return results
    }
    
    private struct DiagnosticSlot {
        let name: String?
        let best: Float?
        let secondBest: Float?
    }
    
    private func debugMatchEnemyColumnWithDiagnostics(in image: UIImage) -> [DiagnosticSlot] {
        buildReferencesIfNeeded()
        guard let (cgImage, imageSize) = uprightPixelCGImage(from: image) else {
            return (0..<6).map { _ in DiagnosticSlot(name: nil, best: nil, secondBest: nil) }
        }
        var out: [DiagnosticSlot] = []
        for slotRect in enemySlotNormalizedRects() {
            let candidates = candidateRects(forEnemySlot: slotRect)
            var bestName: String?
            var bestDist: Float?
            var bestSecond: Float?
            for r in candidates {
                guard let crop = cropCGImage(cgImage, visionNormalizedRect: r, imageSize: imageSize) else { continue }
                guard let printObs = featurePrint(for: crop) else { continue }
                let (name, best, second) = bestTwoMatches(for: printObs)
                guard let b = best else { continue }
                if bestDist == nil || b < bestDist! {
                    bestDist = b
                    bestName = name
                    bestSecond = second
                }
            }
            out.append(DiagnosticSlot(name: bestName, best: bestDist, secondBest: bestSecond))
        }
        if out.count < 6 {
            out.append(contentsOf: repeatElement(DiagnosticSlot(name: nil, best: nil, secondBest: nil), count: 6 - out.count))
        }
        return out
    }
    
    /// Enemy slots derived from OCR row frames: crop the portrait tile immediately left of the row’s text cluster.
    func matchEnemyColumn(in image: UIImage, enemyRowFrames: [CGRect]) -> [PortraitSlotMatch] {
        buildReferencesIfNeeded()
        guard let (cgImage, imageSize) = uprightPixelCGImage(from: image) else {
            return (0..<6).map { _ in PortraitSlotMatch(heroName: nil, bestDistance: nil) }
        }
        let frames = Array(enemyRowFrames.prefix(6))
        var results: [PortraitSlotMatch] = []
        for frame in frames {
            let slot = enemyPortraitRect(fromRowFrame: frame)
            let candidates = candidateRects(forEnemySlot: slot)
            var bestName: String?
            var bestDist: Float?
            for r in candidates {
                guard let crop = cropCGImage(cgImage, visionNormalizedRect: r, imageSize: imageSize) else { continue }
                guard let printObs = featurePrint(for: crop) else { continue }
                let (name, dist) = bestMatchingHero(for: printObs)
                guard let d = dist else { continue }
                if bestDist == nil || d < bestDist! {
                    bestDist = d
                    bestName = name
                }
            }
            results.append(PortraitSlotMatch(heroName: bestName, bestDistance: bestDist))
        }
        if results.count < 6 {
            results.append(contentsOf: repeatElement(PortraitSlotMatch(heroName: nil, bestDistance: nil), count: 6 - results.count))
        }
        return results
    }
    
    // MARK: - Reference building
    
    private func buildReferencesIfNeeded() {
        if didBuildReferences { return }
        buildQueue.sync {
            guard !self.didBuildReferences else { return }
            self.loadReferenceImagesFromBundle()
            self.didBuildReferences = true
        }
    }
    
    private func loadReferenceImagesFromBundle() {
        referencePrints.removeAll()
        let exts = Set(["png", "webp", "jpg", "jpeg"])
        
        // 1) Prefer scoreboard-cropped reference portraits (best domain match).
        var didLoadScoreboardRefs = false
        for ext in ["png", "jpg", "jpeg"] {
            let refs = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: Self.scoreboardRefSubdirectory) ?? []
            guard !refs.isEmpty else { continue }
            didLoadScoreboardRefs = true
            for url in refs {
                let stem = url.deletingPathExtension().lastPathComponent
                guard let slug = slugFromScoreboardRefStem(stem),
                      let hero = HeroRegistry.shared.hero(slug: slug) else { continue }
                guard let data = try? Data(contentsOf: url),
                      let uiImage = UIImage(data: data),
                      let cg = normalizedPortraitCGImage(from: uiImage) else { continue }
                guard let fp = featurePrint(for: cg) else { continue }
                referencePrints[hero.name, default: []].append(fp)
            }
        }
        
        // 2) Fallback: wiki icons (weak domain match, but better than nothing).
        if !didLoadScoreboardRefs {
            var urls: [URL] = []
            if let u = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "MarvalRivals-icons") {
                urls.append(contentsOf: u)
            }
            if urls.isEmpty {
                for ext in exts {
                    urls.append(contentsOf: Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [])
                }
            }
            for url in urls where exts.contains(url.pathExtension.lowercased()) {
                let stem = url.deletingPathExtension().lastPathComponent
                guard let slug = HeroRegistry.shared.slugForBundledIconStem(stem),
                      let hero = HeroRegistry.shared.hero(slug: slug) else { continue }
                guard let data = try? Data(contentsOf: url),
                      let uiImage = UIImage(data: data),
                      let cg = normalizedPortraitCGImage(from: uiImage) else { continue }
                guard let fp = featurePrint(for: cg) else { continue }
                referencePrints[hero.name, default: []].append(fp)
            }
        }
        
        print("Portrait matcher: loaded \(referencePrints.values.reduce(0) { $0 + $1.count }) reference prints for \(referencePrints.count) heroes (scoreboardRefs=\(didLoadScoreboardRefs))")
    }
    
    /// Filename convention for scoreboard portrait refs:
    /// - Use slug anywhere in the filename, optionally with a numeric suffix.
    /// Examples: `magneto-1.png`, `enemy_magneto.png`, `ref-invisible-woman-2.jpg`
    private func slugFromScoreboardRefStem(_ stem: String) -> String? {
        let s = stem.lowercased()
        var best: String?
        var bestLen = 0
        for hero in HeroRegistry.shared.allHeroes {
            let slug = hero.slug.lowercased()
            if s.contains(slug), slug.count > bestLen {
                best = hero.slug
                bestLen = slug.count
            }
        }
        return best
    }
    
    // MARK: - Geometry (enemy column heuristics)
    
    /// Vision-style normalized rects (origin bottom-left, y up), one per enemy portrait slot top→bottom.
    /// Tuned for full-screen / ultrawide scoreboards: enemy column is the right panel; icons sit just right of center.
    private func enemySlotNormalizedRects() -> [CGRect] {
        // Calibrated against real screenshots in `MarvelRivals-scoreboards/`.
        // Goal: crop just the portrait tile (avoid username / rank badges).
        let portraitWidth: CGFloat = 0.070
        let originX: CGFloat = 0.476
        let topY: CGFloat = 0.80
        let bottomY: CGFloat = 0.30
        let count = 6
        let h = (topY - bottomY) / CGFloat(count)
        return (0..<count).map { i in
            let yBottom = topY - CGFloat(i + 1) * h
            // Slightly square-ish crop on the portrait tile (role icon sits to the left of this region).
            return CGRect(x: originX, y: yBottom + h * 0.08, width: portraitWidth, height: h * 0.80)
        }
    }
    
    /// Renders `image` upright in pixel space so crops align with Vision-style normalized rects.
    private func uprightPixelCGImage(from image: UIImage) -> (CGImage, CGSize)? {
        let w = image.size.width * image.scale
        let h = image.size.height * image.scale
        guard w >= 8, h >= 8 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        }
        guard let cg = rendered.cgImage else { return nil }
        return (cg, CGSize(width: cg.width, height: cg.height))
    }
    
    private func cropCGImage(_ cgImage: CGImage, visionNormalizedRect rect: CGRect, imageSize: CGSize) -> CGImage? {
        let w = imageSize.width
        let h = imageSize.height
        let px = CGRect(
            x: rect.minX * w,
            y: (1.0 - rect.maxY) * h,
            width: rect.width * w,
            height: rect.height * h
        ).integral
        guard px.width >= 8, px.height >= 8 else { return nil }
        return cgImage.cropping(to: px)
    }

    /// Multiple crops help when overlays/tags shift the visible portrait.
    private func candidateRects(forEnemySlot base: CGRect) -> [CGRect] {
        func clamp01(_ x: CGFloat) -> CGFloat { min(1, max(0, x)) }
        func clampRect(_ r: CGRect) -> CGRect {
            let x = clamp01(r.minX)
            let y = clamp01(r.minY)
            let maxX = clamp01(r.maxX)
            let maxY = clamp01(r.maxY)
            return CGRect(x: x, y: y, width: max(0, maxX - x), height: max(0, maxY - y))
        }
        func inset(_ r: CGRect, dx: CGFloat, dy: CGFloat) -> CGRect { clampRect(r.insetBy(dx: dx, dy: dy)) }
        func shift(_ r: CGRect, dx: CGFloat, dy: CGFloat) -> CGRect { clampRect(r.offsetBy(dx: dx, dy: dy)) }
        
        // Start with base, then try a few insets (remove borders / tags) and small vertical shifts.
        let s = base
        let in1 = inset(s, dx: s.width * 0.05, dy: s.height * 0.05)
        let in2 = inset(s, dx: s.width * 0.10, dy: s.height * 0.10)
        let up = shift(in1, dx: 0, dy: s.height * 0.04)
        let down = shift(in1, dx: 0, dy: -s.height * 0.04)
        let left = shift(in1, dx: -s.width * 0.03, dy: 0)
        let right = shift(in1, dx: s.width * 0.03, dy: 0)
        return [s, in1, in2, up, down, left, right].filter { $0.width > 0.01 && $0.height > 0.01 }
    }

    /// Scoreboard layout: portrait tile sits immediately left of the row’s username/text cluster.
    private func enemyPortraitRect(fromRowFrame row: CGRect) -> CGRect {
        let h = row.height
        let size = min(max(h * 1.05, 0.05), 0.16)
        let gap = h * 0.20
        let x = row.minX - gap - size
        let y = row.midY - size / 2
        let r = CGRect(x: x, y: y, width: size, height: size)
        // Clamp to normalized space.
        let clampedX = min(1, max(0, r.minX))
        let clampedY = min(1, max(0, r.minY))
        let clampedMaxX = min(1, max(0, r.maxX))
        let clampedMaxY = min(1, max(0, r.maxY))
        return CGRect(x: clampedX, y: clampedY, width: max(0, clampedMaxX - clampedX), height: max(0, clampedMaxY - clampedY))
    }
    
    /// Resize to a stable size for feature extraction.
    private func normalizedPortraitCGImage(from image: UIImage) -> CGImage? {
        let target: CGFloat = 160
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target), format: format)
        let out = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: target, height: target))
        }
        return out.cgImage
    }
    
    // MARK: - Vision
    
    private func featurePrint(for cgImage: CGImage) -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            return nil
        }
    }
    
    /// Best hero = minimum distance across that hero’s reference prints (fair vs multiple bundle assets).
    private func bestMatchingHero(for observation: VNFeaturePrintObservation) -> (String?, Float?) {
        var perHeroBest: [String: Float] = [:]
        for (heroName, prints) in referencePrints {
            var minD: Float = .greatestFiniteMagnitude
            for ref in prints {
                var d: Float = 0
                do {
                    try observation.computeDistance(&d, to: ref)
                    minD = min(minD, d)
                } catch {
                    continue
                }
            }
            if minD < .greatestFiniteMagnitude {
                perHeroBest[heroName] = minD
            }
        }
        guard let top = perHeroBest.min(by: { $0.value < $1.value }) else { return (nil, nil) }
        let best = top.value
        if best > maxDistanceToAccept {
            return (nil, best)
        }
        let secondBest = perHeroBest
            .filter { $0.key != top.key }
            .min(by: { $0.value < $1.value })?
            .value
        if let second = secondBest {
            let sep = second - best
            if best <= strongMatchDistanceToAccept {
                // Strong match: still require *some* separation so we don't accept near-ties.
                if sep < 0.01 { return (nil, best) }
                return (top.key, best)
            }
            // For weaker matches, require a bigger margin to avoid palette collisions (e.g. Venom vs others).
            let requiredSep: Float
            if best <= 0.90 {
                requiredSep = 0.02
            } else if best <= 1.00 {
                requiredSep = 0.05
            } else {
                requiredSep = max(minDistanceSeparationToAccept, 0.08)
            }
            if sep < requiredSep {
                return (nil, best)
            }
        }
        return (top.key, best)
    }
    
    /// Debug + acceptance support: return best hero plus best/second-best distances.
    private func bestTwoMatches(for observation: VNFeaturePrintObservation) -> (String?, Float?, Float?) {
        var perHeroBest: [String: Float] = [:]
        for (heroName, prints) in referencePrints {
            var minD: Float = .greatestFiniteMagnitude
            for ref in prints {
                var d: Float = 0
                do {
                    try observation.computeDistance(&d, to: ref)
                    minD = min(minD, d)
                } catch {
                    continue
                }
            }
            if minD < .greatestFiniteMagnitude {
                perHeroBest[heroName] = minD
            }
        }
        guard let top = perHeroBest.min(by: { $0.value < $1.value }) else { return (nil, nil, nil) }
        let second = perHeroBest
            .filter { $0.key != top.key }
            .min(by: { $0.value < $1.value })?
            .value
        return (top.key, top.value, second)
    }
    
    private func saveEnemyTeam(_ heroes: [String]) {
        let padded = heroes + Array(repeating: "", count: max(0, 6 - heroes.count))
        let six = Array(padded.prefix(6))
        MatchStore.shared.enemy1 = six[0]
        MatchStore.shared.enemy2 = six[1]
        MatchStore.shared.enemy3 = six[2]
        MatchStore.shared.enemy4 = six[3]
        MatchStore.shared.enemy5 = six[4]
        MatchStore.shared.enemy6 = six[5]
    }
}
