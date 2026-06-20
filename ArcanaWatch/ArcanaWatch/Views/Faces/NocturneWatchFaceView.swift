import SwiftUI

/// Art Deco night watch with midnight purple/navy palette.
struct NocturneWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let midnight = Color(red: 0.10, green: 0.09, blue: 0.19)
    private let deepPurple = Color(red: 0.05, green: 0.04, blue: 0.12)
    private let platinum = Color(red: 0.78, green: 0.76, blue: 0.82)
    private let violet = Color(red: 0.55, green: 0.40, blue: 0.75)
    private let dimGold = Color(red: 0.72, green: 0.65, blue: 0.50)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Platinum case
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [platinum, platinum.opacity(0.5), platinum],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: diameter * 0.025
                        )
                        .frame(width: diameter, height: diameter)

                    // Midnight dial
                    Circle()
                        .fill(RadialGradient(
                            colors: [midnight, deepPurple],
                            center: .center, startRadius: 0, endRadius: diameter * 0.46
                        ))
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // Art Deco concentric rings
                    decoRings(diameter: diameter)

                    // Diamond accents at 45° positions
                    decoAccents(diameter: diameter)

                    // Roman numerals
                    romanNumerals(diameter: diameter)

                    // Complications
                    // 12: Temp Art Deco panel
                    decoTempPanel(diameter: diameter)
                        .offset(y: -diameter * 0.24)

                    // 9: Battery purple arc
                    nocturneBattery(diameter: diameter)
                        .offset(x: -diameter * 0.22)

                    // 3: Rain droplet
                    nocturneRain(diameter: diameter)
                        .offset(x: diameter * 0.22)

                    // 6: Activity deco bars
                    nocturneActivity(diameter: diameter)
                        .offset(y: diameter * 0.24)

                    // Art Deco hands
                    nocturneHands(diameter: diameter, date: date)

                    // Purple center jewel
                    ZStack {
                        Circle()
                            .fill(RadialGradient(
                                colors: [violet, deepPurple],
                                center: .center, startRadius: 0, endRadius: diameter * 0.025
                            ))
                            .frame(width: diameter * 0.04, height: diameter * 0.04)
                        Circle()
                            .fill(deepPurple)
                            .frame(width: diameter * 0.015, height: diameter * 0.015)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Deco Rings

    private func decoRings(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(violet.opacity(0.15), lineWidth: 0.5)
                .frame(width: diameter * 0.82, height: diameter * 0.82)
            Circle()
                .stroke(violet.opacity(0.10), lineWidth: 0.5)
                .frame(width: diameter * 0.72, height: diameter * 0.72)
            Circle()
                .stroke(violet.opacity(0.08), lineWidth: 0.5)
                .frame(width: diameter * 0.58, height: diameter * 0.58)
        }
    }

    // MARK: - Diamond Accents

    private func decoAccents(diameter: CGFloat) -> some View {
        ForEach([45.0, 135.0, 225.0, 315.0], id: \.self) { deg in
            let r = diameter * 0.385
            let angle = Angle.degrees(deg - 90)
            Diamond()
                .fill(violet.opacity(0.25))
                .frame(width: diameter * 0.012, height: diameter * 0.025)
                .offset(
                    x: r * CGFloat(cos(angle.radians)),
                    y: r * CGFloat(sin(angle.radians))
                )
                .rotationEffect(.degrees(deg))
        }
    }

    // MARK: - Roman Numerals

    private func romanNumerals(diameter: CGFloat) -> some View {
        let r = diameter * 0.35
        let allRomans: [(Int, String)] = [
            (12, "XII"), (1, "I"), (2, "II"), (3, "III"), (4, "IV"), (5, "V"),
            (6, "VI"), (7, "VII"), (8, "VIII"), (9, "IX"), (10, "X"), (11, "XI")
        ]
        return ForEach(allRomans, id: \.0) { hour, text in
            let angle = Angle.degrees(Double(hour) * 30 - 90)
            let major = [12, 3, 6, 9].contains(hour)
            Text(text)
                .font(.custom("Georgia", size: diameter * (major ? WatchConstants.fontNumeralLg : WatchConstants.fontBody)))
                .foregroundColor(major ? dimGold : dimGold.opacity(0.5))
                .offset(
                    x: r * CGFloat(cos(angle.radians)),
                    y: r * CGFloat(sin(angle.radians))
                )
        }
    }

    // MARK: - Complications

    private func decoTempPanel(diameter: CGFloat) -> some View {
        ZStack {
            // Art Deco frame
            RoundedRectangle(cornerRadius: 2)
                .stroke(violet.opacity(0.3), lineWidth: 0.5)
                .frame(width: diameter * 0.16, height: diameter * 0.075)
            Text("\(Int(weather.temperatureValue))°F")
                .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                .foregroundColor(dimGold)
        }
    }

    private func nocturneBattery(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 1.0)
                .stroke(violet.opacity(0.15), lineWidth: 2)
                .frame(width: diameter * 0.12, height: diameter * 0.12)
            Circle()
                .trim(from: 0.25, to: 0.25 + 0.75 * CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2 ? violet : Color.red,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: diameter * 0.12, height: diameter * 0.12)
            Text("\(Int(battery.level * 100))")
                .font(.system(size: diameter * WatchConstants.fontCaption, design: .monospaced))
                .foregroundColor(platinum.opacity(0.6))
        }
    }

    private func nocturneRain(diameter: CGFloat) -> some View {
        VStack(spacing: 2) {
            // Stylized droplet
            Image(systemName: weather.isRaining ? "drop.fill" : "drop")
                .font(.system(size: diameter * WatchConstants.fontBody))
                .foregroundColor(violet)
            Text("\(Int(weather.rainChance * 100))%")
                .font(.system(size: diameter * WatchConstants.fontBody, design: .monospaced))
                .foregroundColor(platinum.opacity(0.5))
        }
    }

    private func nocturneActivity(diameter: CGFloat) -> some View {
        HStack(spacing: diameter * 0.01) {
            decoBar(progress: activity.moveProgress, color: .red, diameter: diameter)
            decoBar(progress: activity.exerciseProgress, color: .green, diameter: diameter)
            decoBar(progress: activity.standProgress, color: violet, diameter: diameter)
        }
    }

    private func decoBar(progress: Double, color: Color, diameter: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 1)
                .fill(color.opacity(0.15))
                .frame(width: diameter * 0.015, height: diameter * 0.06)
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: diameter * 0.015, height: diameter * 0.06 * min(CGFloat(progress), 1.0))
        }
    }

    // MARK: - Hands

    private func nocturneHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))

        return ZStack {
            // Art Deco dauphine hands
            DauphineHandShape(
                length: diameter * 0.26,
                baseWidth: diameter * 0.030,
                tailLength: diameter * 0.04
            )
            .fill(LinearGradient(
                colors: [platinum.opacity(0.6), platinum, platinum, platinum.opacity(0.6)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            DauphineHandShape(
                length: diameter * 0.38,
                baseWidth: diameter * 0.022,
                tailLength: diameter * 0.05
            )
            .fill(LinearGradient(
                colors: [platinum.opacity(0.6), platinum, platinum, platinum.opacity(0.6)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Purple seconds
            SubdialHandShape(length: diameter * 0.40, tailLength: diameter * 0.08, width: 1)
                .fill(violet)
                .frame(width: diameter, height: diameter)
                .rotationEffect(secondAngle)
        }
    }
}

// MARK: - Diamond Shape

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
