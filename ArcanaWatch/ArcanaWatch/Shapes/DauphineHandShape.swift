import SwiftUI

/// Dauphine hand: tapered polygon wider at the base with a sharp tip.
/// Drawn upward (negative Y) in its own coordinate space, then rotated by the parent.
struct DauphineHandShape: Shape {
    /// Length from center to tip.
    let length: CGFloat
    /// Width at the base.
    let baseWidth: CGFloat
    /// Short tail extension below center.
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let halfBase = baseWidth / 2
        let midTaper = baseWidth / 6 // narrow taper at 60% of length

        var path = Path()
        // Tail (below center)
        path.move(to: CGPoint(x: midX - halfBase, y: midY + tailLength))
        // Base left
        path.addLine(to: CGPoint(x: midX - halfBase, y: midY))
        // Mid taper left (60% up)
        path.addLine(to: CGPoint(x: midX - midTaper, y: midY - length * 0.6))
        // Tip
        path.addLine(to: CGPoint(x: midX, y: midY - length))
        // Mid taper right
        path.addLine(to: CGPoint(x: midX + midTaper, y: midY - length * 0.6))
        // Base right
        path.addLine(to: CGPoint(x: midX + halfBase, y: midY))
        // Tail right
        path.addLine(to: CGPoint(x: midX + halfBase, y: midY + tailLength))
        path.closeSubpath()
        return path
    }
}
