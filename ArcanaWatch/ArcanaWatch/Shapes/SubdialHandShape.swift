import SwiftUI

/// Thin needle shape for subdial hands.
struct SubdialHandShape: Shape {
    let length: CGFloat
    let tailLength: CGFloat
    let width: CGFloat

    init(length: CGFloat, tailLength: CGFloat = 0, width: CGFloat = 1) {
        self.length = length
        self.tailLength = tailLength
        self.width = width
    }

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let halfW = width / 2

        var path = Path()
        // Tail
        path.move(to: CGPoint(x: midX - halfW, y: midY + tailLength))
        // Base to tip
        path.addLine(to: CGPoint(x: midX - halfW, y: midY))
        path.addLine(to: CGPoint(x: midX, y: midY - length))
        path.addLine(to: CGPoint(x: midX + halfW, y: midY))
        path.addLine(to: CGPoint(x: midX + halfW, y: midY + tailLength))
        path.closeSubpath()
        return path
    }
}
