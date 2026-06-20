import SwiftUI

// MARK: - Paddle hand shape (thick skeleton hands matching the T-Touch reference)
/// A wide, flat-tipped paddle/baton hand. Drawn as a rotated rectangle with
/// a thin dark "skeleton" line running down its length, matching the bold
/// lume-filled hands on the reference dial.
private struct PaddleHandShape: Shape {
    let length: CGFloat
    let width: CGFloat
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let hw = width / 2
        return Path(roundedRect: CGRect(x: midX - hw, y: midY - length,
                                         width: width, height: length + tailLength),
                     cornerRadius: hw * 0.5)
    }
}

/// Tactical carbon-dial chronograph face — black case, woven-carbon dial,
/// bold white Arabic numerals at 12/3/6/9, thick rectangular baton markers
/// elsewhere, wide skeletonized paddle hour/minute hands, and a signature
/// red/white arrow-tipped chronograph seconds hand. Inspired by the Tissot
/// T-Touch Expert Solar — the brand's compass-bezel text, manufacturer
/// wordmark, and digital readout are intentionally omitted.
struct SWSWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let caseEdge  = Color(red: 0.20, green: 0.20, blue: 0.21)
    private let caseBlack = Color(red: 0.07, green: 0.07, blue: 0.075)
    private let dialBlack = Color(red: 0.045, green: 0.045, blue: 0.05)
    private let accentRed = Color(red: 0.86, green: 0.12, blue: 0.10)

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : (1.0 / 30.0))) { context in
            GeometryReader { geo in
                let d = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Black case with subtle bevel highlight
                    Circle()
                        .fill(
                            isLuminanceReduced
                                ? AnyShapeStyle(Color(white: 0.08))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [caseEdge, caseBlack, caseEdge],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                        )
                        .frame(width: d * 0.97, height: d * 0.97)

                    // Separator ring
                    Circle()
                        .fill(Color.black)
                        .frame(width: d * 0.93, height: d * 0.93)

                    // Carbon-fiber dial
                    Circle()
                        .fill(dialBlack)
                        .frame(width: d * 0.86, height: d * 0.86)

                    // Carbon texture — hidden in AOD
                    if !isLuminanceReduced { carbonTexture(d: d) }

                    // Chapter ring: minute ticks, hour batons, quarter numerals
                    chapterRing(d: d)

                    // Brand text — hidden in AOD
                    if !isLuminanceReduced { swsBrand(d: d) }

                    // Hands
                    swsHands(d: d, date: date)

                    // Center pin
                    Circle()
                        .fill(isLuminanceReduced ? Color(white: 0.3) : accentRed)
                        .frame(width: d * 0.028, height: d * 0.028)
                    Circle()
                        .fill(Color.black)
                        .frame(width: d * 0.012, height: d * 0.012)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Carbon Texture

    /// Subtle woven crosshatch to suggest a carbon-fiber dial.
    private func carbonTexture(d: CGFloat) -> some View {
        Canvas { context, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = d * 0.43
            context.clip(to: Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)))

            let spacing = d * 0.014
            let count = Int((r * 4) / spacing) + 2

            for i in -count...count {
                let off = CGFloat(i) * spacing
                var p = Path()
                p.move(to: CGPoint(x: cx - r * 2 + off, y: cy - r * 2))
                p.addLine(to: CGPoint(x: cx + r * 2 + off, y: cy + r * 2))
                context.stroke(p, with: .color(.white.opacity(0.03)), lineWidth: spacing * 0.45)
            }
            for i in -count...count {
                let off = CGFloat(i) * spacing
                var p = Path()
                p.move(to: CGPoint(x: cx + r * 2 + off, y: cy - r * 2))
                p.addLine(to: CGPoint(x: cx - r * 2 + off, y: cy + r * 2))
                context.stroke(p, with: .color(.black.opacity(0.4)), lineWidth: spacing * 0.45)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Chapter Ring

    private func chapterRing(d: CGFloat) -> some View {
        ZStack {
            // Minute ticks — skip the quarter-hour positions (12/3/6/9) where
            // the large numerals sit.
            Canvas { context, size in
                let cx = size.width / 2, cy = size.height / 2
                let outerR = d * 0.41

                for i in 0..<60 {
                    let isQuarter = i % 15 == 0
                    if isQuarter { continue }
                    let angle = Angle.degrees(Double(i) * 6 - 90)
                    let cosA = CGFloat(cos(angle.radians))
                    let sinA = CGFloat(sin(angle.radians))
                    let isFive = i % 5 == 0
                    let inner = outerR - (isFive ? d * 0.028 : d * 0.014)
                    var path = Path()
                    path.move(to: CGPoint(x: cx + cosA * outerR, y: cy + sinA * outerR))
                    path.addLine(to: CGPoint(x: cx + cosA * inner, y: cy + sinA * inner))
                    context.stroke(path, with: .color(.white.opacity(isFive ? 0.6 : 0.25)),
                                    lineWidth: isFive ? 1.5 : 0.75)
                }
            }
            .allowsHitTesting(false)

            // Thick rectangular baton markers at non-quarter hours — wide,
            // solid white bars matching the reference dial's bold indices.
            ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                RoundedRectangle(cornerRadius: d * 0.006)
                    .fill(.white)
                    .frame(width: d * 0.026, height: d * 0.072)
                    .offset(y: -(d * 0.41 - d * 0.036))
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
            .allowsHitTesting(false)

            // Large, bold Arabic numerals at 12, 3, 6, 9
            ForEach([(12, 0.0), (3, 90.0), (6, 180.0), (9, 270.0)], id: \.0) { label, deg in
                let a = Angle.degrees(deg - 90)
                Text("\(label)")
                    .font(.system(size: d * 0.115, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .offset(x: d * 0.305 * CGFloat(cos(a.radians)),
                            y: d * 0.305 * CGFloat(sin(a.radians)))
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - Brand Text

    private func swsBrand(d: CGFloat) -> some View {
        ZStack {
            Text("SWS")
                .font(.system(size: d * 0.052, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .offset(y: -d * 0.16)
            Text("SOLAR · CARBON")
                .font(.system(size: d * 0.020, weight: .medium))
                .foregroundColor(accentRed.opacity(0.8))
                .offset(y: -d * 0.122)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hands

    private func swsHands(d: CGFloat, date: Date) -> some View {
        let hourAngle = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))

        // Smooth, continuously-sweeping chronograph seconds hand.
        let calendar = Calendar.current
        let second = Double(calendar.component(.second, from: date))
        let nanosecond = Double(calendar.component(.nanosecond, from: date))
        let secondAngle = Angle.degrees((second + nanosecond / 1_000_000_000) * 6.0)

        return ZStack {
            // Hour hand — wide white paddle with skeleton line (dimmed in AOD)
            paddleHand(d: d, length: d * 0.205, width: d * 0.052, tailLength: d * 0.030, angle: hourAngle)
                .opacity(isLuminanceReduced ? 0.45 : 1.0)

            // Minute hand — wide white paddle with skeleton line (dimmed in AOD)
            paddleHand(d: d, length: d * 0.310, width: d * 0.042, tailLength: d * 0.030, angle: minuteAngle)
                .opacity(isLuminanceReduced ? 0.45 : 1.0)

            // Red shaft with white/red arrow-tip — hidden in AOD
            if !isLuminanceReduced { Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height / 2
                let theta = secondAngle.radians - .pi / 2
                let cosA = CGFloat(cos(theta)), sinA = CGFloat(sin(theta))

                let tailLen  = d * 0.07
                let shaftLen = d * 0.34
                let arrowLen = d * 0.045
                let arrowW   = d * 0.022

                // Tail (counterweight side)
                var tail = Path()
                tail.move(to: CGPoint(x: cx - cosA * tailLen, y: cy - sinA * tailLen))
                tail.addLine(to: CGPoint(x: cx, y: cy))
                ctx.stroke(tail, with: .color(accentRed), lineWidth: 1.5)

                // Shaft
                var shaft = Path()
                shaft.move(to: CGPoint(x: cx, y: cy))
                shaft.addLine(to: CGPoint(x: cx + cosA * shaftLen, y: cy + sinA * shaftLen))
                ctx.stroke(shaft, with: .color(accentRed), lineWidth: 1.5)

                // Arrowhead: white triangle outlined in red, pointing at the tip
                let baseX = cx + cosA * shaftLen
                let baseY = cy + sinA * shaftLen
                let tipX  = cx + cosA * (shaftLen + arrowLen)
                let tipY  = cy + sinA * (shaftLen + arrowLen)
                let perpX = -sinA, perpY = cosA

                var arrow = Path()
                arrow.move(to: CGPoint(x: tipX, y: tipY))
                arrow.addLine(to: CGPoint(x: baseX + perpX * arrowW, y: baseY + perpY * arrowW))
                arrow.addLine(to: CGPoint(x: baseX - perpX * arrowW, y: baseY - perpY * arrowW))
                arrow.closeSubpath()
                ctx.fill(arrow, with: .color(.white))
                ctx.stroke(arrow, with: .color(accentRed), lineWidth: 1)
            }
            .allowsHitTesting(false)
            } // end if !isLuminanceReduced
        }
    }

    /// Draws a wide paddle hand (hour or minute) with a thin dark skeleton
    /// line running down its length — matches the bold, lume-filled hands
    /// of the reference dial.
    private func paddleHand(d: CGFloat, length: CGFloat, width: CGFloat,
                            tailLength: CGFloat, angle: Angle) -> some View {
        ZStack {
            PaddleHandShape(length: length, width: width, tailLength: tailLength)
                .fill(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
                .frame(width: d, height: d)
                .rotationEffect(angle)

            // Skeleton cutout line down the center of the paddle
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height / 2
                let theta = angle.radians
                let lineW = width * 0.16
                let yTop = -(length - width * 0.45)
                let yBot = tailLength - width * 0.25
                let corners: [(CGFloat, CGFloat)] = [
                    (-lineW / 2, yTop), (lineW / 2, yTop),
                    (lineW / 2, yBot), (-lineW / 2, yBot)
                ]
                var p = Path()
                let pts = corners.map { (x, y) -> CGPoint in
                    let rx = x * CGFloat(cos(theta)) - y * CGFloat(sin(theta))
                    let ry = x * CGFloat(sin(theta)) + y * CGFloat(cos(theta))
                    return CGPoint(x: cx + rx, y: cy + ry)
                }
                p.move(to: pts[0])
                pts.dropFirst().forEach { p.addLine(to: $0) }
                p.closeSubpath()
                ctx.fill(p, with: .color(dialBlack))
            }
            .allowsHitTesting(false)
        }
    }
}
