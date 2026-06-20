import SwiftUI

/// German dress watch with off-center dial and outsize date (Lange-inspired).
struct LongitudeWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let goldLight = Color(red: 0.85, green: 0.72, blue: 0.35)
    private let goldDark = Color(red: 0.65, green: 0.52, blue: 0.15)
    private let creamDial = Color(red: 0.96, green: 0.94, blue: 0.88)
    private let warmGray = Color(red: 0.45, green: 0.42, blue: 0.38)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Gold case bezel
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [goldLight, goldDark, goldLight, goldDark, goldLight],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: diameter * 0.03
                        )
                        .frame(width: diameter, height: diameter)

                    // Cream dial
                    Circle()
                        .fill(creamDial)
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // Off-center main dial (shifted up-left)
                    offCenterDial(diameter: diameter, date: date)

                    // Complications arranged in a clean Lange-1 asymmetric layout:
                    // ALL three sit in the right margin clear of the off-center main dial.
                    // Upper right — outsize temperature (Lange's signature outsize-date)
                    outsizeTempDisplay(diameter: diameter)
                        .offset(x: diameter * 0.27, y: -diameter * 0.20)

                    // Right-middle — activity rings (acts as the small-seconds subdial)
                    ActivityRingsView(
                        diameter: diameter * 0.13,
                        moveProgress: activity.moveProgress,
                        exerciseProgress: activity.exerciseProgress,
                        standProgress: activity.standProgress
                    )
                    .offset(x: diameter * 0.29, y: diameter * 0.02)

                    // Right-bottom — battery arc (acts as the power-reserve indicator)
                    batteryArc(diameter: diameter)
                        .offset(x: diameter * 0.29, y: diameter * 0.22)

                    // Bottom — discreet rain readout, balanced under the main dial
                    rainDisplay(diameter: diameter)
                        .offset(x: -diameter * 0.04, y: diameter * 0.36)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Off-Center Dial

    private func offCenterDial(diameter: CGFloat, date: Date) -> some View {
        let subDiameter = diameter * 0.62
        let offset = CGPoint(x: -diameter * 0.06, y: -diameter * 0.06)

        return ZStack {
            // Thin circle border for the subdial
            Circle()
                .stroke(warmGray.opacity(0.3), lineWidth: 0.5)
                .frame(width: subDiameter, height: subDiameter)

            // Tick marks
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let r = subDiameter / 2 - 2
                for i in 0..<60 {
                    let angle = Angle.degrees(Double(i) * 6 - 90)
                    let cosA = CGFloat(cos(angle.radians))
                    let sinA = CGFloat(sin(angle.radians))
                    let tickLen: CGFloat = i % 5 == 0 ? diameter * 0.025 : diameter * 0.01
                    let tickW: CGFloat = i % 5 == 0 ? 1 : 0.5
                    var tick = Path()
                    tick.move(to: CGPoint(x: center.x + cosA * r, y: center.y + sinA * r))
                    tick.addLine(to: CGPoint(x: center.x + cosA * (r - tickLen),
                                             y: center.y + sinA * (r - tickLen)))
                    context.stroke(tick, with: .color(warmGray.opacity(i % 5 == 0 ? 0.6 : 0.3)), lineWidth: tickW)
                }
            }
            .frame(width: subDiameter, height: subDiameter)
            .allowsHitTesting(false)

            // Roman numerals at 12, 3, 6, 9
            ForEach([(12, "XII"), (3, "III"), (6, "VI"), (9, "IX")], id: \.0) { hour, text in
                let angle = Angle.degrees(Double(hour) * 30 - 90)
                let r = subDiameter / 2 - diameter * 0.055
                Text(text)
                    .font(.custom("Georgia", size: diameter * WatchConstants.fontNumeral))
                    .foregroundColor(warmGray)
                    .offset(
                        x: r * CGFloat(cos(angle.radians)),
                        y: r * CGFloat(sin(angle.radians))
                    )
            }

            // Gold dauphine hands
            longitudeHands(diameter: subDiameter, date: date)
        }
        .offset(x: offset.x, y: offset.y)
    }

    private func longitudeHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))

        return ZStack {
            DauphineHandShape(
                length: diameter * 0.30,
                baseWidth: diameter * 0.04,
                tailLength: diameter * 0.05
            )
            .fill(LinearGradient(
                colors: [goldDark, goldLight, goldLight, goldDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            DauphineHandShape(
                length: diameter * 0.42,
                baseWidth: diameter * 0.028,
                tailLength: diameter * 0.06
            )
            .fill(LinearGradient(
                colors: [goldDark, goldLight, goldLight, goldDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Gold center dot
            Circle()
                .fill(goldLight)
                .frame(width: diameter * 0.03, height: diameter * 0.03)
        }
    }

    // MARK: - Outsize Temperature Display

    private func outsizeTempDisplay(diameter: CGFloat) -> some View {
        HStack(spacing: 1) {
            // Tens digit
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: diameter * 0.055, height: diameter * 0.070)
                RoundedRectangle(cornerRadius: 2)
                    .stroke(warmGray.opacity(0.3), lineWidth: 0.5)
                    .frame(width: diameter * 0.055, height: diameter * 0.070)
                Text("\(Int(weather.temperatureValue) / 10)")
                    .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                    .foregroundColor(.black)
            }
            // Ones digit
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: diameter * 0.055, height: diameter * 0.070)
                RoundedRectangle(cornerRadius: 2)
                    .stroke(warmGray.opacity(0.3), lineWidth: 0.5)
                    .frame(width: diameter * 0.055, height: diameter * 0.070)
                Text("\(Int(weather.temperatureValue) % 10)°")
                    .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                    .foregroundColor(.black)
            }
        }
    }

    // MARK: - Rain

    private func rainDisplay(diameter: CGFloat) -> some View {
        HStack(spacing: 2) {
            Image(systemName: weather.isRaining ? "cloud.rain.fill" : "drop")
                .font(.system(size: diameter * WatchConstants.fontBody))
            Text("\(Int(weather.rainChance * 100))%")
                .font(.custom("Georgia", size: diameter * WatchConstants.fontValue))
        }
        .foregroundColor(warmGray.opacity(0.6))
    }

    // MARK: - Battery

    private func batteryArc(diameter: CGFloat) -> some View {
        let arcD = diameter * 0.16
        return ZStack {
            Circle()
                .stroke(warmGray.opacity(0.2), lineWidth: 0.5)
                .frame(width: arcD, height: arcD)

            // Small seconds-style battery arc
            Circle()
                .trim(from: 0.0, to: CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2 ? goldLight : Color.red,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                .frame(width: arcD * 0.8, height: arcD * 0.8)
                .rotationEffect(.degrees(-90))

            Text("\(Int(battery.level * 100))%")
                .font(.system(size: diameter * WatchConstants.fontCaption, design: .monospaced))
                .foregroundColor(warmGray)
        }
    }
}
