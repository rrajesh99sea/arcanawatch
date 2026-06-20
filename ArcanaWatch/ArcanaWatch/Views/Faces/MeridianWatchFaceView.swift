import SwiftUI

/// World-time watch with city ring and dual-time display.
struct MeridianWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let navyBlue = Color(red: 0.12, green: 0.16, blue: 0.28)
    private let platinum = Color(red: 0.78, green: 0.80, blue: 0.84)
    private let platDark = Color(red: 0.50, green: 0.52, blue: 0.56)
    private let accentBlue = Color(red: 0.30, green: 0.55, blue: 0.85)

    private let cities = ["LON", "PAR", "DXB", "BOM", "SGP", "TKY",
                          "SYD", "NOU", "LAX", "NYC", "GRU", "MAD"]

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Platinum case (dimmed in AOD)
                    Circle()
                        .strokeBorder(
                            isLuminanceReduced
                                ? AnyShapeStyle(Color(white: 0.20))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [platinum, platDark, platinum],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )),
                            lineWidth: diameter * 0.025
                        )
                        .frame(width: diameter, height: diameter)

                    // Navy dial (very dark in AOD)
                    Circle()
                        .fill(RadialGradient(
                            colors: isLuminanceReduced
                                ? [Color(red: 0.04, green: 0.05, blue: 0.09), Color.black]
                                : [navyBlue, Color(red: 0.08, green: 0.10, blue: 0.18)],
                            center: .center, startRadius: 0, endRadius: diameter * 0.46
                        ))
                        .frame(width: diameter * 0.92, height: diameter * 0.92)

                    // City ring — hidden in AOD
                    if !isLuminanceReduced { cityRing(diameter: diameter) }

                    // Crosshair — hidden in AOD
                    if !isLuminanceReduced { crosshairLines(diameter: diameter) }

                    // Hour markers
                    meridianMarkers(diameter: diameter)

                    // Date window — hidden in AOD
                    if !isLuminanceReduced { meridianDateWindow(diameter: diameter, date: date) }

                    // Brand text — hidden in AOD
                    if !isLuminanceReduced { meridianBrand(diameter: diameter) }

                    // Second time zone readout — hidden in AOD
                    if !isLuminanceReduced { meridianDualTimeZone(diameter: diameter, date: date) }

                    // Hands
                    meridianHands(diameter: diameter, date: date)

                    // Center pin
                    Circle()
                        .fill(isLuminanceReduced ? Color(white: 0.25) : accentBlue)
                        .frame(width: diameter * 0.02, height: diameter * 0.02)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - City Ring

    private func cityRing(diameter: CGFloat) -> some View {
        let r = diameter * 0.43
        return ForEach(Array(cities.enumerated()), id: \.offset) { i, city in
            let angle = Angle.degrees(Double(i) * 30 - 90)
            Text(city)
                .font(.system(size: diameter * WatchConstants.fontCaption, weight: .medium, design: .monospaced))
                .foregroundColor(platinum.opacity(0.4))
                .offset(
                    x: r * CGFloat(cos(angle.radians)),
                    y: r * CGFloat(sin(angle.radians))
                )
        }
    }

    // MARK: - Crosshair

    private func crosshairLines(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = diameter * 0.38

            // Vertical dashed line
            let dashPattern: [CGFloat] = [4, 4]
            var vLine = Path()
            vLine.move(to: CGPoint(x: center.x, y: center.y - r))
            vLine.addLine(to: CGPoint(x: center.x, y: center.y + r))
            context.stroke(vLine, with: .color(platinum.opacity(0.12)),
                           style: StrokeStyle(lineWidth: 0.5, dash: dashPattern))

            // Horizontal dashed line
            var hLine = Path()
            hLine.move(to: CGPoint(x: center.x - r, y: center.y))
            hLine.addLine(to: CGPoint(x: center.x + r, y: center.y))
            context.stroke(hLine, with: .color(platinum.opacity(0.12)),
                           style: StrokeStyle(lineWidth: 0.5, dash: dashPattern))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Markers

    private func meridianMarkers(diameter: CGFloat) -> some View {
        ZStack {
            // Diamond at 12
            Canvas { context, size in
                let cx = size.width / 2
                let topY = size.height / 2 - diameter * 0.36
                let dSize = diameter * 0.012
                var path = Path()
                path.move(to: CGPoint(x: cx, y: topY))
                path.addLine(to: CGPoint(x: cx + dSize, y: topY + dSize * 1.5))
                path.addLine(to: CGPoint(x: cx, y: topY + dSize * 3))
                path.addLine(to: CGPoint(x: cx - dSize, y: topY + dSize * 1.5))
                path.closeSubpath()
                context.fill(path, with: .color(platinum))
            }
            .allowsHitTesting(false)

            // Batons at other hours
            ForEach(1..<12, id: \.self) { hour in
                Rectangle()
                    .fill(platinum)
                    .frame(width: diameter * 0.008, height: hour % 3 == 0 ? diameter * 0.05 : diameter * 0.03)
                    .offset(y: -(diameter * 0.37))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }

            // Minute ticks
            ForEach(0..<60, id: \.self) { i in
                if i % 5 != 0 {
                    Rectangle()
                        .fill(platDark.opacity(0.3))
                        .frame(width: 0.5, height: diameter * 0.012)
                        .offset(y: -(diameter * 0.40))
                        .rotationEffect(.degrees(Double(i) * 6))
                }
            }
        }
    }

    // MARK: - Date Window

    private func meridianDateWindow(diameter: CGFloat, date: Date) -> some View {
        let day = AngleCalculations.dayOfMonth(from: date)
        return ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.78, green: 0.82, blue: 0.98))
                .frame(width: diameter * 0.091, height: diameter * 0.056)
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color(red: 0.47, green: 0.51, blue: 0.71), lineWidth: 0.5)
                .frame(width: diameter * 0.091, height: diameter * 0.056)
            Text("\(day)")
                .font(.system(size: diameter * 0.04, weight: .bold))
                .foregroundColor(Color(red: 0.067, green: 0.094, blue: 0.188))
        }
        .offset(x: diameter * 0.222)
        .allowsHitTesting(false)
    }

    // MARK: - Brand Text

    private func meridianBrand(diameter: CGFloat) -> some View {
        ZStack {
            Text("MERIDIAN")
                .font(.custom(WatchConstants.romanFontName, size: diameter * 0.040))
                .foregroundColor(Color(red: 0.78, green: 0.82, blue: 1.0).opacity(0.5))
                .offset(y: -diameter * 0.126)
            Text("DUAL TIME · AUTOMATIC")
                .font(.custom(WatchConstants.romanFontName, size: diameter * 0.020))
                .foregroundColor(Color(red: 0.71, green: 0.75, blue: 0.94).opacity(0.3))
                .offset(y: -diameter * 0.086)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Dual Time Zone

    private func meridianDualTimeZone(diameter: CGFloat, date: Date) -> some View {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let offset = 4
        let tzHour = (hour + offset) % 24

        return ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.78, green: 0.82, blue: 0.94).opacity(0.06))
                .frame(width: diameter * 0.303, height: diameter * 0.071)
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color(red: 0.71, green: 0.75, blue: 0.90).opacity(0.15), lineWidth: 0.5)
                .frame(width: diameter * 0.303, height: diameter * 0.071)
            Text("+\(offset)h")
                .font(.system(size: diameter * 0.022, design: .monospaced))
                .foregroundColor(Color(red: 0.71, green: 0.76, blue: 0.92).opacity(0.45))
                .offset(x: -diameter * 0.101)
            Text(String(format: "%02d:%02d", tzHour, minute))
                .font(.system(size: diameter * 0.038, design: .monospaced))
                .foregroundColor(Color(red: 0.78, green: 0.84, blue: 1.0).opacity(0.55))
                .offset(x: diameter * 0.056)
        }
        .offset(y: diameter * 0.273)
        .allowsHitTesting(false)
    }

    // MARK: - Hands

    private func meridianHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))
        let handOpacity: Double = isLuminanceReduced ? 0.50 : 1.0

        return ZStack {
            // Hour hand
            DauphineHandShape(
                length: diameter * 0.222,
                baseWidth: diameter * 0.030,
                tailLength: diameter * 0.04
            )
            .fill(LinearGradient(
                colors: [platDark.opacity(handOpacity), platinum.opacity(handOpacity),
                         platinum.opacity(handOpacity), platDark.opacity(handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            // Minute hand
            DauphineHandShape(
                length: diameter * 0.328,
                baseWidth: diameter * 0.023,
                tailLength: diameter * 0.05
            )
            .fill(LinearGradient(
                colors: [platDark.opacity(handOpacity), platinum.opacity(handOpacity),
                         platinum.opacity(handOpacity), platDark.opacity(handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Seconds — hidden in AOD
            if !isLuminanceReduced {
                SubdialHandShape(length: diameter * 0.374, tailLength: diameter * 0.08, width: 1)
                    .fill(accentBlue)
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(secondAngle)
            }
        }
    }
}
