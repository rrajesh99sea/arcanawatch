import SwiftUI

/// Hour and minute dauphine hands with metallic gradient and shadow.
struct HandsView: View {
    let diameter: CGFloat
    let date: Date

    private var hourAngle: Angle {
        .degrees(AngleCalculations.hourAngle(from: date))
    }
    private var minuteAngle: Angle {
        .degrees(AngleCalculations.minuteAngle(from: date))
    }

    var body: some View {
        ZStack {
            // Hour hand
            handView(
                length: diameter * WatchConstants.hourHandLength,
                baseWidth: diameter * WatchConstants.hourHandBaseWidth,
                tailLength: diameter * 0.04,
                angle: hourAngle
            )

            // Minute hand
            handView(
                length: diameter * WatchConstants.minuteHandLength,
                baseWidth: diameter * WatchConstants.minuteHandBaseWidth,
                tailLength: diameter * 0.05,
                angle: minuteAngle
            )
        }
        .frame(width: diameter, height: diameter)
    }

    private func handView(length: CGFloat, baseWidth: CGFloat,
                           tailLength: CGFloat, angle: Angle) -> some View {
        DauphineHandShape(length: length, baseWidth: baseWidth, tailLength: tailLength)
            .fill(
                LinearGradient(
                    colors: [
                        WatchConstants.silverDark,
                        WatchConstants.silverLight,
                        WatchConstants.silverLight,
                        WatchConstants.silverDark
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
            .frame(width: diameter, height: diameter)
            .rotationEffect(angle)
    }
}
