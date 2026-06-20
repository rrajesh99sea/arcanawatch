import SwiftUI

/// Type B pilot/flieger watch with high-legibility instrument style.
/// All geometry values converted directly from the HTML Design Studio defaults
/// (canvas W=396, so HTML px / 396 = Swift ratio of diameter).
struct AirfieldWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    // Palette — matches HTML designer defaults
    private let lumeGreen  = Color(red: 0.75, green: 0.88, blue: 0.65)
    private let dialBlack  = Color(red: 0.05, green: 0.05, blue: 0.05)
    private let steelTop   = Color(red: 0.69, green: 0.69, blue: 0.69)  // #b0b0b0
    private let steelMid   = Color(red: 0.44, green: 0.44, blue: 0.44)  // #707070
    private let accent     = Color(red: 1.00, green: 0.33, blue: 0.00)  // #ff5500

    // ── Geometry constants (HTML px ÷ 396) ──────────────────────────────
    //   caseR=192  dialR=178  scaleR=175  scaleNumR=153  markerR=138  numeralR=100
    private let kCaseR:      CGFloat = 0.970   // 192/198 of radius  → case fills 97% of view radius
    private let kDialR:      CGFloat = 0.899   // 178/198            → dial diameter = 0.899 × radius × 2 ≈ 90% of view
    private let kScaleR:     CGFloat = 0.442   // 175/396            → outer 24h tick ring
    private let kScaleNumR:  CGFloat = 0.386   // 153/396            → 24h numeral ring
    private let kMarkerR:    CGFloat = 0.348   // 138/396            → inner chapter-ring / hour ticks
    private let kNumeralR:   CGFloat = 0.253   // 100/396            → 3/6/9 numeral ring

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : 1)) { context in
            GeometryReader { geo in
                let d    = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Case — gradient ring
                    Circle()
                        .fill(
                            isLuminanceReduced
                                ? AnyShapeStyle(Color(white: 0.18))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [steelTop, steelMid, steelTop],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                        )
                        .frame(width: d * 0.970, height: d * 0.970)

                    // Black inner ring between case and dial
                    Circle()
                        .fill(Color.black)
                        .frame(width: d * 0.924, height: d * 0.924)

                    // Black dial
                    Circle()
                        .fill(dialBlack)
                        .frame(width: d * kDialR, height: d * kDialR)

                    // Outer 24-hour scale — hidden in AOD
                    if !isLuminanceReduced { outerScale(d: d) }

                    // Triangle at 12 — hidden in AOD
                    if !isLuminanceReduced { triangleAt12(d: d) }

                    // Inner chapter ring: hour indices + 3/6/9 numerals + minute ticks
                    chapterRing(d: d)

                    // Brand text — hidden in AOD
                    if !isLuminanceReduced { airfieldBrand(d: d) }

                    // Sword hands
                    airfieldHands(d: d, date: date)

                    // Accent center pin
                    Circle()
                        .fill(isLuminanceReduced ? Color(white: 0.5) : accent)
                        .frame(width: d * 0.030, height: d * 0.030)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Outer 24-hour scale

    private func outerScale(d: CGFloat) -> some View {
        Canvas { context, size in
            let cx = size.width / 2, cy = size.height / 2
            let scaleR    = d * kScaleR
            let scaleNumR = d * kScaleNumR

            // 24 tick marks
            for i in 0..<24 {
                let angle = Angle.degrees(Double(i) * 15.0 - 90)
                let cosA  = CGFloat(cos(angle.radians))
                let sinA  = CGFloat(sin(angle.radians))
                // Major ticks at 6-hour marks, medium at 2-hour, minor at 1-hour
                let tickLen: CGFloat = i % 6 == 0 ? d * 0.038 : i % 2 == 0 ? d * 0.025 : d * 0.018
                let lw:      CGFloat = i % 6 == 0 ? 2 : 1
                var path = Path()
                path.move(to:    CGPoint(x: cx + cosA * scaleR,            y: cy + sinA * scaleR))
                path.addLine(to: CGPoint(x: cx + cosA * (scaleR - tickLen), y: cy + sinA * (scaleR - tickLen)))
                context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: lw)
            }

            // Four numerals: 6, 12, 18, 24
            let labels: [(String, Double)] = [("6",6),("12",12),("18",18),("24",0)]
            for (label, hour) in labels {
                let angle = Angle.degrees(hour * 15.0 - 90)
                let pt    = CGPoint(
                    x: cx + scaleNumR * CGFloat(cos(angle.radians)),
                    y: cy + scaleNumR * CGFloat(sin(angle.radians))
                )
                context.draw(
                    Text(label)
                        .font(.system(size: d * 0.026, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.35)),
                    at: pt
                )
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Triangle at 12

    private func triangleAt12(d: CGFloat) -> some View {
        Canvas { context, size in
            let cx     = size.width / 2
            let cy     = size.height / 2
            // HTML: translate to (CX, CY - (markerR-8)) = center at 130px above CY
            // tip at that center - 12px → tip = 142px above CY
            let tipY   = cy - d * 0.359   // 142/396
            let baseY  = cy - d * 0.318   // 126/396
            let halfW  = d * 0.018        //   7/396

            var path = Path()
            path.move(to:    CGPoint(x: cx,         y: tipY))
            path.addLine(to: CGPoint(x: cx - halfW, y: baseY))
            path.addLine(to: CGPoint(x: cx + halfW, y: baseY))
            path.closeSubpath()
            context.fill(path, with: .color(.white))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Inner chapter ring (hour ticks + 3/6/9 numerals + minute ticks)

    private func chapterRing(d: CGFloat) -> some View {
        Canvas { context, size in
            let cx      = size.width / 2
            let cy      = size.height / 2
            let markerR = d * kMarkerR   // outer edge of tick ring
            let numR    = d * kNumeralR  // 3/6/9 numeral radius

            // ── Minute ticks (non-5 positions, at the inner chapter ring) ────
            for i in 0..<60 {
                if i % 5 == 0 { continue }
                let angle = Angle.degrees(Double(i) * 6.0 - 90)
                let cosA  = CGFloat(cos(angle.radians))
                let sinA  = CGFloat(sin(angle.radians))
                var path  = Path()
                path.move(to:    CGPoint(x: cx + cosA * markerR,           y: cy + sinA * markerR))
                path.addLine(to: CGPoint(x: cx + cosA * (markerR - d * 0.015), y: cy + sinA * (markerR - d * 0.015)))
                context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
            }

            // ── Hour indices ─────────────────────────────────────────────────
            for i in 1..<12 {       // i=0 is the triangle; handled above
                let angle    = Angle.degrees(Double(i) * 30.0 - 90)
                let cosA     = CGFloat(cos(angle.radians))
                let sinA     = CGFloat(sin(angle.radians))
                let isMajor  = i % 3 == 0   // 3, 6, 9
                let tickLen: CGFloat = isMajor ? d * 0.045 : d * 0.030  // 18px / 12px
                let lw:      CGFloat = isMajor ? 4 : 2

                var path = Path()
                path.move(to:    CGPoint(x: cx + cosA * markerR,             y: cy + sinA * markerR))
                path.addLine(to: CGPoint(x: cx + cosA * (markerR - tickLen), y: cy + sinA * (markerR - tickLen)))
                context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: lw, lineCap: .square))
            }

            // ── 3, 6, 9 numerals (inside the chapter ring) ──────────────────
            for (label, hour): (String, Double) in [("3", 3), ("6", 6), ("9", 9)] {
                let angle = Angle.degrees(hour * 30.0 - 90)
                let pt    = CGPoint(
                    x: cx + numR * CGFloat(cos(angle.radians)),
                    y: cy + numR * CGFloat(sin(angle.radians))
                )
                context.draw(
                    Text(label)
                        .font(.system(size: d * 0.085, weight: .heavy)),
                    at: pt
                )
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Brand Text

    private func airfieldBrand(d: CGFloat) -> some View {
        ZStack {
            Text("AIRFIELD")
                .font(.system(size: d * 0.042, weight: .black))
                .foregroundColor(.white.opacity(0.6))
                .offset(y: -d * 0.1313)
            Text("TYPE B  AUTOMATIC")
                .font(.system(size: d * 0.022))
                .foregroundColor(.white.opacity(0.35))
                .offset(y: -d * 0.0909)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Lume Dot

    /// Draws a lume dot at local point (0, -len*0.3), rotated by `angle` (matches HTML drawHand).
    private func lumeDot(d: CGFloat, len: CGFloat, dotDiameter: CGFloat, angle: Angle) -> some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let theta = angle.radians
            let localY = -len * 0.3
            let rx = -localY * CGFloat(sin(theta))
            let ry = localY * CGFloat(cos(theta))
            let r = dotDiameter / 2
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx + rx - r, y: cy + ry - r, width: dotDiameter, height: dotDiameter)),
                with: .color(Color(red: 0.71, green: 0.94, blue: 0.71).opacity(0.3))
            )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hands

    private func airfieldHands(d: CGFloat, date: Date) -> some View {
        let hourAngle   = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))
        let handOpacity: Double = isLuminanceReduced ? 0.55 : 1.0

        return ZStack {
            // Hour — length 88px, width 6px
            SwordHandShape(
                length:     d * 0.222,
                baseWidth:  d * 0.015,
                tailLength: d * 0.030
            )
            .fill(LinearGradient(
                colors: [.white.opacity(0.75 * handOpacity), .white.opacity(handOpacity), .white.opacity(0.75 * handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.7), radius: 3, x: 1, y: 1)
            .frame(width: d, height: d)
            .rotationEffect(hourAngle)

            // Lume dot on hour hand — hidden in AOD
            if !isLuminanceReduced {
                lumeDot(d: d, len: d * 0.222, dotDiameter: d * 0.0152, angle: hourAngle)
            }

            // Minute — length 122px, width 5px
            SwordHandShape(
                length:     d * 0.308,
                baseWidth:  d * 0.013,
                tailLength: d * 0.030
            )
            .fill(LinearGradient(
                colors: [.white.opacity(0.75 * handOpacity), .white.opacity(handOpacity), .white.opacity(0.75 * handOpacity)],
                startPoint: .leading, endPoint: .trailing
            ))
            .shadow(color: .black.opacity(0.7), radius: 3, x: 1, y: 1)
            .frame(width: d, height: d)
            .rotationEffect(minuteAngle)

            // Lume dot on minute hand — hidden in AOD
            if !isLuminanceReduced {
                lumeDot(d: d, len: d * 0.308, dotDiameter: d * 0.0126, angle: minuteAngle)
            }

            // Seconds + lollipop — hidden in AOD
            if !isLuminanceReduced {
                SubdialHandShape(length: d * 0.328, tailLength: d * 0.051, width: 2)
                    .fill(accent)
                    .frame(width: d, height: d)
                    .rotationEffect(secondAngle)

                Canvas { ctx, size in
                    let cx = size.width / 2, cy = size.height / 2
                    let tipDist  = d * 0.328
                    let blobDist = tipDist - d * 0.038
                    let secondRad = secondAngle.radians - .pi / 2
                    let bx = cx + CGFloat(cos(secondRad)) * blobDist
                    let by = cy + CGFloat(sin(secondRad)) * blobDist
                    ctx.fill(Path(ellipseIn: CGRect(x: bx - d*0.015, y: by - d*0.015,
                                                    width: d*0.030, height: d*0.030)),
                             with: .color(accent))
                }
                .allowsHitTesting(false)
            }
        }
    }
}
