import SwiftUI

/// Ultra-thin minimalist dress watch with white dial and leaf hands.
struct SilhouetteWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let goldLight = Color(red: 0.82, green: 0.70, blue: 0.38)
    private let goldDark = Color(red: 0.60, green: 0.48, blue: 0.18)
    private let creamWhite = Color(red: 0.97, green: 0.96, blue: 0.93)
    private let warmGray = Color(red: 0.55, green: 0.52, blue: 0.48)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    // Light background
                    Color(red: 0.94, green: 0.93, blue: 0.90)

                    // Gold case
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [goldLight, goldDark, goldLight, goldDark, goldLight],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: diameter * 0.025
                        )
                        .frame(width: diameter, height: diameter)

                    // White lacquer dial
                    Circle()
                        .fill(creamWhite)
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // Subtle guilloche
                    guillochePattern(diameter: diameter)

                    // Hour markers
                    silhouetteMarkers(diameter: diameter)

                    // Complications
                    // 12: Temperature
                    Text("\(Int(weather.temperatureValue))°")
                        .font(.custom("Georgia", size: diameter * WatchConstants.fontValue))
                        .foregroundColor(goldDark.opacity(0.6))
                        .offset(y: -diameter * 0.26)

                    // 9: Battery arc
                    silhouetteBattery(diameter: diameter)
                        .offset(x: -diameter * 0.22)

                    // 3: Rain dot
                    silhouetteRain(diameter: diameter)
                        .offset(x: diameter * 0.24)

                    // 6: Activity rings (thin)
                    silhouetteActivity(diameter: diameter)
                        .offset(y: diameter * 0.22)

                    // Leaf hands
                    silhouetteHands(diameter: diameter, date: date)

                    // Small gold center dot
                    Circle()
                        .fill(goldLight)
                        .frame(width: diameter * 0.02, height: diameter * 0.02)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Guilloche

    private func guillochePattern(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxR = diameter * 0.42

            // Concentric wavy rings
            for ring in stride(from: diameter * 0.06, through: maxR, by: diameter * 0.04) {
                var wavePath = Path()
                let waves = 8
                for deg in stride(from: 0.0, through: 360.0, by: 2.0) {
                    let angle = Angle.degrees(deg)
                    let waveOffset = sin(Double(waves) * angle.radians) * 1.5
                    let r = ring + CGFloat(waveOffset)
                    let pt = CGPoint(
                        x: center.x + r * CGFloat(cos(angle.radians)),
                        y: center.y + r * CGFloat(sin(angle.radians))
                    )
                    if deg == 0 { wavePath.move(to: pt) }
                    else { wavePath.addLine(to: pt) }
                }
                wavePath.closeSubpath()
                context.stroke(wavePath, with: .color(warmGray.opacity(0.06)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Markers

    private func silhouetteMarkers(diameter: CGFloat) -> some View {
        let r = diameter * 0.40
        return ZStack {
            // Gold batons at quarters
            ForEach([12, 3, 6, 9], id: \.self) { hour in
                Rectangle()
                    .fill(goldLight)
                    .frame(width: diameter * 0.012, height: diameter * 0.05)
                    .offset(y: -(r - diameter * 0.025))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
            // Tiny gold dots at other hours
            ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                Circle()
                    .fill(goldLight)
                    .frame(width: diameter * 0.008, height: diameter * 0.008)
                    .offset(y: -(r - diameter * 0.01))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
        }
    }

    // MARK: - Battery

    private func silhouetteBattery(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(warmGray.opacity(0.1), lineWidth: 1.5)
                .frame(width: diameter * 0.10, height: diameter * 0.10)
            Circle()
                .trim(from: 0.0, to: CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2 ? goldLight : Color.red,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                .frame(width: diameter * 0.10, height: diameter * 0.10)
                .rotationEffect(.degrees(-90))
        }
    }

    // MARK: - Rain

    private func silhouetteRain(diameter: CGFloat) -> some View {
        VStack(spacing: 1) {
            Circle()
                .fill(weather.isRaining ? Color.blue.opacity(0.5) : warmGray.opacity(0.15))
                .frame(width: diameter * 0.018, height: diameter * 0.018)
            Text("\(Int(weather.rainChance * 100))%")
                .font(.system(size: diameter * WatchConstants.fontBody))
                .foregroundColor(warmGray.opacity(0.5))
        }
    }

    // MARK: - Activity

    private func silhouetteActivity(diameter: CGFloat) -> some View {
        ZStack {
            // Thin concentric rings
            Circle()
                .trim(from: 0, to: min(activity.moveProgress, 1.0))
                .stroke(Color.red.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: diameter * 0.13, height: diameter * 0.13)
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: min(activity.exerciseProgress, 1.0))
                .stroke(Color.green.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: diameter * 0.10, height: diameter * 0.10)
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: min(activity.standProgress, 1.0))
                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: diameter * 0.07, height: diameter * 0.07)
                .rotationEffect(.degrees(-90))
        }
    }

    // MARK: - Hands

    private func silhouetteHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))

        return ZStack {
            LeafHandShape(
                length: diameter * 0.28,
                maxWidth: diameter * 0.035,
                tailLength: diameter * 0.03
            )
            .fill(LinearGradient(
                colors: [goldDark, goldLight, goldLight, goldDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            LeafHandShape(
                length: diameter * 0.40,
                maxWidth: diameter * 0.025,
                tailLength: diameter * 0.04
            )
            .fill(LinearGradient(
                colors: [goldDark, goldLight, goldLight, goldDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)
        }
    }
}
