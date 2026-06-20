import SwiftUI

/// Concentric activity rings: Move (red), Exercise (green), Stand (blue).
struct ActivityRingsView: View {
    let diameter: CGFloat
    let moveProgress: Double
    let exerciseProgress: Double
    let standProgress: Double

    private let moveColor = Color.red
    private let exerciseColor = Color.green
    private let standColor = Color(red: 0.0, green: 0.75, blue: 1.0)

    var body: some View {
        ZStack {
            // Background tracks
            ringTrack(radius: diameter * 0.42, color: moveColor)
            ringTrack(radius: diameter * 0.32, color: exerciseColor)
            ringTrack(radius: diameter * 0.22, color: standColor)

            // Filled arcs
            ringArc(radius: diameter * 0.42, progress: moveProgress, color: moveColor)
            ringArc(radius: diameter * 0.32, progress: exerciseProgress, color: exerciseColor)
            ringArc(radius: diameter * 0.22, progress: standProgress, color: standColor)
        }
        .frame(width: diameter, height: diameter)
    }

    private func ringTrack(radius: CGFloat, color: Color) -> some View {
        Circle()
            .stroke(color.opacity(0.2), lineWidth: diameter * 0.08)
            .frame(width: radius, height: radius)
    }

    private func ringArc(radius: CGFloat, progress: Double, color: Color) -> some View {
        Circle()
            .trim(from: 0, to: min(progress, 2.0))
            .stroke(color, style: StrokeStyle(lineWidth: diameter * 0.08, lineCap: .round))
            .frame(width: radius, height: radius)
            .rotationEffect(.degrees(-90))
    }
}
