import SwiftUI

/// Breguet/leaf-style hand with organic curves — wider in the middle, tapering at both ends.
struct LeafHandShape: Shape {
    let length: CGFloat
    let maxWidth: CGFloat
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY

        var path = Path()
        // Start at tail bottom center
        path.move(to: CGPoint(x: midX, y: midY + tailLength))
        // Left side curve: tail to tip
        path.addQuadCurve(
            to: CGPoint(x: midX, y: midY - length),
            control: CGPoint(x: midX - maxWidth / 2, y: midY - length * 0.4)
        )
        // Right side curve: tip back to tail
        path.addQuadCurve(
            to: CGPoint(x: midX, y: midY + tailLength),
            control: CGPoint(x: midX + maxWidth / 2, y: midY - length * 0.4)
        )
        path.closeSubpath()
        return path
    }
}
