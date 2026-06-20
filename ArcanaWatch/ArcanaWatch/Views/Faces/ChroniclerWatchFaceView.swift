import SwiftUI

/// Chronograph watch with tachymeter bezel and three subdials.
struct ChroniclerWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let dialBlack = Color(red: 0.06, green: 0.06, blue: 0.06)
    private let silverLight = Color(red: 0.88, green: 0.88, blue: 0.88)
    private let silverDark = Color(red: 0.45, green: 0.45, blue: 0.45)

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : (1.0 / 30.0))) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Tachymeter bezel — hidden in AOD
                    if !isLuminanceReduced { tachymeterBezel(diameter: diameter) }

                    // Black dial
                    Circle()
                        .fill(dialBlack)
                        .frame(width: diameter * 0.82, height: diameter * 0.82)

                    // Minute ticks — hidden in AOD
                    if !isLuminanceReduced { chroniclerTicks(diameter: diameter) }

                    // Hour markers
                    hourMarkers(diameter: diameter)

                    // Chronograph subdials — hidden in AOD
                    if !isLuminanceReduced { chroniclerSubdials(diameter: diameter, date: date) }

                    // Brand text — hidden in AOD
                    if !isLuminanceReduced { chroniclerBrand(diameter: diameter) }

                    // Hands
                    chroniclerHands(diameter: diameter, date: date)

                    // Center pin
                    Circle()
                        .fill(isLuminanceReduced ? Color(white: 0.45) : Color.red)
                        .frame(width: diameter * 0.02, height: diameter * 0.02)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Tachymeter Bezel

    private func tachymeterBezel(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter / 2
            let innerR = diameter * 0.41

            // Black bezel ring
            let ring = Path(ellipseIn: CGRect(x: center.x - outerR, y: center.y - outerR,
                                               width: outerR * 2, height: outerR * 2))
            context.fill(ring, with: .color(Color(red: 0.12, green: 0.12, blue: 0.12)))

            // Tachymeter numbers — each value has its own explicit bezel angle
            // (matches design spec; avoids the wrap-around overlap of the old
            // seconds/60*360 formula, which placed several numbers on top of
            // each other near 12 o'clock).
            let tachs = [300, 250, 200, 180, 160, 140, 130, 120, 110, 100, 90, 85, 80, 75, 70, 65, 60, 55, 50]
            let tachAngles: [Double] = [90, 108, 126, 135, 144, 155, 165, 175, 186, 198, 210, 222, 234, 246, 260, 274, 288, 305, 324]
            let numR = diameter * 0.449   // 178/396

            for (i, value) in tachs.enumerated() {
                let angle = Angle.degrees(tachAngles[i] - 90)
                let pt = CGPoint(x: center.x + numR * CGFloat(cos(angle.radians)),
                                 y: center.y + numR * CGFloat(sin(angle.radians)))
                context.draw(
                    Text("\(value)")
                        .font(.system(size: diameter * 0.017, weight: .medium))
                        .foregroundColor(silverLight.opacity(0.45)),
                    at: pt
                )
            }

            // Tick marks on bezel
            for i in 0..<60 {
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                let tickOuter = outerR - diameter * 0.005
                let tickInner = i % 5 == 0 ? innerR + diameter * 0.01 : outerR - diameter * 0.025
                var tick = Path()
                tick.move(to: CGPoint(x: center.x + cosA * tickOuter, y: center.y + sinA * tickOuter))
                tick.addLine(to: CGPoint(x: center.x + cosA * tickInner, y: center.y + sinA * tickInner))
                context.stroke(tick, with: .color(silverLight.opacity(0.6)),
                               lineWidth: i % 5 == 0 ? 1 : 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Ticks

    private func chroniclerTicks(diameter: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter * 0.40
            for i in 0..<60 {
                if i % 5 == 0 { continue }
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                var tick = Path()
                tick.move(to: CGPoint(x: center.x + cosA * outerR, y: center.y + sinA * outerR))
                tick.addLine(to: CGPoint(x: center.x + cosA * (outerR - diameter * 0.015),
                                         y: center.y + sinA * (outerR - diameter * 0.015)))
                context.stroke(tick, with: .color(silverDark.opacity(0.4)), lineWidth: 0.5)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hour Markers

    private func hourMarkers(diameter: CGFloat) -> some View {
        let r = diameter * 0.35
        // 3, 6, 9 are skipped — those positions are occupied by chronograph subdials.
        return ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
            BatonIndexShape()
                .fill(LinearGradient(
                    colors: [silverDark, silverLight, silverDark],
                    startPoint: .leading, endPoint: .trailing
                ))
                .frame(width: diameter * 0.008, height: hour % 3 == 0 ? diameter * 0.055 : diameter * 0.045)
                .offset(y: -(r - diameter * 0.02))
                .rotationEffect(.degrees(Double(hour) * 30))
        }
    }

    // MARK: - Subdials

    private func chroniclerSubdial(diameter: CGFloat, offsetX: CGFloat, offsetY: CGFloat,
                                    label: String, value: Double, maxVal: Double) -> some View {
        let r = diameter * 0.106   // 42/396

        return Canvas { context, size in
            let cx = size.width / 2 + offsetX
            let cy = size.height / 2 + offsetY

            // Subdial face
            let face = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            context.fill(face, with: .color(Color(red: 0.086, green: 0.086, blue: 0.086)))
            context.stroke(face, with: .color(Color(red: 0.227, green: 0.227, blue: 0.227)), lineWidth: 1)

            // Ticks + numerals
            let step = maxVal / 5
            var i = 0.0
            while i <= maxVal + 0.001 {
                let angle = Angle.degrees(i / maxVal * 240 + 60)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                var tick = Path()
                tick.move(to: CGPoint(x: cx + cosA * (r - 2), y: cy + sinA * (r - 2)))
                tick.addLine(to: CGPoint(x: cx + cosA * (r - 8), y: cy + sinA * (r - 8)))
                context.stroke(tick, with: .color(.white.opacity(0.5)), lineWidth: 1.5)

                if i > 0 && i < maxVal {
                    context.draw(
                        Text("\(Int(i))")
                            .font(.system(size: diameter * 0.022))
                            .foregroundColor(.white.opacity(0.4)),
                        at: CGPoint(x: cx + cosA * (r - 16), y: cy + sinA * (r - 16))
                    )
                }
                i += step
            }

            // Label
            context.draw(
                Text(label)
                    .font(.system(size: diameter * 0.024))
                    .foregroundColor(.white.opacity(0.4)),
                at: CGPoint(x: cx, y: cy + r * 0.35)
            )

            // Hand
            let a2 = Angle.degrees(value / maxVal * 240 + 60)
            let cosA2 = CGFloat(cos(a2.radians))
            let sinA2 = CGFloat(sin(a2.radians))
            var hand = Path()
            hand.move(to: CGPoint(x: cx - cosA2 * (r * 0.2), y: cy - sinA2 * (r * 0.2)))
            hand.addLine(to: CGPoint(x: cx + cosA2 * (r * 0.75), y: cy + sinA2 * (r * 0.75)))
            context.stroke(hand, with: .color(.white), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

            context.fill(Path(ellipseIn: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6)), with: .color(.white))
        }
        .allowsHitTesting(false)
    }

    private func chroniclerSubdials(diameter: CGFloat, date: Date) -> some View {
        let calendar = Calendar.current
        let h = Double(calendar.component(.hour, from: date) % 12)
        let m = Double(calendar.component(.minute, from: date))
        let s = Double(calendar.component(.second, from: date))

        return ZStack {
            // 9 o'clock — running seconds
            chroniclerSubdial(diameter: diameter, offsetX: -diameter * 0.227, offsetY: 0,
                              label: "S", value: s, maxVal: 60)
            // 12 o'clock — 30-minute counter
            chroniclerSubdial(diameter: diameter, offsetX: 0, offsetY: -diameter * 0.202,
                              label: "30", value: m.truncatingRemainder(dividingBy: 30), maxVal: 30)
            // 3 o'clock — 12-hour counter
            chroniclerSubdial(diameter: diameter, offsetX: diameter * 0.227, offsetY: 0,
                              label: "12", value: h, maxVal: 12)
        }
    }

    // MARK: - Brand Text

    private func chroniclerBrand(diameter: CGFloat) -> some View {
        Text("CHRONICLER")
            .font(.custom(WatchConstants.romanFontName, size: diameter * 0.04))
            .foregroundColor(.white.opacity(0.55))
            .offset(y: -diameter * 0.0758)
            .allowsHitTesting(false)
    }

    // MARK: - Hands

    private func chroniclerHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let handOpacity: Double = isLuminanceReduced ? 0.55 : 1.0

        let calendar = Calendar.current
        let second = Double(calendar.component(.second, from: date))
        let nanosecond = Double(calendar.component(.nanosecond, from: date))
        let secondAngle = Angle.degrees((second + nanosecond / 1_000_000_000) * 6.0)

        return ZStack {
            // Hour hand
            DauphineHandShape(
                length: diameter * 0.227,
                baseWidth: diameter * 0.025,
                tailLength: diameter * 0.035
            )
            .fill(LinearGradient(
                colors: [silverDark.opacity(handOpacity), silverLight.opacity(handOpacity),
                         silverLight.opacity(handOpacity), silverDark.opacity(handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(hourAngle)

            // Minute hand
            DauphineHandShape(
                length: diameter * 0.328,
                baseWidth: diameter * 0.020,
                tailLength: diameter * 0.045
            )
            .fill(LinearGradient(
                colors: [silverDark.opacity(handOpacity), silverLight.opacity(handOpacity),
                         silverLight.opacity(handOpacity), silverDark.opacity(handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.6), radius: 3, x: 1, y: 1)
            .frame(width: diameter, height: diameter)
            .rotationEffect(minuteAngle)

            // Seconds + lollipop — hidden in AOD
            if !isLuminanceReduced {
                SubdialHandShape(length: diameter * 0.379, tailLength: diameter * 0.08, width: 1)
                    .fill(Color.red)
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(secondAngle)

                Canvas { ctx, size in
                    let cx = size.width / 2, cy = size.height / 2
                    let theta = secondAngle.radians
                    let dist = diameter * 0.348
                    let r = diameter * 0.0101
                    let bx = cx + dist * CGFloat(sin(theta))
                    let by = cy - dist * CGFloat(cos(theta))
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: bx - r, y: by - r, width: r * 2, height: r * 2)),
                        with: .color(.red)
                    )
                }
                .allowsHitTesting(false)
            }
        }
    }
}
