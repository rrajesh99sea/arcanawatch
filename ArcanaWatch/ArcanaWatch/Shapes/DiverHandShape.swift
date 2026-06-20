import SwiftUI

/// Broad-arrow diver hand matching the HTML _drawDiverHand exactly.
/// baseWidth = full width of the base, upper, and tip sections.
/// Shoulder section (30%–70% of length) flares to ~1.67× the base width.
/// The tip is flat (rectangular). The body fill is dark with a lume stripe overlay.
struct DiverHandShape: Shape {
    let length: CGFloat
    let baseWidth: CGFloat
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let hw = baseWidth / 2        // half base-width
        let fw = baseWidth / 1.2      // flare half-width (w/1.2 in HTML)

        var path = Path()
        // Tail
        path.move(to: CGPoint(x: midX - hw, y: midY + tailLength))
        path.addLine(to: CGPoint(x: midX - hw, y: midY))
        // Narrow shaft up to shoulder start (30%)
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.30))
        // Shoulder step out
        path.addLine(to: CGPoint(x: midX - fw, y: midY - length * 0.30))
        // Shoulder top (70%)
        path.addLine(to: CGPoint(x: midX - fw, y: midY - length * 0.70))
        // Shoulder step back in
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.70))
        // Up to flat tip
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length))
        // Mirror right
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX + fw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX + fw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX + hw, y: midY))
        path.addLine(to: CGPoint(x: midX + hw, y: midY + tailLength))
        path.closeSubpath()
        return path
    }
}
