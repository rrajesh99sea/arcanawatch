import SwiftUI

/// Battery arc gauge subdial at 9 o'clock.
struct BatterySubdialView: View {
    let watchDiameter: CGFloat
    @ObservedObject var battery: BatteryModel

    private var subdialDiameter: CGFloat {
        watchDiameter * WatchConstants.subdialDiameter
    }
    private var offset: CGFloat {
        watchDiameter * WatchConstants.subdialOffset
    }
    private var arcRadius: CGFloat { subdialDiameter * 0.35 }

    var body: some View {
        SubdialView(diameter: subdialDiameter) {
            // Background arc
            arcSegment(from: 0, to: 1)
                .stroke(WatchConstants.tickGray.opacity(0.4), lineWidth: 3)

            // Filled arc
            arcSegment(from: 0, to: CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2
                        ? WatchConstants.silver
                        : Color.red,
                    lineWidth: 3
                )

            // Percentage label
            Text("\(Int(battery.level * 100))%")
                .font(.custom(WatchConstants.romanFontName,
                              size: watchDiameter * WatchConstants.fontValue))
                .foregroundColor(WatchConstants.silver)
                .offset(y: subdialDiameter * 0.15)
        }
        .offset(x: -offset)
    }

    /// Arc from 135° (bottom-left) sweeping 270° clockwise.
    private func arcSegment(from start: CGFloat, to end: CGFloat) -> Path {
        let startAngle = Angle.degrees(135)
        let fullSweep = 270.0
        return Path { path in
            path.addArc(
                center: CGPoint(x: subdialDiameter / 2, y: subdialDiameter / 2),
                radius: arcRadius,
                startAngle: startAngle + .degrees(fullSweep * Double(start)),
                endAngle: startAngle + .degrees(fullSweep * Double(end)),
                clockwise: false
            )
        }
    }
}
