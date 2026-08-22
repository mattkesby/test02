import SwiftUI

struct MiddleFeeling {
    let name: String
    let outers: [String]
}

struct CoreEmotion: Identifiable {
    let name: String
    /// Core / middle / outer ring fills, saturated to pale.
    let colors: (core: Color, middle: Color, outer: Color)
    /// Darker companion for text on pale tints.
    let textColor: Color
    let mids: [MiddleFeeling]

    var id: String { name }
    var outerCount: Int { mids.reduce(0) { $0 + $1.outers.count } }
}

/// One tappable feeling on the outer ring, with its wheel position.
struct OuterFeeling: Identifiable, Hashable {
    let core: String
    let middle: String
    let name: String
    /// Wheel angles in degrees (0° = 3 o'clock, clockwise, y-down).
    let startAngle: Double
    let endAngle: Double

    var id: String { "\(core)/\(name)" }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: OuterFeeling, rhs: OuterFeeling) -> Bool { lhs.id == rhs.id }
}

enum Wheel {
    // Clockwise from the top, matching the classic feelings wheel.
    static let cores: [CoreEmotion] = [
        CoreEmotion(
            name: "Anger",
            colors: (Color(hex: 0xDF86DD), Color(hex: 0xECAEEA), Color(hex: 0xF6D7F5)),
            textColor: Color(hex: 0xA94EA7),
            mids: [
                MiddleFeeling(name: "Rage", outers: ["Hate", "Hostile"]),
                MiddleFeeling(name: "Exasperated", outers: ["Agitated", "Frustrated"]),
                MiddleFeeling(name: "Irritable", outers: ["Annoyed", "Aggravated"]),
                MiddleFeeling(name: "Envy", outers: ["Resentful", "Jealous"]),
                MiddleFeeling(name: "Disgust", outers: ["Contempt", "Revolted"]),
            ]
        ),
        CoreEmotion(
            name: "Sadness",
            colors: (Color(hex: 0x9FA9E6), Color(hex: 0xBFC6EF), Color(hex: 0xE0E3F8)),
            textColor: Color(hex: 0x53599C),
            mids: [
                MiddleFeeling(name: "Suffering", outers: ["Agony", "Hurt"]),
                MiddleFeeling(name: "Sadness", outers: ["Depressed", "Sorrow"]),
                MiddleFeeling(name: "Disappointed", outers: ["Dismayed", "Displeased"]),
                MiddleFeeling(name: "Shameful", outers: ["Regretful", "Guilty"]),
                MiddleFeeling(name: "Neglected", outers: ["Isolated", "Lonely"]),
                MiddleFeeling(name: "Despair", outers: ["Grief", "Powerless"]),
            ]
        ),
        CoreEmotion(
            name: "Surprise",
            colors: (Color(hex: 0x7FDCC0), Color(hex: 0xA8E8D4), Color(hex: 0xD6F4EA)),
            textColor: Color(hex: 0x2E8A6C),
            mids: [
                MiddleFeeling(name: "Stunned", outers: ["Shocked", "Dismayed"]),
                MiddleFeeling(name: "Confused", outers: ["Disillusioned", "Perplexed"]),
                MiddleFeeling(name: "Amazed", outers: ["Astonished", "Awe-struck"]),
                MiddleFeeling(name: "Overcome", outers: ["Speechless", "Astounded"]),
                MiddleFeeling(name: "Moved", outers: ["Stimulated", "Touched"]),
            ]
        ),
        CoreEmotion(
            name: "Joy",
            colors: (Color(hex: 0xA8D97A), Color(hex: 0xC6E6A2), Color(hex: 0xE4F3D2)),
            textColor: Color(hex: 0x5D8A3C),
            mids: [
                MiddleFeeling(name: "Content", outers: ["Pleased", "Satisfied"]),
                MiddleFeeling(name: "Happy", outers: ["Amused", "Delighted"]),
                MiddleFeeling(name: "Cheerful", outers: ["Jovial", "Blissful"]),
                MiddleFeeling(name: "Proud", outers: ["Triumphant", "Illustrious"]),
                MiddleFeeling(name: "Optimistic", outers: ["Eager", "Hopeful"]),
                MiddleFeeling(name: "Enthusiastic", outers: ["Excited", "Zeal"]),
                MiddleFeeling(name: "Elation", outers: ["Euphoric", "Jubilation"]),
                MiddleFeeling(name: "Enthralled", outers: ["Enchanted", "Rapture"]),
            ]
        ),
        CoreEmotion(
            name: "Love",
            colors: (Color(hex: 0xE9D377), Color(hex: 0xF1E4A4), Color(hex: 0xF9F2D4)),
            textColor: Color(hex: 0x9A7D1E),
            mids: [
                MiddleFeeling(name: "Affectionate", outers: ["Romantic", "Fondness"]),
                MiddleFeeling(name: "Longing", outers: ["Sentimental", "Attracted"]),
                MiddleFeeling(name: "Desire", outers: ["Passion", "Infatuation"]),
                MiddleFeeling(name: "Tenderness", outers: ["Caring", "Compassionate"]),
                MiddleFeeling(name: "Peaceful", outers: ["Relieved", "Satisfied"]),
            ]
        ),
        CoreEmotion(
            name: "Fear",
            colors: (Color(hex: 0xEC9B85), Color(hex: 0xF3BCAC), Color(hex: 0xFADFD7)),
            textColor: Color(hex: 0xB65B41),
            mids: [
                MiddleFeeling(name: "Scared", outers: ["Frightened", "Helpless"]),
                MiddleFeeling(name: "Terror", outers: ["Panic", "Hysterical"]),
                MiddleFeeling(name: "Insecure", outers: ["Inferior", "Inadequate"]),
                MiddleFeeling(name: "Nervous", outers: ["Worried", "Anxious"]),
                MiddleFeeling(name: "Horror", outers: ["Mortified", "Dread"]),
            ]
        ),
    ]

    /// Angular width of one middle-feeling wedge, in degrees.
    static let unitDegrees: Double = 360.0 / Double(cores.reduce(0) { $0 + $1.mids.count })

    /// Start angle of the whole wheel: Anger's wedge is centred on 12 o'clock.
    static let startDegrees: Double = -90 - Double(cores[0].mids.count) * unitDegrees / 2

    /// Angular span of one core emotion, keyed by index into `cores`.
    static func span(of core: CoreEmotion) -> Double {
        Double(core.mids.count) * unitDegrees
    }

    /// Start angle of a core's wedge on the unrotated wheel.
    static func startAngle(of coreIndex: Int) -> Double {
        var angle = startDegrees
        for i in 0..<coreIndex { angle += span(of: cores[i]) }
        return angle
    }

    static let outerFeelings: [OuterFeeling] = {
        var result: [OuterFeeling] = []
        var cursor = startDegrees
        for core in cores {
            for mid in core.mids {
                let width = unitDegrees / Double(mid.outers.count)
                for outer in mid.outers {
                    result.append(OuterFeeling(
                        core: core.name,
                        middle: mid.name,
                        name: outer,
                        startAngle: cursor,
                        endAngle: cursor + width
                    ))
                    cursor += width
                }
            }
        }
        return result
    }()

    static func core(named name: String) -> CoreEmotion {
        cores.first { $0.name == name } ?? cores[0]
    }

    static func outers(of core: CoreEmotion) -> [OuterFeeling] {
        outerFeelings.filter { $0.core == core.name }
    }

    /// The core emotion whose wedge sits under the 12 o'clock pointer
    /// for a wheel rotated by `rotation` degrees.
    static func focusedCore(rotation: Double) -> CoreEmotion {
        var pointer = (-90 - rotation).truncatingRemainder(dividingBy: 360)
        if pointer < 0 { pointer += 360 }
        for (index, core) in cores.enumerated() {
            var start = startAngle(of: index).truncatingRemainder(dividingBy: 360)
            if start < 0 { start += 360 }
            var angle = pointer
            if angle < start { angle += 360 }
            if angle >= start, angle < start + span(of: core) { return core }
        }
        return cores[0]
    }
}
