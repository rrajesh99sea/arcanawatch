import SwiftUI

/// A tapered baton shape for hour markers — wider at the outer edge, narrower inward.
struct BatonIndexShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topWidth = rect.width
        let bottomWidth = rect.width * 0.6
        // Top (outer edge) — full width
        path.move(to: CGPoint(x: (rect.width - topWidth) / 2, y: 0))
        path.addLine(to: CGPoint(x: (rect.width + topWidth) / 2, y: 0))
        // Bottom (inner edge) — tapered
        path.addLine(to: CGPoint(x: (rect.width + bottomWidth) / 2, y: rect.height))
        path.addLine(to: CGPoint(x: (rect.width - bottomWidth) / 2, y: rect.height))
        path.closeSubpath()
        return path
    }
}
