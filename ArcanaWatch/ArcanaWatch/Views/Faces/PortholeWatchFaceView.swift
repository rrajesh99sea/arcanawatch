import SwiftUI

/// Nautical/diver watch with octagonal case and navy blue dial.
struct PortholeWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let navyBlue = Color(red: 0.18, green: 0.30, blue: 0.42)
    private let steelLight = Color(red: 0.82, green: 0.84, blue: 0.86)
    private let steelDark = Color(red: 0.45, green: 0.47, blue: 0.49)
    private let screwColor = Color(red: 0.60, green: 0.62, blue: 0.64)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Octagonal case
                    octagonalBezel(diameter: diameter)

                    // Navy dial with stripe texture
                    navyDial(diameter: diameter)

                    // Hour markers
                    hourMarkers(diameter: diameter)

                    // Complications
                    complicationTemp(diameter: diameter)
                        .offset(y: -diameter * 0.28)

                    complicationActivity(diameter: diameter)
                        .offset(x: diameter * 0.26)

                    complicationRain(diameter: diameter)
                        .offset(y: diameter * 0.28)

                    complicationBattery(diameter: diameter)
                        .offset(x: -diameter * 0.26)

                    // Hands
                    portholeHands(diameter: diameter, date: date)

                    // Center pin
                    CenterPinView(diameter: diameter)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Octagonal Bezel

    private func octagonalBezel(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter / 2
            let innerR = outerR * 0.95

            // Outer octagon
            let outerPath = octagonPath(center: center, radius: outerR)
            context.fill(outerPath, with: .linearGradient(
                Gradient(colors: [steelLight, steelDark, steelLight]),
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: size.width, y: size.height)
            ))

            // Inner octagon cutout
            let innerPath = octagonPath(center: center, radius: innerR)
            context.fill(innerPath, with: .color(navyBlue))

            // Screws at corners
            for i in 0..<8 {
                let angle = Angle.degrees(Double(i) * 45 + 22.5)
                let screwR = (outerR + innerR) / 2
                let sx = center.x + screwR * CGFloat(cos(angle.radians))
                let sy = center.y + screwR * CGFloat(sin(angle.radians))
                let screwSize: CGFloat = diameter * 0.02
                let screwRect = CGRect(x: sx - screwSize, y: sy - screwSize,
                                       width: screwSize * 2, height: screwSize * 2)
                context.fill(Path(ellipseIn: screwRect), with: .color(screwColor))
                // Cross slot
                var h = Path()
                h.move(to: CGPoint(x: sx - screwSize * 0.6, y: sy))
                h.addLine(to: CGPoint(x: sx + screwSize * 0.6, y: sy))
                var v = Path()
                v.move(to: CGPoint(x: sx, y: sy - screwSize * 0.6))
                v.addLine(to: CGPoint(x: sx, y: sy + screwSize * 0.6))
                context.stroke(h, with: .color(.black.opacity(0.5)), lineWidth: 0.5)
                context.stroke(v, with: .color(.black.opacity(0.5)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    private func octagonPath(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for i in 0..<8 {
            let angle = Angle.degrees(Double(i) * 45 + 22.5)
            let pt = CGPoint(
                x: center.x + radius * CGFloat(cos(angle.radians)),
                y: center.y + radius * CGFloat(sin(angle.radians))
            )
            if i == 0 { path.move(to: pt) }
            else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Navy Dial

    private func navyDial(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = diameter * 0.44

            // Stripe texture (horizontal lines)
            for i in stride(from: -r, through: r, by: 3) {
                var line = Path()
                let x1 = center.x - sqrt(max(0, r * r - i * i))
                let x2 = center.x + sqrt(max(0, r * r - i * i))
                line.move(to: CGPoint(x: x1, y: center.y + i))
                line.addLine(to: CGPoint(x: x2, y: center.y + i))
                context.stroke(line, with: .color(.white.opacity(0.03)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hour Markers

    private func hourMarkers(diameter: CGFloat) -> some View {
        let dialR = diameter * 0.42
        return ZStack {
            // Arabic numerals at 12, 3, 6, 9
            ForEach([12, 3, 6, 9], id: \.self) { hour in
                let angle = Angle.degrees(Double(hour) * 30 - 90)
                let r = dialR - diameter * 0.07
                Text("\(hour)")
                    .font(.system(size: diameter * WatchConstants.fontNumeralLg, weight: .bold, design: .default))
                    .foregroundColor(steelLight)
                    .offset(
                        x: r * CGFloat(cos(angle.radians)),
                        y: r * CGFloat(sin(angle.radians))
                    )
            }
            // Baton indices at other hours
            ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                Rectangle()
                    .fill(steelLight)
                    .frame(width: diameter * 0.008, height: diameter * 0.04)
                    .offset(y: -(dialR - diameter * 0.04))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
        }
    }

    // MARK: - Complications

    private func complicationTemp(diameter: CGFloat) -> some View {
        VStack(spacing: 1) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: diameter * WatchConstants.fontBody))
                .foregroundColor(steelLight.opacity(0.7))
            Text("\(Int(weather.temperatureValue))°")
                .font(.system(size: diameter * WatchConstants.fontValueLg, weight: .medium, design: .monospaced))
                .foregroundColor(steelLight)
        }
    }

    private func complicationActivity(diameter: CGFloat) -> some View {
        VStack(spacing: 2) {
            gaugeBar(progress: activity.moveProgress, color: .red, diameter: diameter)
            gaugeBar(progress: activity.exerciseProgress, color: .green, diameter: diameter)
            gaugeBar(progress: activity.standProgress, color: .cyan, diameter: diameter)
        }
    }

    private func gaugeBar(progress: Double, color: Color, diameter: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.2))
                .frame(width: diameter * 0.08, height: diameter * 0.015)
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: diameter * 0.08 * min(CGFloat(progress), 1.0), height: diameter * 0.015)
        }
    }

    private func complicationRain(diameter: CGFloat) -> some View {
        HStack(spacing: 2) {
            Image(systemName: weather.isRaining ? "cloud.rain.fill" : "drop")
                .font(.system(size: diameter * WatchConstants.fontBody))
                .foregroundColor(.cyan.opacity(0.8))
            Text("\(Int(weather.rainChance * 100))%")
                .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                .foregroundColor(steelLight.opacity(0.8))
        }
    }

    private func complicationBattery(diameter: CGFloat) -> some View {
        ZStack {
            // Background arc
            Circle()
                .trim(from: 0.25, to: 1.0)
                .stroke(steelDark.opacity(0.3), lineWidth: 2)
                .frame(width: diameter * 0.12, height: diameter * 0.12)

            // Filled arc
            Circle()
                .trim(from: 0.25, to: 0.25 + 0.75 * CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2 ? steelLight : Color.red,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: diameter * 0.12, height: diameter * 0.12)

            Text("\(Int(battery.level * 100))")
                .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                .foregroundColor(steelLight.opacity(0.8))
        }
    }

    // MARK: - Hands

    private func portholeHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))

        return ZStack {
            // Hour
            DauphineHandShape(
                length: diameter * 0.28,
                baseWidth: diameter * 0.03,
                tailLength: diameter * 0.04
            )
            .fill(LinearGradient(
                colors: [steelDark, steelLight, steelLight, steelDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            // Minute
            DauphineHandShape(
                length: diameter * 0.40,
                baseWidth: diameter * 0.022,
                tailLength: diameter * 0.05
            )
            .fill(LinearGradient(
                colors: [steelDark, steelLight, steelLight, steelDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Seconds hand (red)
            SubdialHandShape(length: diameter * 0.42, tailLength: diameter * 0.08, width: 1.5)
                .fill(Color.red)
                .frame(width: diameter, height: diameter)
                .rotationEffect(secondAngle)
        }
    }
}
