import SwiftUI

/// Home screen: the spinnable wheel of emotions. Drag anywhere on the
/// wheel to spin it; the core emotion under the top pointer is focused
/// and its outer feelings appear as tappable chips below.
struct WheelScreen: View {
    @State private var rotation: Double = 0
    /// Anchor of the drag in progress: its fixed start location (to tell
    /// gestures apart even if a cancellation skips onEnded) and the last
    /// pointer angle seen.
    @State private var dragSession: (start: CGPoint, lastAngle: Double)?
    @State private var selected: OuterFeeling?

    private var focusedCore: CoreEmotion { Wheel.focusedCore(rotation: rotation) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            wheel
            focusRow
            chips
            callToAction
        }
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.selection, trigger: focusedCore.name)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ATTUNE")
                .font(.system(size: 11, weight: .semibold))
                .kerning(3)
                .foregroundColor(Theme.muted)
            Text("How are you feeling?")
                .font(.system(size: 25, design: .serif))
                .foregroundColor(Theme.ink)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    private var wheel: some View {
        GeometryReader { geometry in
            WheelCanvas(rotation: rotation, selected: selected, focusedName: focusedCore.name)
                .contentShape(Rectangle())
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in handleTap(at: value.location, in: geometry.size) }
                )
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            handleDrag(from: value.startLocation, to: value.location, in: geometry.size)
                        }
                        .onEnded { _ in dragSession = nil }
                )
        }
        .aspectRatio(390.0 / 396.0, contentMode: .fit)
        .accessibilityLabel("Wheel of emotions, focused on \(focusedCore.name). Spin to change focus.")
    }

    private var focusRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(focusedCore.name)
                .font(.system(size: 19, design: .serif))
                .foregroundColor(Theme.ink)
            Text("\(focusedCore.outerCount) outer feelings — tap one")
                .font(.system(size: 12))
                .foregroundColor(Theme.muted)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var chips: some View {
        ScrollView {
            FlowLayout(spacing: 8) {
                ForEach(Wheel.outers(of: focusedCore)) { feeling in
                    chip(for: feeling)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
        }
        .frame(maxHeight: .infinity)
    }

    private func chip(for feeling: OuterFeeling) -> some View {
        let isSelected = feeling == selected
        return Button {
            selected = feeling
        } label: {
            Text(feeling.name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Theme.ink : Theme.body)
                .padding(.horizontal, 17)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(isSelected ? focusedCore.colors.middle : Theme.card)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Theme.ink : Theme.cardBorder, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var callToAction: some View {
        if let selected {
            NavigationLink(value: selected) {
                HStack {
                    Text("What's beneath \(selected.name)?")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Theme.background)
                .padding(.horizontal, 22)
                .frame(height: 58)
                .background(RoundedRectangle(cornerRadius: 18).fill(Theme.inkDeep))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Gestures

    /// Angle (degrees) of a point around the wheel centre, in view space.
    private func angle(of location: CGPoint, in size: CGSize) -> Double {
        let center = WheelCanvas.center(in: size)
        return atan2(location.y - center.y, location.x - center.x) * 180 / .pi
    }

    private func handleDrag(from start: CGPoint, to location: CGPoint, in size: CGSize) {
        let angle = angle(of: location, in: size)
        if let session = dragSession, session.start == start {
            var delta = angle - session.lastAngle
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }
            rotation += delta
        }
        dragSession = (start, angle)
    }

    private func handleTap(at location: CGPoint, in size: CGSize) {
        let center = WheelCanvas.center(in: size)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let radius = (dx * dx + dy * dy).squareRoot()
        let scale = WheelCanvas.scale(in: size)
        guard radius >= 172 * scale, radius <= 248 * scale else { return }

        var tapped = atan2(dy, dx) * 180 / .pi - rotation
        // Normalise into the wheel's angular range [start, start + 360).
        tapped = (tapped - Wheel.startDegrees).truncatingRemainder(dividingBy: 360)
        if tapped < 0 { tapped += 360 }
        tapped += Wheel.startDegrees

        if let hit = Wheel.outerFeelings.first(where: { tapped >= $0.startAngle && tapped < $0.endAngle }) {
            selected = hit
        }
    }
}

/// Draws the full three-ring wheel, the selection outline, hub and pointer.
struct WheelCanvas: View {
    let rotation: Double
    let selected: OuterFeeling?
    let focusedName: String

    /// All geometry is authored in a 390-wide design space and scaled.
    static func scale(in size: CGSize) -> CGFloat { size.width / 390 }
    static func center(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2, y: 270 * scale(in: size))
    }

    private static let hubRadius: CGFloat = 50
    private static let coreRadius: CGFloat = 108
    private static let midRadius: CGFloat = 172
    private static let outerRadius: CGFloat = 248

    var body: some View {
        Canvas { context, size in
            let scale = Self.scale(in: size)
            let center = Self.center(in: size)

            var wheel = context
            wheel.translateBy(x: center.x, y: center.y)
            wheel.rotate(by: .degrees(rotation))
            wheel.scaleBy(x: scale, y: scale)
            drawRings(in: &wheel)
            drawSelection(in: &wheel)

            drawHub(in: context, center: center, scale: scale)
        }
        .shadow(color: Color(hex: 0x46305C).opacity(0.14), radius: 12, y: 5)
    }

    private func wedge(_ a0: Double, _ a1: Double, _ r0: CGFloat, _ r1: CGFloat) -> Path {
        var path = Path()
        path.addArc(center: .zero, radius: r1,
                    startAngle: .degrees(a0), endAngle: .degrees(a1), clockwise: false)
        path.addArc(center: .zero, radius: r0,
                    startAngle: .degrees(a1), endAngle: .degrees(a0), clockwise: true)
        path.closeSubpath()
        return path
    }

    private func drawRings(in context: inout GraphicsContext) {
        var cursor = Wheel.startDegrees
        for core in Wheel.cores {
            let span = Wheel.span(of: core)
            fillWedge(in: &context, wedge(cursor, cursor + span, Self.hubRadius, Self.coreRadius),
                      color: core.colors.core)
            var midCursor = cursor
            for mid in core.mids {
                let midEnd = midCursor + Wheel.unitDegrees
                fillWedge(in: &context, wedge(midCursor, midEnd, Self.coreRadius, Self.midRadius),
                          color: core.colors.middle)
                let outerWidth = Wheel.unitDegrees / Double(mid.outers.count)
                var outerCursor = midCursor
                for outer in mid.outers {
                    fillWedge(in: &context,
                              wedge(outerCursor, outerCursor + outerWidth, Self.midRadius, Self.outerRadius),
                              color: core.colors.outer)
                    drawLabel(in: &context, text: outer,
                              angle: outerCursor + outerWidth / 2,
                              radius: (Self.midRadius + Self.outerRadius) / 2,
                              font: .system(size: 10.5), color: Color(hex: 0x3F3749))
                    outerCursor += outerWidth
                }
                drawLabel(in: &context, text: mid.name,
                          angle: midCursor + Wheel.unitDegrees / 2,
                          radius: (Self.coreRadius + Self.midRadius) / 2,
                          font: .system(size: 10), color: Color(hex: 0x4C4356))
                midCursor = midEnd
            }
            drawLabel(in: &context, text: core.name,
                      angle: cursor + span / 2,
                      radius: (Self.hubRadius + Self.coreRadius) / 2,
                      font: .system(size: 14.5, design: .serif).italic(), color: Theme.ink)
            cursor += span
        }
    }

    private func fillWedge(in context: inout GraphicsContext, _ path: Path, color: Color) {
        context.fill(path, with: .color(color))
        context.stroke(path, with: .color(Theme.background), lineWidth: 1.2)
    }

    /// Radial label, flipped on the visually-left half of the wheel so it
    /// stays readable at the current rotation.
    private func drawLabel(in context: inout GraphicsContext, text: String,
                           angle: Double, radius: CGFloat, font: Font, color: Color) {
        var normalized = (angle + rotation).truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        let flipped = normalized > 90 && normalized < 270
        let radians = angle * .pi / 180
        var label = context
        label.translateBy(x: radius * cos(radians), y: radius * sin(radians))
        label.rotate(by: .degrees(flipped ? angle + 180 : angle))
        label.draw(Text(text).font(font).foregroundColor(color), at: .zero, anchor: .center)
    }

    private func drawSelection(in context: inout GraphicsContext) {
        guard let selected else { return }
        let path = wedge(selected.startAngle, selected.endAngle, Self.midRadius, Self.outerRadius)
        context.stroke(path, with: .color(Theme.ink), lineWidth: 2.5)
    }

    private func drawHub(in context: GraphicsContext, center: CGPoint, scale: CGFloat) {
        let hub = Path(ellipseIn: CGRect(
            x: center.x - Self.hubRadius * scale,
            y: center.y - Self.hubRadius * scale,
            width: Self.hubRadius * 2 * scale,
            height: Self.hubRadius * 2 * scale
        ))
        context.fill(hub, with: .color(Theme.card))
        context.stroke(hub, with: .color(Theme.ink.opacity(0.12)), lineWidth: 1)
        context.draw(
            Text(focusedName).font(.system(size: 19, design: .serif).italic()).foregroundColor(Theme.ink),
            at: CGPoint(x: center.x, y: center.y - 5 * scale), anchor: .center
        )
        context.draw(
            Text("SPIN ME").font(.system(size: 9.5)).kerning(1.5).foregroundColor(Theme.muted),
            at: CGPoint(x: center.x, y: center.y + 15 * scale), anchor: .center
        )

        var pointer = Path()
        pointer.move(to: CGPoint(x: center.x - 9 * scale, y: 6 * scale))
        pointer.addLine(to: CGPoint(x: center.x + 9 * scale, y: 6 * scale))
        pointer.addLine(to: CGPoint(x: center.x, y: 22 * scale))
        pointer.closeSubpath()
        context.fill(pointer, with: .color(Theme.ink))
    }
}
