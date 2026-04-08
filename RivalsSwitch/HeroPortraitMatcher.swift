//
//  HeroPortraitMatcher.swift
//  RivalsSwitch
//
//  Portrait matching:
//  - **Physical device:** Vision `VNGenerateImageFeaturePrint` when all reference prints build (best discrimination).
//  - **Simulator / fallback:** L² on unit RGB thumbnails (Espresso often unavailable in Simulator).
//

import Foundation
import UIKit
import Vision

final class HeroPortraitMatcher {
    
    static let shared = HeroPortraitMatcher()
    
    private let buildQueue = DispatchQueue(label: "com.rivalsswitch.portraitmatcher.build", qos: .userInitiated)
    /// Per-hero, per-asset unit vectors (L²-normalized RGB thumbnails). Same pipeline as live crops.
    private var referenceThumbVectors: [String: [[Float]]] = [:]
    /// Populated only on device when every bundled ref successfully produces a print (same keys as RGB).
    private var referenceFeaturePrints: [String: [VNFeaturePrintObservation]] = [:]
    private var didBuildReferences = false
    
    private var useFeaturePrintRanking: Bool { !referenceFeaturePrints.isEmpty }
    
    /// Thumbnail side in pixels (56×56×3 RGB). Slightly larger than 48 helps separate similar faces (e.g. Magneto vs Loki).
    private let thumbSide: Int = 56
    
    /// L² on unit RGB vectors — reject outright if no hero is closer than this (too ambiguous / wrong crop).
    /// Tuned to the raw-RGB embedding scale (~0.5–0.75 typical); do not pair with alternate preprocessings without retuning.
    private let maxDistanceToAccept: Float = 0.73
    
    /// Minimum gap between #1 and #2 when the best distance is in the “mid” range (not a strongMatch).
    private let minDistanceSeparationToAccept: Float = 0.012
    
    /// Best distance this low → accept even if #2 is somewhat close (very likely correct hero).
    private let strongMatchDistanceToAccept: Float = 0.38
    
    /// When best is between `strongMatch` and `maxDistance`, still accept if gap ≥ this (fills slots that were nil at 0.018).
    private let marginalGapToAccept: Float = 0.009
    
    /// Vision feature-print distance (scale unrelated to RGB L² — tuned empirically).
    private let maxFeaturePrintDistanceToAccept: Float = 14.0
    private let strongFeaturePrintDistance: Float = 5.0
    private let minFeaturePrintSeparation: Float = 0.6
    private let marginalFeaturePrintGap: Float = 0.25
    
    private let distanceEps: Float = 1e-5
    
    private init() {}
    
    // MARK: - Public

    /// Identify enemy team heroes via portrait matching.
    ///
    /// Enemy rows show **usernames**, not hero names — OCR cannot identify heroes from text on the enemy side.
    /// Instead we crop the portrait tile for each slot and compare to bundled references (Vision feature prints on device when available, else RGB).
    ///
    /// `friendlyRowMidYs` come from YOUR TEAM OCR rows. They share the same Y positions as enemy rows
    /// (same horizontal scoreboard rows), giving us reliable Y anchors regardless of screenshot size.
    /// `splitX` is the horizontal boundary between the two team columns.
    func refineEnemyTeamWithPortraits(
        in image: UIImage,
        friendlyRowMidYs: [CGFloat],
        splitX: CGFloat,
        completion: @escaping () -> Void
    ) {
        buildReferencesIfNeeded()

        guard let (cgImage, imageSize) = uprightPixelCGImage(from: image) else {
            DispatchQueue.main.async { completion() }
            return
        }

        let portraitRects = enemyPortraitRects(friendlyRowMidYs: friendlyRowMidYs, splitX: splitX, imageSize: imageSize)

        let ocr = [
            MatchStore.shared.enemy1, MatchStore.shared.enemy2, MatchStore.shared.enemy3,
            MatchStore.shared.enemy4, MatchStore.shared.enemy5, MatchStore.shared.enemy6
        ]

        var merged: [String] = []
        for (i, slotRect) in portraitRects.enumerated() {
            let ocrSlot = (i < ocr.count ? ocr[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)

            let candidates = candidateRects(forEnemySlot: slotRect)
            var bestName: String?
            var bestDist: Float?
            for r in candidates {
                guard let crop = cropCGImage(cgImage, visionNormalizedRect: r, imageSize: imageSize) else { continue }
                let (name, dist) = bestMatchForCrop(crop)
                guard let d = dist, let n = name else { continue }
                if bestDist == nil || d < bestDist! {
                    bestDist = d
                    bestName = n
                }
            }

            let picked: String
            if ocrSlot.isEmpty, let cv = bestName {
                picked = cv
            } else {
                picked = ocrSlot
            }
            merged.append(picked)
        }
        merged = MatchStore.dedupeEnemyHeroSlotsPreservingOrder(merged)
        DispatchQueue.main.async {
            self.saveEnemyTeam(merged)
            completion()
        }
    }

    // MARK: - Portrait rect geometry

    /// Compute the six enemy portrait rects from YOUR TEAM row midYs + the column split X.
    ///
    /// Layout insight:
    /// - The scoreboard has two symmetric columns. YOUR TEAM rows and ENEMY TEAM rows share identical Y positions.
    /// - The enemy portrait tile is the leftmost element in each enemy row, sitting just right of the column split.
    /// - Portrait tiles are square on screen; we crop a **pixel** square (see below).
    private func enemyPortraitRects(friendlyRowMidYs: [CGFloat], splitX: CGFloat, imageSize: CGSize) -> [CGRect] {
        func clamp(_ x: CGFloat) -> CGFloat { min(1, max(0, x)) }
        func clampRect(_ r: CGRect) -> CGRect {
            let x = clamp(r.minX), y = clamp(r.minY)
            return CGRect(x: x, y: y,
                          width: min(1 - x, max(0, r.width)),
                          height: min(1 - y, max(0, r.height)))
        }

        let W = imageSize.width
        let H = imageSize.height
        guard W >= 8, H >= 8 else { return [] }

        // ── Row spacing (gives portrait height) ──────────────────────────────────────
        // Use YOUR TEAM midYs; they're always at the same Y as enemy rows.
        var midYs = friendlyRowMidYs.sorted { $0 > $1 }  // descending = top first in Vision
        let n = midYs.count
        let rowSpacing: CGFloat
        if n >= 2 {
            rowSpacing = (midYs[0] - midYs[n - 1]) / CGFloat(n - 1)
        } else {
            rowSpacing = 0.066
        }
        // Vision rects use width and height as fractions of image width and height **independently**.
        // Using one number for both (old behavior) makes a 16:9 screenshot crop **wider** in pixels than
        // tall — not square — so adjacent row UI bleeds in horizontally. Fix: one edge length in pixels,
        // then different normalized width vs height so the crop is square in pixel space (matches square icons).
        let minDim = min(W, H)
        let sidePx = min(0.12 * minDim, max(0.038 * minDim, rowSpacing * H * 0.88))
        let normW = sidePx / W
        let normH = sidePx / H

        // ── Extrapolate to 6 rows if we have fewer ───────────────────────────────────
        while midYs.count < 6 {
            midYs.append((midYs.last ?? 0.45) - rowSpacing)
        }
        midYs = Array(midYs.prefix(6))

        // ── Enemy portrait X position ─────────────────────────────────────────────────
        // The enemy portrait is the leftmost item in the right column, sitting just past
        // the divider line (which is close to splitX).
        // Try multiple X positions so different screenshot crops/scales still land on the portrait.
        // We'll build a base rect for each; candidateRects() tries small shifts on top of this.
        let portraitX = splitX - normW * 0.25  // portrait straddles the split slightly

        return midYs.map { midY in
            clampRect(CGRect(x: portraitX,
                             y: midY - normH / 2,
                             width: normW,
                             height: normH))
        }
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
    
    /// File-system–synced groups often copy `App.app/MarvalRivals-icons-scoreboard/*.webp` while
    /// `Bundle.urls(forResourcesWithExtension:subdirectory:)` still returns nothing — read the directory directly.
    private func scoreboardIconFileURLs() -> [URL] {
        let exts = Set(["webp", "png", "jpg", "jpeg"])
        let folderNames = [
            "MarvalRivals-icons-scoreboard",
            "MarvelRivals-icons-scoreboard",
        ]
        var out: [URL] = []
        var seen = Set<String>()
        let fm = FileManager.default
        let bundleRoot = Bundle.main.bundleURL
        
        func appendUnique(_ u: URL) {
            let p = u.path
            guard seen.insert(p).inserted else { return }
            out.append(u)
        }
        
        for folder in folderNames {
            let dir = bundleRoot.appendingPathComponent(folder, isDirectory: true)
            guard fm.fileExists(atPath: dir.path) else { continue }
            guard let items = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { continue }
            for u in items {
                guard exts.contains(u.pathExtension.lowercased()) else { continue }
                appendUnique(u)
            }
        }
        
        for folder in folderNames {
            for ext in exts {
                for u in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: folder) ?? [] {
                    appendUnique(u)
                }
            }
        }
        
        // Flat bundle: copies without preserving folder (only names that look like scoreboard refs)
        if out.isEmpty, let flat = try? fm.contentsOfDirectory(at: bundleRoot, includingPropertiesForKeys: nil) {
            for u in flat {
                guard exts.contains(u.pathExtension.lowercased()) else { continue }
                let n = u.lastPathComponent.lowercased()
                guard n.contains("avatar") else { continue }
                appendUnique(u)
            }
        }
        
        return out
    }
    
    private func loadReferenceImagesFromBundle() {
        referenceThumbVectors.removeAll()
        referenceFeaturePrints.removeAll()
        #if !targetEnvironment(simulator)
        var fpAccumulator: [String: [VNFeaturePrintObservation]] = [:]
        var featurePrintBuildFailed = false
        #endif
        let exts = Set(["png", "webp", "jpg", "jpeg"])
        var urls: [URL] = []
        
        // Prefer a "scoreboard-framed" icon set if present (filenames contain slugs, e.g. `magneto_avatar.webp`).
        // Drop files into `RivalsSwitch/MarvalRivals-icons-scoreboard/`.
        let isUsingScoreboardIconSet: Bool
        let scoreboard = scoreboardIconFileURLs()
        if !scoreboard.isEmpty {
            urls.append(contentsOf: scoreboard)
            isUsingScoreboardIconSet = true
        } else if let u = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "MarvalRivals-icons") {
            urls.append(contentsOf: u)
            isUsingScoreboardIconSet = false
        } else {
            isUsingScoreboardIconSet = false
        }
        if urls.isEmpty {
            for ext in exts {
                urls.append(contentsOf: Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [])
            }
        }
        for url in urls where exts.contains(url.pathExtension.lowercased()) {
            let stem = url.deletingPathExtension().lastPathComponent
            let slug = isUsingScoreboardIconSet
                ? slugFromScoreboardRefStem(stem)
                : HeroRegistry.shared.slugForBundledIconStem(stem)
            guard let slug,
                  let hero = HeroRegistry.shared.hero(slug: slug) else { continue }
            guard let data = try? Data(contentsOf: url),
                  let uiImage = UIImage(data: data),
                  let cg = (isUsingScoreboardIconSet
                            ? resizedSquareCGImage(from: uiImage, target: 160)
                            : normalizedPortraitCGImage(from: uiImage)) else { continue }
            guard let vec = unitRGBVector(from: cg) else { continue }
            referenceThumbVectors[hero.name, default: []].append(vec)
            #if !targetEnvironment(simulator)
            if !featurePrintBuildFailed {
                if let fp = Self.makeFeaturePrintObservation(from: cg) {
                    fpAccumulator[hero.name, default: []].append(fp)
                } else {
                    featurePrintBuildFailed = true
                    fpAccumulator.removeAll()
                }
            }
            #endif
        }
        
        #if !targetEnvironment(simulator)
        if !featurePrintBuildFailed, !fpAccumulator.isEmpty {
            var perHeroMatch = true
            for (name, vecs) in referenceThumbVectors {
                guard let fps = fpAccumulator[name], fps.count == vecs.count else {
                    perHeroMatch = false
                    break
                }
            }
            if perHeroMatch, Set(fpAccumulator.keys) == Set(referenceThumbVectors.keys) {
                referenceFeaturePrints = fpAccumulator
            }
        }
        #endif
    }
    
    /// On Simulator this is never called for refs (see `loadReferenceImagesFromBundle`).
    private static func makeFeaturePrintObservation(from cgImage: CGImage) -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            return nil
        }
    }
    
    private func featurePrintObservation(from cgImage: CGImage) -> VNFeaturePrintObservation? {
        Self.makeFeaturePrintObservation(from: cgImage)
    }
    
    /// Scoreboard ref filenames: `magneto_avatar.webp`, `elsa_bloodstone_avatar.webp`, `jeff-the-land-shark_avatar.webp`, etc.
    private func slugFromScoreboardRefStem(_ stem: String) -> String? {
        var s = stem.lowercased()
        s = s.replacingOccurrences(of: "_", with: "-")
        if s.hasSuffix("-avatar") {
            s = String(s.dropLast("-avatar".count))
        }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if let h = HeroRegistry.shared.hero(slug: s) { return h.slug }
        // Longest slug contained in filename (handles odd OCR-style names).
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

    /// Reference-only normalization: wiki icons are “zoomed out” vs in-game portraits.
    /// We center-crop in on the reference so composition matches the scoreboard crop better.
    private func normalizedReferenceFeatureInputCGImage(from cgImage: CGImage) -> CGImage? {
        let target: CGFloat = 160
        let oversample: CGFloat = 256
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        // Aspect-fill into oversampled square.
        let baseRenderer = UIGraphicsImageRenderer(size: CGSize(width: oversample, height: oversample), format: format)
        let base = baseRenderer.image { _ in
            let iw = CGFloat(cgImage.width)
            let ih = CGFloat(cgImage.height)
            let scale = max(oversample / iw, oversample / ih)
            let dw = iw * scale
            let dh = ih * scale
            let dx = (oversample - dw) / 2
            let dy = (oversample - dh) / 2
            UIImage(cgImage: cgImage).draw(in: CGRect(x: dx, y: dy, width: dw, height: dh))
        }
        guard let baseCG = base.cgImage else { return nil }

        // Center-crop in (keep ~70%).
        let zoomKeep: CGFloat = 0.70
        let cropSize = CGFloat(baseCG.width) * zoomKeep
        let cx = (CGFloat(baseCG.width) - cropSize) / 2
        let cy = (CGFloat(baseCG.height) - cropSize) / 2
        guard let cropped = baseCG.cropping(to: CGRect(x: cx, y: cy, width: cropSize, height: cropSize).integral) else { return nil }

        // Downsample.
        let outRenderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target), format: format)
        let out = outRenderer.image { _ in
            UIImage(cgImage: cropped).draw(in: CGRect(x: 0, y: 0, width: target, height: target))
        }
        return out.cgImage
    }

    /// Multiple crops help when portrait X shifts due to different screenshot crops/scales.
    /// We spread candidates broadly in X so we hit the portrait even when the base rect is slightly off.
    private func candidateRects(forEnemySlot base: CGRect) -> [CGRect] {
        func c(_ x: CGFloat) -> CGFloat { min(1, max(0, x)) }
        func cr(_ r: CGRect) -> CGRect {
            let x = c(r.minX), y = c(r.minY), mx = c(r.maxX), my = c(r.maxY)
            return CGRect(x: x, y: y, width: max(0, mx - x), height: max(0, my - y))
        }
        func shift(_ r: CGRect, dx: CGFloat = 0, dy: CGFloat = 0) -> CGRect { cr(r.offsetBy(dx: dx, dy: dy)) }
        func inset(_ r: CGRect, f: CGFloat) -> CGRect { cr(r.insetBy(dx: r.width * f, dy: r.height * f)) }

        let s = base
        let w = s.width
        let h = s.height
        // X: phone photos / different crops shift the portrait horizontally vs splitX heuristics.
        // Y: real camera shots often misalign row centers slightly vs OCR-derived midYs — vertical nudges help Magneto vs wrong-row picks.
        return [
            s,
            shift(s, dx:  w * 0.15),
            shift(s, dx:  w * 0.30),
            shift(s, dx:  w * 0.45),
            shift(s, dx: -w * 0.15),
            shift(s, dx: -w * 0.30),
            shift(s, dy:  h * 0.14),
            shift(s, dy: -h * 0.14),
            shift(s, dy:  h * 0.24),
            shift(s, dy: -h * 0.24),
            shift(shift(s, dx: w * 0.15), dy: h * 0.14),
            shift(shift(s, dx: w * 0.15), dy: -h * 0.14),
            inset(s, f: 0.08),
            inset(shift(s, dx: w * 0.15), f: 0.08),
            inset(shift(s, dx: w * 0.30), f: 0.08),
        ].filter { $0.width >= 0.01 && $0.height >= 0.01 }
    }

    
    /// Resize to a stable size for feature extraction.
    private func normalizedPortraitCGImage(from image: UIImage) -> CGImage? {
        guard let cg = image.cgImage else { return nil }
        return normalizedReferenceFeatureInputCGImage(from: cg)
    }
    
    private func resizedSquareCGImage(from image: UIImage, target: CGFloat) -> CGImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target), format: format)
        let out = renderer.image { _ in
            let iw = image.size.width * image.scale
            let ih = image.size.height * image.scale
            let scale = max(target / iw, target / ih)
            let dw = iw * scale
            let dh = ih * scale
            let dx = (target - dw) / 2
            let dy = (target - dh) / 2
            image.draw(in: CGRect(x: dx, y: dy, width: dw, height: dh))
        }
        return out.cgImage
    }
    
    // MARK: - RGB thumbnail embedding (no Vision / Espresso)
    
    /// Aspect-fill into a square, then read premultiplied RGBA into a **unit L²** RGB vector (alpha unpremultiplied).
    private func rgbSquareThumbnailCGImage(from cgImage: CGImage) -> CGImage? {
        let side = CGFloat(thumbSide)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let size = CGSize(width: side, height: side)
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let img = UIImage(cgImage: cgImage)
        let out = renderer.image { _ in
            let iw = CGFloat(cgImage.width)
            let ih = CGFloat(cgImage.height)
            guard iw > 0, ih > 0 else { return }
            let scale = max(side / iw, side / ih)
            let dw = iw * scale
            let dh = ih * scale
            let dx = (side - dw) / 2
            let dy = (side - dh) / 2
            img.draw(in: CGRect(x: dx, y: dy, width: dw, height: dh))
        }
        return out.cgImage
    }
    
    private func rgbaBytes(from cgImage: CGImage) -> [UInt8]? {
        let w = cgImage.width
        let h = cgImage.height
        guard w > 0, h > 0 else { return nil }
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        var data = [UInt8](repeating: 0, count: h * bytesPerRow)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let ok: Bool = data.withUnsafeMutableBytes { rawPtr -> Bool in
            guard let ctx = CGContext(
                data: rawPtr.baseAddress,
                width: w, height: h,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
            return true
        }
        return ok ? data : nil
    }
    
    /// Same pipeline for bundle icons and scoreboard crops: square thumb → RGB unit vector.
    private func unitRGBVector(from cgImage: CGImage) -> [Float]? {
        guard let rgb = rgbSquareThumbnailCGImage(from: cgImage),
              let raw = rgbaBytes(from: rgb) else { return nil }
        let nPix = thumbSide * thumbSide
        guard raw.count >= nPix * 4 else { return nil }
        var v: [Float] = []
        v.reserveCapacity(nPix * 3)
        for i in stride(from: 0, to: nPix * 4, by: 4) {
            let pa255 = Float(raw[i + 3])
            if pa255 > 5 {
                v.append(Float(raw[i]) / pa255)
                v.append(Float(raw[i + 1]) / pa255)
                v.append(Float(raw[i + 2]) / pa255)
            } else {
                v.append(0)
                v.append(0)
                v.append(0)
            }
        }
        let norm = sqrt(v.reduce(0) { $0 + $1 * $1 })
        guard norm > 1e-4 else { return nil }
        return v.map { $0 / norm }
    }
    
    private func l2Distance(_ a: [Float], _ b: [Float]) -> Float {
        precondition(a.count == b.count)
        var s: Float = 0
        for i in 0..<a.count {
            let x = a[i] - b[i]
            s += x * x
        }
        return sqrt(s)
    }
    
    private func rankThumbDistances(query: [Float]) -> [(key: String, value: Float)]? {
        var perHeroBest: [String: Float] = [:]
        for (heroName, vecs) in referenceThumbVectors {
            var minD: Float = .greatestFiniteMagnitude
            for ref in vecs {
                let d = l2Distance(query, ref)
                minD = min(minD, d)
            }
            if minD < .greatestFiniteMagnitude {
                perHeroBest[heroName] = minD
            }
        }
        guard !perHeroBest.isEmpty else { return nil }
        return perHeroBest.sorted { a, b in
            if abs(a.value - b.value) > distanceEps { return a.value < b.value }
            return a.key < b.key
        }
    }
    
    private func rankFeaturePrintDistances(query: VNFeaturePrintObservation) -> [(key: String, value: Float)]? {
        var perHeroBest: [String: Float] = [:]
        for (heroName, fps) in referenceFeaturePrints {
            var minD: Float = .greatestFiniteMagnitude
            for ref in fps {
                var d: Float = 0
                do {
                    try ref.computeDistance(&d, to: query)
                    minD = min(minD, d)
                } catch {
                    continue
                }
            }
            if minD < .greatestFiniteMagnitude {
                perHeroBest[heroName] = minD
            }
        }
        guard !perHeroBest.isEmpty else { return nil }
        return perHeroBest.sorted { a, b in
            if abs(a.value - b.value) > distanceEps { return a.value < b.value }
            return a.key < b.key
        }
    }
    
    /// Shared acceptance rule: unique #1, distance cap, and separation vs #2.
    private func evaluateRankedMatch(
        ranked: [(key: String, value: Float)],
        maxDistance: Float,
        strongMatch: Float,
        minSep: Float,
        marginal: Float
    ) -> (String?, Float?) {
        guard !ranked.isEmpty else { return (nil, nil) }
        let bestVal = ranked[0].value
        if bestVal > maxDistance {
            return (nil, bestVal)
        }
        let tied = ranked.filter { abs($0.value - bestVal) <= distanceEps }
        guard tied.count == 1, let sole = tied.first else {
            return (nil, bestVal)
        }
        let winner = sole.key
        let nextRung = ranked.first { $0.value > bestVal + distanceEps }
        let gapToNext = nextRung.map { $0.value - bestVal } ?? Float.greatestFiniteMagnitude
        if bestVal <= strongMatch { return (winner, bestVal) }
        if gapToNext >= minSep { return (winner, bestVal) }
        if gapToNext >= marginal { return (winner, bestVal) }
        return (nil, bestVal)
    }
    
    private func bestMatchingHeroThumb(for query: [Float]) -> (String?, Float?) {
        guard let ranked = rankThumbDistances(query: query), !ranked.isEmpty else { return (nil, nil) }
        return evaluateRankedMatch(
            ranked: ranked,
            maxDistance: maxDistanceToAccept,
            strongMatch: strongMatchDistanceToAccept,
            minSep: minDistanceSeparationToAccept,
            marginal: marginalGapToAccept
        )
    }
    
    private func bestMatchingHeroFeaturePrint(for query: VNFeaturePrintObservation) -> (String?, Float?) {
        guard let ranked = rankFeaturePrintDistances(query: query), !ranked.isEmpty else { return (nil, nil) }
        return evaluateRankedMatch(
            ranked: ranked,
            maxDistance: maxFeaturePrintDistanceToAccept,
            strongMatch: strongFeaturePrintDistance,
            minSep: minFeaturePrintSeparation,
            marginal: marginalFeaturePrintGap
        )
    }
    
    /// Prefer Vision feature prints on device when refs loaded; otherwise RGB. If print fails for a crop, fall back to RGB.
    private func bestMatchForCrop(_ crop: CGImage) -> (String?, Float?) {
        if useFeaturePrintRanking, let fp = featurePrintObservation(from: crop) {
            return bestMatchingHeroFeaturePrint(for: fp)
        }
        guard let qvec = unitRGBVector(from: crop) else { return (nil, nil) }
        return bestMatchingHeroThumb(for: qvec)
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
