import SwiftUI

/// Reusable subdial frame: circle outline with 12 tick marks and a content slot.
struct SubdialView<Content: View>: View {
    let diameter: CGFloat
    let tickCount: Int
    @ViewBuilder let content: () -> Content

    init(diameter: CGFloat, tickCount: Int = 12,
         @ViewBuilder content: @escaping () -> Content) {
        self.diameter = diameter
        self.tickCount = tickCount
        self.content = content
    }

    private var radius: CGFloat { diameter / 2 }

    var body: some View {
        ZStack {
            // Subdial circle frame
            Circle()
                .stroke(WatchConstants.silverDark, lineWidth: 0.5)
                .frame(width: diameter, height: diameter)

            // Tick marks
            tickMarks

            // Content (hand, text, gauge, etc.)
            content()
        }
        .frame(width: diameter, height: diameter)
    }

    private var tickMarks: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = radius - 1
            let tickLen: CGFloat = 3

            for i in 0..<tickCount {
                let angle = Angle.degrees(Double(i) * (360.0 / Double(tickCount)) - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                let outer = CGPoint(x: center.x + cosA * r, y: center.y + sinA * r)
                let inner = CGPoint(x: center.x + cosA * (r - tickLen),
                                    y: center.y + sinA * (r - tickLen))
                var tick = Path()
                tick.move(to: outer)
                tick.addLine(to: inner)
                context.stroke(tick,
                               with: .color(WatchConstants.tickGray),
                               lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }
}
