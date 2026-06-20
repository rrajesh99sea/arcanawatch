import SwiftUI

/// Sword-style hand matching the HTML _drawSwordHand exactly.
/// baseWidth = full width of the base/tip section.
/// Guard (40%–55% of length) flares to 2.4× the base width, like a cross-guard.
/// The tip is flat (rectangular), not pointed.
struct SwordHandShape: Shape {
    let length: CGFloat
    let baseWidth: CGFloat
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let hw = baseWidth / 2       // half base-width from center
        let gw = baseWidth * 1.2     // guard half-width (w*1.2 in HTML)

        var path = Path()
        // Tail (below pivot)
        path.move(to: CGPoint(x: midX - hw, y: midY + tailLength))
        path.addLine(to: CGPoint(x: midX - hw, y: midY))
        // Shaft up to guard start (40%)
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.40))
        // Guard step out
        path.addLine(to: CGPoint(x: midX - gw, y: midY - length * 0.40))
        // Guard top
        path.addLine(to: CGPoint(x: midX - gw, y: midY - length * 0.55))
        // Guard step back in
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.55))
        // Up to flat tip
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length))
        // Mirror: down from tip to guard
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.55))
        path.addLine(to: CGPoint(x: midX + gw, y: midY - length * 0.55))
        path.addLine(to: CGPoint(x: midX + gw, y: midY - length * 0.40))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.40))
        // Back to pivot and tail
        path.addLine(to: CGPoint(x: midX + hw, y: midY))
        path.addLine(to: CGPoint(x: midX + hw, y: midY + tailLength))
        path.closeSubpath()
        return path
    }
}
