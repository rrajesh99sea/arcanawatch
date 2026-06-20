import SwiftUI

/// Luxury sports watch with hexagonal bezel and tapisserie dial (AP-inspired).
struct FortressWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let tapissBlue = Color(red: 0.24, green: 0.37, blue: 0.50)
    private let steelLight = Color(red: 0.85, green: 0.87, blue: 0.89)
    private let steelDark = Color(red: 0.48, green: 0.50, blue: 0.52)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Hexagonal bezel with screws
                    hexBezel(diameter: diameter)

                    // Tapisserie dial
                    tapisseriePattern(diameter: diameter)

                    // Hour markers (batons)
                    fortressBatons(diameter: diameter)

                    // Minute ticks
                    fortressTicks(diameter: diameter)

                    // Complications
                    // Bottom: Battery bar
                    batteryBar(diameter: diameter)
                        .offset(y: diameter * 0.30)

                    // 6 o'clock: Temperature
                    VStack(spacing: 1) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: diameter * WatchConstants.fontBody))
                        Text("\(Int(weather.temperatureValue))°")
                            .font(.system(size: diameter * WatchConstants.fontValueLg, weight: .medium, design: .monospaced))
                    }
                    .foregroundColor(steelLight)
                    .offset(y: diameter * 0.22)

                    // 9 o'clock: Rain
                    VStack(spacing: 1) {
                        Image(systemName: weather.isRaining ? "cloud.rain.fill" : "drop.fill")
                            .font(.system(size: diameter * WatchConstants.fontBody))
                            .foregroundColor(.cyan.opacity(0.7))
                        Text("\(Int(weather.rainChance * 100))%")
                            .font(.system(size: diameter * WatchConstants.fontValue, design: .monospaced))
                            .foregroundColor(steelLight.opacity(0.7))
                    }
                    .offset(x: -diameter * 0.24)

                    // 3 o'clock: Activity rings
                    ActivityRingsView(
                        diameter: diameter * 0.14,
                        moveProgress: activity.moveProgress,
                        exerciseProgress: activity.exerciseProgress,
                        standProgress: activity.standProgress
                    )
                    .offset(x: diameter * 0.24)

                    // Date window
                    dateWindow(diameter: diameter, date: date)
                        .offset(x: diameter * 0.24, y: diameter * 0.06)

                    // Hands
                    fortressHands(diameter: diameter, date: date)

                    // Center pin
                    CenterPinView(diameter: diameter)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Hex Bezel

    private func hexBezel(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter / 2
            let innerR = outerR * 0.93

            // Outer hex
            let outerHex = hexPath(center: center, radius: outerR)
            context.fill(outerHex, with: .linearGradient(
                Gradient(colors: [steelLight, steelDark, steelLight]),
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: size.width, y: size.height)
            ))

            // Inner (clipped by hex) — the dial area is round
            let innerCircle = Path(ellipseIn: CGRect(
                x: center.x - innerR, y: center.y - innerR,
                width: innerR * 2, height: innerR * 2
            ))
            context.fill(innerCircle, with: .color(tapissBlue))

            // 6 screws at vertices
            for i in 0..<6 {
                let angle = Angle.degrees(Double(i) * 60 - 30)
                let screwR = (outerR + innerR) / 2
                let sx = center.x + screwR * CGFloat(cos(angle.radians))
                let sy = center.y + screwR * CGFloat(sin(angle.radians))
                let screwSize: CGFloat = diameter * 0.018
                let screwRect = CGRect(x: sx - screwSize, y: sy - screwSize,
                                       width: screwSize * 2, height: screwSize * 2)
                context.fill(Path(ellipseIn: screwRect), with: .color(steelDark))
                // Slot
                var slot = Path()
                slot.move(to: CGPoint(x: sx - screwSize * 0.6, y: sy))
                slot.addLine(to: CGPoint(x: sx + screwSize * 0.6, y: sy))
                context.stroke(slot, with: .color(.black.opacity(0.4)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    private func hexPath(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for i in 0..<6 {
            let angle = Angle.degrees(Double(i) * 60 - 30)
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

    // MARK: - Tapisserie

    private func tapisseriePattern(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = diameter * 0.42
            let gridSize: CGFloat = diameter * 0.022

            // Clip to circle
            context.clipToLayer { ctx in
                ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r,
                                                 width: r * 2, height: r * 2)),
                         with: .color(.white))
            }

            // Grid of tiny squares
            let startX = center.x - r
            let startY = center.y - r
            var x = startX
            while x < center.x + r {
                var y = startY
                while y < center.y + r {
                    let rect = CGRect(x: x, y: y, width: gridSize - 1, height: gridSize - 1)
                    context.fill(Path(rect), with: .color(.white.opacity(0.04)))
                    // Tiny highlight
                    let hlRect = CGRect(x: x, y: y, width: gridSize * 0.3, height: gridSize * 0.3)
                    context.fill(Path(hlRect), with: .color(.white.opacity(0.06)))
                    y += gridSize
                }
                x += gridSize
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Batons

    private func fortressBatons(diameter: CGFloat) -> some View {
        ForEach(1..<13, id: \.self) { hour in
            Rectangle()
                .fill(LinearGradient(
                    colors: [steelDark, steelLight, steelDark],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: diameter * 0.01, height: hour % 3 == 0 ? diameter * 0.06 : diameter * 0.04)
                .offset(y: -(diameter * 0.38))
                .rotationEffect(.degrees(Double(hour) * 30))
        }
    }

    // MARK: - Ticks

    private func fortressTicks(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter * 0.43
            for i in 0..<60 {
                if i % 5 == 0 { continue }
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                var tick = Path()
                tick.move(to: CGPoint(x: center.x + cosA * outerR, y: center.y + sinA * outerR))
                tick.addLine(to: CGPoint(x: center.x + cosA * (outerR - diameter * 0.012),
                                         y: center.y + sinA * (outerR - diameter * 0.012)))
                context.stroke(tick, with: .color(steelDark.opacity(0.4)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Battery Bar

    private func batteryBar(diameter: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(steelDark.opacity(0.2))
                .frame(width: diameter * 0.30, height: diameter * 0.015)
            RoundedRectangle(cornerRadius: 2)
                .fill(battery.level > 0.2 ? steelLight : Color.red)
                .frame(width: diameter * 0.30 * CGFloat(battery.level), height: diameter * 0.015)
        }
    }

    // MARK: - Date

    private func dateWindow(diameter: CGFloat, date: Date) -> some View {
        let day = AngleCalculations.dayOfMonth(from: date)
        return ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white)
                .frame(width: diameter * 0.10, height: diameter * 0.075)
            Text("\(day)")
                .font(.system(size: diameter * WatchConstants.fontValueLg, weight: .bold))
                .foregroundColor(.black)
        }
    }

    // MARK: - Hands

    private func fortressHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))

        return ZStack {
            DauphineHandShape(
                length: diameter * 0.28,
                baseWidth: diameter * 0.032,
                tailLength: diameter * 0.04
            )
            .fill(LinearGradient(
                colors: [steelDark, steelLight, steelLight, steelDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            DauphineHandShape(
                length: diameter * 0.40,
                baseWidth: diameter * 0.024,
                tailLength: diameter * 0.05
            )
            .fill(LinearGradient(
                colors: [steelDark, steelLight, steelLight, steelDark],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Red seconds
            SubdialHandShape(length: diameter * 0.42, tailLength: diameter * 0.08, width: 1.5)
                .fill(Color.red)
                .frame(width: diameter, height: diameter)
                .rotationEffect(secondAngle)
        }
    }
}
