import SwiftUI

/// Gear/cog wheel shape for skeleton watch faces.
struct GearShape: Shape {
    let toothCount: Int
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let toothDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let anglePerTooth = 360.0 / Double(toothCount)
        let halfTooth = anglePerTooth / 4.0

        var path = Path()

        for i in 0..<toothCount {
            let baseAngle = Angle.degrees(Double(i) * anglePerTooth - 90)

            // Inner left
            let a1 = baseAngle - .degrees(halfTooth)
            let p1 = point(center: center, radius: innerRadius, angle: a1)
            // Outer left
            let a2 = baseAngle - .degrees(halfTooth * 0.6)
            let p2 = point(center: center, radius: outerRadius, angle: a2)
            // Outer right
            let a3 = baseAngle + .degrees(halfTooth * 0.6)
            let p3 = point(center: center, radius: outerRadius, angle: a3)
            // Inner right
            let a4 = baseAngle + .degrees(halfTooth)
            let p4 = point(center: center, radius: innerRadius, angle: a4)

            if i == 0 {
                path.move(to: p1)
            } else {
                path.addLine(to: p1)
            }
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
        }

        path.closeSubpath()

        // Center hole
        let holeRadius = innerRadius * 0.4
        path.addEllipse(in: CGRect(
            x: center.x - holeRadius,
            y: center.y - holeRadius,
            width: holeRadius * 2,
            height: holeRadius * 2
        ))

        return path
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y + radius * CGFloat(sin(angle.radians))
        )
    }
}
