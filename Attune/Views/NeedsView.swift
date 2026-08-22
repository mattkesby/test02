import SwiftUI

/// The route pushed from NeedsView to RespondView.
struct RespondRoute: Hashable {
    let feeling: OuterFeeling
    let needs: [String]
}

/// Screen 2: the needs that may be unmet (or nourished) beneath a feeling.
struct NeedsView: View {
    let feeling: OuterFeeling

    /// In pick order — the first selected need leads the NVC sentence.
    @State private var selectedNeeds: [String] = []

    private var core: CoreEmotion { Wheel.core(named: feeling.core) }
    private var met: Bool { NVC.needsAreMet(core: feeling.core) }
    private var needs: [Need] { NVC.candidateNeeds(core: feeling.core) }

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleBlock
                    explainerCard
                    sectionHeader
                    needsGrid
                    attribution
                }
                .padding(.horizontal, 24)
            }
            callToAction
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Circle()
                    .fill(core.colors.core)
                    .frame(width: 14, height: 14)
                Text(feeling.name)
                    .font(.system(size: 32, design: .serif))
                    .foregroundColor(Theme.ink)
            }
            Text("\(feeling.core) · \(feeling.middle) · \(feeling.name)")
                .font(.system(size: 12.5))
                .foregroundColor(Theme.muted)
        }
        .padding(.top, 6)
    }

    private var explainerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Feelings are messengers.")
                .font(.system(size: 17, design: .serif).italic())
                .foregroundColor(Theme.ink)
            Text(met
                 ? "In Nonviolent Communication, a pleasant feeling like \(feeling.name.lowercased()) is a signal — needs of yours are being nourished. Naming them helps you savor and protect what's working."
                 : "In Nonviolent Communication, \(feeling.name.lowercased()) is a signal — a need of yours isn't being met. Naming the need turns the feeling into something you can act on.")
                .font(.system(size: 13))
                .lineSpacing(3)
                .foregroundColor(Theme.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.cardBorder, lineWidth: 1))
        .padding(.top, 18)
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(met ? "NEEDS BEING NOURISHED" : "POSSIBLE UNMET NEEDS")
                .font(.system(size: 11, weight: .semibold))
                .kerning(2)
                .foregroundColor(Theme.subtle)
            Text("tap all that resonate")
                .font(.system(size: 12))
                .foregroundColor(Theme.muted)
        }
        .padding(.top, 22)
        .padding(.bottom, 10)
    }

    private var needsGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(needs) { need in
                needCard(need)
            }
        }
    }

    private func needCard(_ need: Need) -> some View {
        let isSelected = selectedNeeds.contains(need.name)
        return Button {
            if isSelected {
                selectedNeeds.removeAll { $0 == need.name }
            } else {
                selectedNeeds.append(need.name)
            }
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(need.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.ink)
                Text(need.gloss)
                    .font(.system(size: 12))
                    .lineSpacing(2)
                    .foregroundColor(Theme.subtle)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? core.colors.outer : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Theme.ink : Theme.cardBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var attribution: some View {
        Text("Based on Marshall Rosenberg's Nonviolent Communication")
            .font(.system(size: 11))
            .foregroundColor(Theme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
    }

    private var callToAction: some View {
        NavigationLink(value: RespondRoute(feeling: feeling, needs: selectedNeeds)) {
            HStack {
                Text(met ? "Express appreciation" : "Craft an NVC response")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(selectedNeeds.count == 1 ? "1 need" : "\(selectedNeeds.count) needs")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.background.opacity(0.65))
            }
            .foregroundColor(Theme.background)
            .padding(.horizontal, 22)
            .frame(height: 58)
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.inkDeep))
            .opacity(selectedNeeds.isEmpty ? 0.4 : 1)
        }
        .buttonStyle(.plain)
        .disabled(selectedNeeds.isEmpty)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
