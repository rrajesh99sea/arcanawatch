import SwiftUI

/// Decorative silver center jewel at the axis of the hands.
struct CenterPinView: View {
    let diameter: CGFloat

    private var pinRadius: CGFloat { diameter * WatchConstants.centerPinRadius }
    private var dotRadius: CGFloat { diameter * WatchConstants.centerDotRadius }

    var body: some View {
        ZStack {
            // Outer polished ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            WatchConstants.silverLight,
                            WatchConstants.silver,
                            WatchConstants.silverDark
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: pinRadius
                    )
                )
                .frame(width: pinRadius * 2, height: pinRadius * 2)

            // Inner dark dot
            Circle()
                .fill(WatchConstants.dialBlack)
                .frame(width: dotRadius * 2, height: dotRadius * 2)
        }
    }
}
