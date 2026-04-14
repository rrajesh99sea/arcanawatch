import SwiftUI

/// Small seconds subdial at 6 o'clock.
struct SecondsSubdialView: View {
    let watchDiameter: CGFloat
    let date: Date

    private var subdialDiameter: CGFloat {
        watchDiameter * WatchConstants.subdialDiameter
    }
    private var offset: CGFloat {
        watchDiameter * WatchConstants.subdialOffset
    }
    private var secondAngle: Angle {
        .degrees(AngleCalculations.secondAngle(from: date))
    }

    var body: some View {
        SubdialView(diameter: subdialDiameter) {
            // Seconds needle
            SubdialHandShape(
                length: subdialDiameter * 0.38,
                tailLength: subdialDiameter * 0.1,
                width: 1
            )
            .fill(WatchConstants.silver)
            .frame(width: subdialDiameter, height: subdialDiameter)
            .rotationEffect(secondAngle)

            // Center dot
            Circle()
                .fill(WatchConstants.silver)
                .frame(width: 3, height: 3)
        }
        .offset(y: offset)
    }
}
