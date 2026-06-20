import SwiftUI

/// Skeleton watch with visible animated gears and rose gold.
struct LatticeWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let roseGold = Color(red: 0.78, green: 0.52, blue: 0.35)
    private let roseGoldDark = Color(red: 0.55, green: 0.35, blue: 0.22)
    private let bgDark = Color(red: 0.06, green: 0.05, blue: 0.05)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.05)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date
                let seconds = date.timeIntervalSince1970

                ZStack {
                    Color.black

                    // Rose gold case
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [roseGold, roseGoldDark, roseGold, roseGoldDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: diameter * 0.03
                        )
                        .frame(width: diameter, height: diameter)

                    // Dark background
                    Circle()
                        .fill(bgDark)
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // Animated gears
                    gearAssembly(diameter: diameter, time: seconds)

                    // Bridge elements
                    bridgeElements(diameter: diameter)

                    // Chapter ring with numerals
                    chapterRing(diameter: diameter)

                    // Complications
                    // 9: Battery gear arc
                    latticeBattery(diameter: diameter)
                        .offset(x: -diameter * 0.22, y: diameter * 0.08)

                    // Bridge plate: Temperature
                    Text("\(Int(weather.temperatureValue))°")
                        .font(.system(size: diameter * WatchConstants.fontValue, weight: .medium, design: .monospaced))
                        .foregroundColor(roseGold.opacity(0.6))
                        .offset(x: diameter * 0.08, y: -diameter * 0.20)

                    // Small window: Rain
                    latticeRain(diameter: diameter)
                        .offset(x: diameter * 0.20, y: diameter * 0.12)

                    // 6: Activity through skeleton
                    ActivityRingsView(
                        diameter: diameter * 0.12,
                        moveProgress: activity.moveProgress,
                        exerciseProgress: activity.exerciseProgress,
                        standProgress: activity.standProgress
                    )
                    .offset(y: diameter * 0.22)

                    // Skeleton hands
                    latticeHands(diameter: diameter, date: date)

                    // Center
                    Circle()
                        .fill(roseGold)
                        .frame(width: diameter * 0.025, height: diameter * 0.025)
                    Circle()
                        .fill(bgDark)
                        .frame(width: diameter * 0.012, height: diameter * 0.012)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Gear Assembly

    private func gearAssembly(diameter: CGFloat, time: Double) -> some View {
        ZStack {
            // Main barrel (large, upper-left)
            GearShape(
                toothCount: 32,
                innerRadius: diameter * 0.08,
                outerRadius: diameter * 0.10,
                toothDepth: diameter * 0.015
            )
            .fill(roseGold.opacity(0.25))
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(time * 3))
            .offset(x: -diameter * 0.12, y: -diameter * 0.14)

            // Medium gear (right)
            GearShape(
                toothCount: 20,
                innerRadius: diameter * 0.05,
                outerRadius: diameter * 0.065,
                toothDepth: diameter * 0.012
            )
            .fill(roseGold.opacity(0.20))
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(-time * 5))
            .offset(x: diameter * 0.10, y: -diameter * 0.06)

            // Small gear (lower)
            GearShape(
                toothCount: 14,
                innerRadius: diameter * 0.03,
                outerRadius: diameter * 0.04,
                toothDepth: diameter * 0.008
            )
            .fill(roseGold.opacity(0.18))
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(time * 8))
            .offset(x: -diameter * 0.04, y: diameter * 0.10)

            // Tiny gear
            GearShape(
                toothCount: 10,
                innerRadius: diameter * 0.02,
                outerRadius: diameter * 0.028,
                toothDepth: diameter * 0.006
            )
            .fill(roseGold.opacity(0.15))
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(-time * 12))
            .offset(x: diameter * 0.16, y: diameter * 0.12)
        }
    }

    // MARK: - Bridges

    private func bridgeElements(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            // Diagonal bridges
            let bridges: [(CGPoint, CGPoint)] = [
                (CGPoint(x: center.x - diameter * 0.30, y: center.y - diameter * 0.20),
                 CGPoint(x: center.x + diameter * 0.15, y: center.y - diameter * 0.10)),
                (CGPoint(x: center.x - diameter * 0.15, y: center.y + diameter * 0.15),
                 CGPoint(x: center.x + diameter * 0.30, y: center.y + diameter * 0.05))
            ]

            for (start, end) in bridges {
                var bridge = Path()
                bridge.move(to: start)
                bridge.addLine(to: end)
                context.stroke(bridge, with: .color(roseGold.opacity(0.15)), lineWidth: diameter * 0.02)
                context.stroke(bridge, with: .color(roseGold.opacity(0.08)), lineWidth: diameter * 0.025)

                // Screw holes at ends
                for pt in [start, end] {
                    let holeR = diameter * 0.006
                    context.fill(
                        Path(ellipseIn: CGRect(x: pt.x - holeR, y: pt.y - holeR,
                                               width: holeR * 2, height: holeR * 2)),
                        with: .color(bgDark)
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Chapter Ring

    private func chapterRing(diameter: CGFloat) -> some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(roseGold.opacity(0.2), lineWidth: 0.5)
                .frame(width: diameter * 0.85, height: diameter * 0.85)

            // Numerals at quarters
            ForEach([(12, "XII"), (3, "III"), (6, "VI"), (9, "IX")], id: \.0) { hour, text in
                let angle = Angle.degrees(Double(hour) * 30 - 90)
                let r = diameter * 0.38
                Text(text)
                    .font(.custom("Georgia", size: diameter * WatchConstants.fontNumeral))
                    .foregroundColor(roseGold)
                    .offset(
                        x: r * CGFloat(cos(angle.radians)),
                        y: r * CGFloat(sin(angle.radians))
                    )
            }

            // Tick marks
            ForEach(0..<60, id: \.self) { i in
                if i % 5 != 0 {
                    Rectangle()
                        .fill(roseGold.opacity(0.2))
                        .frame(width: 0.5, height: diameter * 0.012)
                        .offset(y: -(diameter * 0.42))
                        .rotationEffect(.degrees(Double(i) * 6))
                }
            }
        }
    }

    // MARK: - Complications

    private func latticeBattery(diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 1.0)
                .stroke(roseGold.opacity(0.15), lineWidth: 2)
                .frame(width: diameter * 0.12, height: diameter * 0.12)
            Circle()
                .trim(from: 0.25, to: 0.25 + 0.75 * CGFloat(battery.level))
                .stroke(
                    battery.level > 0.2 ? roseGold : Color.red,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: diameter * 0.12, height: diameter * 0.12)
            Text("\(Int(battery.level * 100))")
                .font(.system(size: diameter * WatchConstants.fontCaption, design: .monospaced))
                .foregroundColor(roseGold.opacity(0.6))
        }
    }

    private func latticeRain(diameter: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(roseGold.opacity(0.2), lineWidth: 0.5)
                .frame(width: diameter * 0.13, height: diameter * 0.07)
            HStack(spacing: 1) {
                Image(systemName: weather.isRaining ? "drop.fill" : "drop")
                    .font(.system(size: diameter * WatchConstants.fontCaptionXS))
                Text("\(Int(weather.rainChance * 100))")
                    .font(.system(size: diameter * WatchConstants.fontCaption, design: .monospaced))
            }
            .foregroundColor(roseGold.opacity(0.5))
        }
    }

    // MARK: - Hands

    private func latticeHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))

        return ZStack {
            // Hollow-look hands (outline style)
            DauphineHandShape(
                length: diameter * 0.26,
                baseWidth: diameter * 0.032,
                tailLength: diameter * 0.04
            )
            .stroke(roseGold, lineWidth: 1.5)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            DauphineHandShape(
                length: diameter * 0.38,
                baseWidth: diameter * 0.024,
                tailLength: diameter * 0.05
            )
            .stroke(roseGold, lineWidth: 1.5)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Orange-tinted seconds
            SubdialHandShape(length: diameter * 0.40, tailLength: diameter * 0.08, width: 1)
                .fill(Color.orange.opacity(0.7))
                .frame(width: diameter, height: diameter)
                .rotationEffect(secondAngle)
        }
    }
}
