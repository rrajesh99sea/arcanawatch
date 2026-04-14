import SwiftUI

/// Thin polished silver bezel ring around the dial.
struct BezelView: View {
    let diameter: CGFloat

    private var outerRadius: CGFloat { diameter / 2 }
    private var bezelWidth: CGFloat { diameter * WatchConstants.bezelWidth }

    var body: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    colors: [
                        WatchConstants.silverLight,
                        WatchConstants.silver,
                        WatchConstants.silverDark,
                        WatchConstants.silver,
                        WatchConstants.silverLight
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: bezelWidth
            )
            .frame(width: diameter, height: diameter)
    }
}
