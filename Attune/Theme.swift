import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Theme {
    static let background = Color(hex: 0xFAF7F2)
    static let card = Color(hex: 0xFFFDF9)
    static let cardBorder = Color(hex: 0xE9E1D5)
    static let ink = Color(hex: 0x3A3244)
    static let inkDeep = Color(hex: 0x332C3E)
    static let body = Color(hex: 0x54495F)
    static let subtle = Color(hex: 0x6D6178)
    static let muted = Color(hex: 0x9A8FA6)
    static let segmentTrack = Color(hex: 0xEFE9DF)
    static let feelingAccent = Color(hex: 0xA94EA7)
    static let needAccent = Color(hex: 0x5D8A3C)
}

/// Wraps subviews onto new rows, like flexbox `wrap` with a gap.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        let width = maxWidth.isFinite ? maxWidth : max(0, x - spacing)
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
