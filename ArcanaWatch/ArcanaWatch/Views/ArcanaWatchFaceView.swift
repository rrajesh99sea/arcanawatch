import SwiftUI

/// Root container: assembles all layers of the Arcana watch face.
/// Uses TimelineView as the single update driver — no Timer objects needed.
struct ArcanaWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

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

                    // Weather temp near 12 o'clock
                    HStack(spacing: 2) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: diameter * WatchConstants.fontBody))
                        Text("\(Int(weather.temperatureValue))°")
                            .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(WatchConstants.silver)
                    .offset(y: -diameter * 0.18)

                    // Rain indicator near top
                    HStack(spacing: 2) {
                        Image(systemName: weather.isRaining ? "cloud.rain.fill" : "drop")
                            .font(.system(size: diameter * WatchConstants.fontBody))
                        Text("\(Int(weather.rainChance * 100))%")
                            .font(.system(size: diameter * WatchConstants.fontBody, design: .monospaced))
                    }
                    .foregroundColor(WatchConstants.silverDark)
                    .offset(y: -diameter * 0.28)

                    // Activity rings around seconds subdial at 6 o'clock
                    ZStack {
                        Circle()
                            .trim(from: 0, to: min(activity.moveProgress, 1.0))
                            .stroke(Color.red.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: diameter * 0.16, height: diameter * 0.16)
                            .rotationEffect(.degrees(-90))
                        Circle()
                            .trim(from: 0, to: min(activity.exerciseProgress, 1.0))
                            .stroke(Color.green.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: diameter * 0.13, height: diameter * 0.13)
                            .rotationEffect(.degrees(-90))
                        Circle()
                            .trim(from: 0, to: min(activity.standProgress, 1.0))
                            .stroke(Color.cyan.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: diameter * 0.10, height: diameter * 0.10)
                            .rotationEffect(.degrees(-90))
                    }
                    .offset(y: diameter * WatchConstants.subdialOffset)

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
        ArcanaWatchFaceView(
            battery: BatteryModel(),
            weather: WeatherModel(),
            activity: ActivityModel()
        )
        .previewDevice("Apple Watch Series 9 - 45mm")
    }
}
#endif
