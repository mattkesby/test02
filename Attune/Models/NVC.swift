import Foundation

/// Content derived from Marshall Rosenberg's Nonviolent Communication:
/// feelings point to needs; responses are built from observation,
/// feeling, need, and request (or, when a need is met, appreciation).
struct Need: Identifiable, Hashable {
    let name: String
    let gloss: String
    var id: String { name }
}

struct NVCStep: Identifiable {
    let title: String
    let body: String
    let tip: String
    var id: String { title }
}

enum ResponseMode: String, CaseIterable, Identifiable {
    case outward
    case inward
    var id: String { rawValue }
}

enum NVC {
    /// Joy and Love usually signal needs being *met*; the other cores
    /// signal needs asking for attention.
    static func needsAreMet(core: String) -> Bool {
        core == "Joy" || core == "Love"
    }

    static func candidateNeeds(core: String) -> [Need] {
        switch core {
        case "Anger":
            return [
                Need(name: "Effectiveness", gloss: "to see your efforts actually work"),
                Need(name: "Progress", gloss: "movement toward what matters"),
                Need(name: "Competence", gloss: "trust in your own ability"),
                Need(name: "Ease", gloss: "for things to flow without struggle"),
                Need(name: "Clarity", gloss: "to know what is expected"),
                Need(name: "Support", gloss: "help carrying the load"),
                Need(name: "Cooperation", gloss: "working with, not against"),
                Need(name: "Autonomy", gloss: "choice over how you do things"),
                Need(name: "To be heard", gloss: "your input landing with others"),
                Need(name: "Consideration", gloss: "your time and effort respected"),
                Need(name: "Respect", gloss: "to be taken seriously"),
                Need(name: "Fairness", gloss: "the same rules for everyone"),
            ]
        case "Sadness":
            return [
                Need(name: "Comfort", gloss: "softness when things are heavy"),
                Need(name: "Connection", gloss: "to feel close to someone"),
                Need(name: "Belonging", gloss: "a place among people"),
                Need(name: "Support", gloss: "help carrying the load"),
                Need(name: "Understanding", gloss: "to be seen as you are"),
                Need(name: "Mourning", gloss: "room to grieve what was lost"),
                Need(name: "Hope", gloss: "a sense that things can shift"),
                Need(name: "Rest", gloss: "permission to stop for a while"),
                Need(name: "Companionship", gloss: "not facing it alone"),
                Need(name: "To matter", gloss: "knowing you count to someone"),
            ]
        case "Fear":
            return [
                Need(name: "Safety", gloss: "shelter from harm"),
                Need(name: "Security", gloss: "solid ground to stand on"),
                Need(name: "Predictability", gloss: "knowing what comes next"),
                Need(name: "Trust", gloss: "confidence in people around you"),
                Need(name: "Reassurance", gloss: "a steady voice saying it's okay"),
                Need(name: "Protection", gloss: "someone watching your back"),
                Need(name: "Stability", gloss: "fewer sudden changes"),
                Need(name: "Clarity", gloss: "facts instead of imaginings"),
                Need(name: "Preparedness", gloss: "feeling ready for what's coming"),
                Need(name: "Support", gloss: "help carrying the load"),
            ]
        case "Surprise":
            return [
                Need(name: "Clarity", gloss: "to understand what just happened"),
                Need(name: "Time to process", gloss: "a pause before responding"),
                Need(name: "Orientation", gloss: "regaining your bearings"),
                Need(name: "Information", gloss: "the missing pieces"),
                Need(name: "Understanding", gloss: "making sense of it"),
                Need(name: "Stability", gloss: "ground that stops moving"),
                Need(name: "Predictability", gloss: "knowing what comes next"),
                Need(name: "Grounding", gloss: "coming back to your body"),
            ]
        case "Joy":
            return [
                Need(name: "Celebration", gloss: "marking what went well"),
                Need(name: "Play", gloss: "lightness for its own sake"),
                Need(name: "Accomplishment", gloss: "seeing your work bear fruit"),
                Need(name: "Growth", gloss: "becoming more yourself"),
                Need(name: "Meaning", gloss: "what you do mattering"),
                Need(name: "Vitality", gloss: "energy moving through you"),
                Need(name: "Freedom", gloss: "room to move and choose"),
                Need(name: "Creativity", gloss: "making something new"),
                Need(name: "Connection", gloss: "sharing it with someone"),
                Need(name: "Hope", gloss: "a future worth leaning toward"),
            ]
        case "Love":
            return [
                Need(name: "Connection", gloss: "to feel close to someone"),
                Need(name: "Intimacy", gloss: "being fully known"),
                Need(name: "Warmth", gloss: "tenderness given and received"),
                Need(name: "Belonging", gloss: "a place among people"),
                Need(name: "Care", gloss: "being looked after"),
                Need(name: "Trust", gloss: "resting in the relationship"),
                Need(name: "Appreciation", gloss: "being valued as you are"),
                Need(name: "Closeness", gloss: "less distance between you"),
                Need(name: "Tenderness", gloss: "gentleness with each other"),
                Need(name: "Community", gloss: "a wider circle that holds you"),
            ]
        default:
            return []
        }
    }

    static func steps(mode: ResponseMode, met: Bool, feeling: String, need: String) -> [NVCStep] {
        let feelingLower = feeling.lowercased()
        let needLower = need.lowercased()
        switch (mode, met) {
        case (.outward, false):
            return [
                NVCStep(title: "Observe",
                        body: "Describe what happened like a camera would record it — no verdicts.",
                        tip: "\u{201C}You always ignore my messages\u{201D} is a judgment. \u{201C}I sent three messages this week\u{201D} is an observation."),
                NVCStep(title: "Feel",
                        body: "Name the emotion itself, and own it as yours.",
                        tip: "\u{201C}I feel ignored\u{201D} points a finger. \u{201C}I feel \(feelingLower)\u{201D} names a feeling."),
                NVCStep(title: "Need",
                        body: "Link the feeling to your need — not to their behavior.",
                        tip: "Needs are universal; strategies for meeting them are negotiable."),
                NVCStep(title: "Request",
                        body: "Ask for one concrete, doable action — and mean it as a request.",
                        tip: "A request survives hearing \u{201C}no\u{201D}. A demand does not."),
            ]
        case (.inward, false):
            return [
                NVCStep(title: "Pause",
                        body: "One slow breath before any words. The gap is where choice lives.",
                        tip: "Nothing needs to be said in this minute."),
                NVCStep(title: "Name",
                        body: "Silently say: \u{201C}I notice \(feelingLower) is here.\u{201D}",
                        tip: "Naming an emotion loosens its grip."),
                NVCStep(title: "Connect",
                        body: "Ask: which need of mine is calling for attention?",
                        tip: "This feeling may be guarding your need for \(needLower)."),
                NVCStep(title: "Choose",
                        body: "Decide your next step from the need — not from the trigger.",
                        tip: "What would meet the need for \(needLower), even a little?"),
            ]
        case (.outward, true):
            return [
                NVCStep(title: "Observe",
                        body: "Say specifically what they did that enriched your life.",
                        tip: "\u{201C}You're amazing\u{201D} is vague praise. \u{201C}You stayed late to help me finish\u{201D} is specific."),
                NVCStep(title: "Feel",
                        body: "Share the feeling their action sparked in you.",
                        tip: "Let them see the \(feelingLower), not just hear about it."),
                NVCStep(title: "Need",
                        body: "Name the need of yours it met.",
                        tip: "Gratitude lands deepest when it names what was nourished: \(needLower)."),
                NVCStep(title: "Appreciate",
                        body: "Let it land — gratitude, not flattery, and nothing owed back.",
                        tip: "No praise, no payback — just what their action did for you."),
            ]
        case (.inward, true):
            return [
                NVCStep(title: "Savor",
                        body: "Stay with the feeling a few breaths longer than usual.",
                        tip: "Good moments pass quickly unless you give them room."),
                NVCStep(title: "Name",
                        body: "Silently say: \u{201C}I notice \(feelingLower) is here.\u{201D}",
                        tip: "Naming a pleasant feeling deepens it."),
                NVCStep(title: "Connect",
                        body: "Ask: which need of mine is being nourished right now?",
                        tip: "This feeling suggests your need for \(needLower) is being met."),
                NVCStep(title: "Extend",
                        body: "Consider what — or who — helped, and how to invite more of it.",
                        tip: "Met needs are worth protecting, not just noticing."),
            ]
        }
    }
}
