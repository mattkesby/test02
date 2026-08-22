import SwiftUI

/// Screen 3: build an NVC response from the feeling and chosen needs —
/// outward (say it to them) or inward (self-empathy).
struct RespondView: View {
    let route: RespondRoute

    @State private var mode: ResponseMode = .outward

    private var core: CoreEmotion { Wheel.core(named: route.feeling.core) }
    private var met: Bool { NVC.needsAreMet(core: route.feeling.core) }
    private var primaryNeed: String { route.needs.first ?? "connection" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(met ? "Share the good" : "Respond with care")
                    .font(.system(size: 32, design: .serif))
                    .foregroundColor(Theme.ink)
                    .padding(.top, 6)
                contextChips
                modePicker
                sentenceCard
                steps
                attribution
            }
            .padding(.horizontal, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
    }

    private var contextChips: some View {
        HStack(spacing: 8) {
            chip("Feeling · \(route.feeling.name)", tint: core.colors.outer, text: core.textColor)
            chip("Need · \(primaryNeed)", tint: Color(hex: 0xE4F3D2), text: Theme.needAccent)
        }
        .padding(.top, 10)
    }

    private func chip(_ label: String, tint: Color, text: Color) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(tint))
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            modeButton(.outward, label: met ? "Tell them" : "Say it to them")
            modeButton(.inward, label: "Self-empathy")
        }
        .padding(4)
        .background(Capsule().fill(Theme.segmentTrack))
        .padding(.top, 18)
    }

    private func modeButton(_ target: ResponseMode, label: String) -> some View {
        let isOn = mode == target
        return Button {
            withAnimation(.easeOut(duration: 0.15)) { mode = target }
        } label: {
            Text(label)
                .font(.system(size: 13.5, weight: isOn ? .semibold : .regular))
                .foregroundColor(isOn ? Theme.ink : Theme.subtle)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    Capsule()
                        .fill(isOn ? Theme.card : Color.clear)
                        .shadow(color: Theme.ink.opacity(isOn ? 0.12 : 0), radius: 2, y: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var sentenceCard: some View {
        sentence
            .font(.system(size: 19, design: .serif))
            .lineSpacing(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
            .padding(.top, 16)
    }

    private var feelingText: Text {
        Text(route.feeling.name.lowercased()).italic().foregroundColor(Theme.feelingAccent)
    }

    private var needText: Text {
        Text(primaryNeed.lowercased()).italic().foregroundColor(Theme.needAccent)
    }

    private func slot(_ label: String) -> Text {
        Text(label).foregroundColor(Theme.muted).underline(true, color: Theme.muted.opacity(0.6))
    }

    private var sentence: Text {
        switch (mode, met) {
        case (.outward, false):
            return Text("When ") + slot("[what happened]")
                + Text(", I feel ") + feelingText
                + Text(" because I need ") + needText
                + Text(". Would you be willing to ") + slot("[one doable action]") + Text("?")
        case (.inward, false):
            return Text("Something happened. I feel ") + feelingText
                + Text(" because ") + needText
                + Text(" matters to me. What would help right now?")
        case (.outward, true):
            return Text("When you ") + slot("[what they did]")
                + Text(", I felt ") + feelingText
                + Text(" — it met my need for ") + needText
                + Text(". Thank you.")
        case (.inward, true):
            return Text("Something good happened. I feel ") + feelingText
                + Text(" because my need for ") + needText
                + Text(" is being nourished. How can I savor this?")
        }
    }

    private var steps: some View {
        VStack(spacing: 10) {
            ForEach(Array(NVC.steps(mode: mode, met: met,
                                    feeling: route.feeling.name,
                                    need: primaryNeed).enumerated()), id: \.element.id) { index, step in
                stepCard(number: index + 1, step: step)
            }
        }
        .padding(.top, 16)
    }

    private func stepCard(number: Int, step: NVCStep) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(Theme.ink)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Theme.ink, lineWidth: 1.5))
            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.ink)
                Text(step.body)
                    .font(.system(size: 13))
                    .lineSpacing(3)
                    .foregroundColor(Theme.body)
                Text(step.tip)
                    .font(.system(size: 12).italic())
                    .lineSpacing(3)
                    .foregroundColor(Theme.muted)
                    .padding(.top, 3)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private var attribution: some View {
        Text("Framework: Marshall Rosenberg, Nonviolent Communication")
            .font(.system(size: 11))
            .foregroundColor(Theme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
    }
}
