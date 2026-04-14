import SwiftUI

/// Root container: assembles all layers of the Arcana watch face.
/// Uses TimelineView as the single update driver — no Timer objects needed.
struct ArcanaWatchFaceView: View {
    @StateObject private var battery = BatteryModel()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    // Full black background
                    Color.black

                    // Bezel (static)
                    BezelView(diameter: diameter)

                    // Dial with sunburst, ticks, indices, numerals (static)
                    DialView(diameter: diameter)

                    // Small seconds at 6 o'clock (updates every second)
                    SecondsSubdialView(watchDiameter: diameter, date: date)

                    // Date window at 3 o'clock (updates at midnight)
                    DateSubdialView(watchDiameter: diameter, date: date)

                    // Battery gauge at 9 o'clock (updates every 60s)
                    BatterySubdialView(watchDiameter: diameter, battery: battery)

                    // Hour + minute dauphine hands (updates every second)
                    HandsView(diameter: diameter, date: date)

                    // Center jewel (static)
                    CenterPinView(diameter: diameter)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
struct ArcanaWatchFaceView_Previews: PreviewProvider {
    static var previews: some View {
        ArcanaWatchFaceView()
            .previewDevice("Apple Watch Series 9 - 45mm")
    }
}
#endif
