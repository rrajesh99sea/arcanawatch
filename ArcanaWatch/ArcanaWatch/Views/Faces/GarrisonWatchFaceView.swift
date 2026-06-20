import SwiftUI

/// Military field watch with olive/khaki palette and tactical readouts.
struct GarrisonWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let olive = Color(red: 0.20, green: 0.22, blue: 0.14)
    private let oliveDark = Color(red: 0.13, green: 0.15, blue: 0.09)
    private let khaki = Color(red: 0.60, green: 0.62, blue: 0.45)
    private let lumeGreen = Color(red: 0.55, green: 0.72, blue: 0.40)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Matte olive case
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [olive, oliveDark, olive],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: diameter * 0.03
                        )
                        .frame(width: diameter, height: diameter)

                    // Dark khaki dial
                    Circle()
                        .fill(RadialGradient(
                            colors: [oliveDark, Color(red: 0.08, green: 0.10, blue: 0.06)],
                            center: .center, startRadius: 0, endRadius: diameter * 0.44
                        ))
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // 24-hour outer ring
                    outerMilRing(diameter: diameter)

                    // Hour markers
                    garrisonMarkers(diameter: diameter)

                    // Minute ticks
                    garrisonTicks(diameter: diameter)

                    // Tactical readout bar at bottom
                    tacticalReadout(diameter: diameter)
                        .offset(y: diameter * 0.26)

                    // Hands
                    garrisonHands(diameter: diameter, date: date)

                    // Orange center pin
                    Circle()
                        .fill(Color.orange)
                        .frame(width: diameter * 0.025, height: diameter * 0.025)
                    Circle()
                        .fill(oliveDark)
                        .frame(width: diameter * 0.01, height: diameter * 0.01)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - 24hr Ring

    private func outerMilRing(diameter: CGFloat) -> some View {
        let r = diameter * 0.44
        return ForEach([0, 6, 12, 18], id: \.self) { hour in
            let angle = Angle.degrees(Double(hour) * 15 - 90)
            let label = String(format: "%02d", hour)
            Text(label)
                .font(.custom("Courier New", size: diameter * WatchConstants.fontCaption))
                .foregroundColor(khaki.opacity(0.4))
                .offset(
                    x: r * CGFloat(cos(angle.radians)),
                    y: r * CGFloat(sin(angle.radians))
                )
        }
    }

    // MARK: - Markers

    private func garrisonMarkers(diameter: CGFloat) -> some View {
        let r = diameter * 0.36
        return ZStack {
            // Triangle at 12
            Canvas { context, size in
                let cx = size.width / 2
                let topY = size.height / 2 - diameter * 0.37
                let triSize = diameter * 0.025
                var tri = Path()
                tri.move(to: CGPoint(x: cx, y: topY))
                tri.addLine(to: CGPoint(x: cx - triSize, y: topY + triSize * 1.5))
                tri.addLine(to: CGPoint(x: cx + triSize, y: topY + triSize * 1.5))
                tri.closeSubpath()
                context.fill(tri, with: .color(lumeGreen))
            }
            .allowsHitTesting(false)

            // Numerals at 3, 6, 9
            ForEach([3, 6, 9], id: \.self) { hour in
                let angle = Angle.degrees(Double(hour) * 30 - 90)
                Text("\(hour)")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontNumeralLg).weight(.bold))
                    .foregroundColor(khaki)
                    .offset(
                        x: r * CGFloat(cos(angle.radians)),
                        y: r * CGFloat(sin(angle.radians))
                    )
            }

            // Small indices at other hours
            ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                Rectangle()
                    .fill(khaki.opacity(0.6))
                    .frame(width: diameter * 0.006, height: diameter * 0.03)
                    .offset(y: -(diameter * 0.38))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
        }
    }

    // MARK: - Ticks

    private func garrisonTicks(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter * 0.42
            for i in 0..<60 {
                if i % 5 == 0 { continue }
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                var tick = Path()
                tick.move(to: CGPoint(x: center.x + cosA * outerR, y: center.y + sinA * outerR))
                tick.addLine(to: CGPoint(x: center.x + cosA * (outerR - diameter * 0.012),
                                         y: center.y + sinA * (outerR - diameter * 0.012)))
                context.stroke(tick, with: .color(khaki.opacity(0.25)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Tactical Readout

    private func tacticalReadout(diameter: CGFloat) -> some View {
        HStack(spacing: diameter * 0.02) {
            // Temperature
            VStack(spacing: 0) {
                Text("TMP")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontCaption))
                    .foregroundColor(khaki.opacity(0.5))
                Text("\(Int(weather.temperatureValue))°")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontValue).weight(.bold))
                    .foregroundColor(lumeGreen)
            }

            // Rain
            VStack(spacing: 0) {
                Text("RN%")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontCaption))
                    .foregroundColor(khaki.opacity(0.5))
                Text("\(Int(weather.rainChance * 100))")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontValue).weight(.bold))
                    .foregroundColor(weather.isRaining ? .cyan : lumeGreen)
            }

            // Battery
            VStack(spacing: 0) {
                Text("BAT")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontCaption))
                    .foregroundColor(khaki.opacity(0.5))
                Text("\(Int(battery.level * 100))")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontValue).weight(.bold))
                    .foregroundColor(battery.level > 0.2 ? lumeGreen : .red)
            }

            // Activity (compact)
            VStack(spacing: 0) {
                Text("ACT")
                    .font(.custom("Courier New", size: diameter * WatchConstants.fontCaption))
                    .foregroundColor(khaki.opacity(0.5))
                HStack(spacing: 1) {
                    Circle().fill(Color.red)
                        .frame(width: diameter * 0.01, height: diameter * 0.01)
                        .opacity(activity.moveProgress >= 1.0 ? 1.0 : 0.3)
                    Circle().fill(Color.green)
                        .frame(width: diameter * 0.01, height: diameter * 0.01)
                        .opacity(activity.exerciseProgress >= 1.0 ? 1.0 : 0.3)
                    Circle().fill(Color.cyan)
                        .frame(width: diameter * 0.01, height: diameter * 0.01)
                        .opacity(activity.standProgress >= 1.0 ? 1.0 : 0.3)
                }
            }
        }
    }

    // MARK: - Hands

    private func garrisonHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))

        return ZStack {
            SwordHandShape(
                length: diameter * 0.26,
                baseWidth: diameter * 0.035,
                tailLength: diameter * 0.04
            )
            .fill(khaki)
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            SwordHandShape(
                length: diameter * 0.38,
                baseWidth: diameter * 0.025,
                tailLength: diameter * 0.05
            )
            .fill(khaki)
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Orange seconds
            SubdialHandShape(length: diameter * 0.40, tailLength: diameter * 0.08, width: 1.5)
                .fill(Color.orange)
                .frame(width: diameter, height: diameter)
                .rotationEffect(secondAngle)
        }
    }
}
