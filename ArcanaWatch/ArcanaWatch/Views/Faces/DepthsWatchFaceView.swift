import SwiftUI

// MARK: - Diver hand shape (broad-arrow style matching HTML _drawDiverHand)
private struct DiverHandShape: Shape {
    let length: CGFloat
    let baseWidth: CGFloat
    var tailLength: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let midY = rect.midY
        let hw = baseWidth / 2       // half base-width
        let fw = baseWidth / 1.2     // flare half-width (w/1.2 in HTML)

        var path = Path()
        path.move(to: CGPoint(x: midX - hw, y: midY + tailLength))
        path.addLine(to: CGPoint(x: midX - hw, y: midY))
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX - fw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX - fw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX - hw, y: midY - length))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX + fw, y: midY - length * 0.70))
        path.addLine(to: CGPoint(x: midX + fw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX + hw, y: midY - length * 0.30))
        path.addLine(to: CGPoint(x: midX + hw, y: midY))
        path.addLine(to: CGPoint(x: midX + hw, y: midY + tailLength))
        path.closeSubpath()
        return path
    }
}

/// Professional dive watch with green lume and rotating bezel.
struct DepthsWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    private let deepGreen = Color(red: 0.04, green: 0.10, blue: 0.04)
    private let lumeGreen = Color(red: 0.40, green: 0.85, blue: 0.35)
    private let bezelGray = Color(red: 0.15, green: 0.15, blue: 0.15)

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : 1)) { context in
            GeometryReader { geo in
                let diameter = min(geo.size.width, geo.size.height)
                let date = context.date

                ZStack {
                    Color.black

                    // Bezel ring — hidden in AOD
                    if !isLuminanceReduced { diveBezel(diameter: diameter, date: date) }

                    // Dark green dial
                    Circle()
                        .fill(RadialGradient(
                            colors: isLuminanceReduced
                                ? [Color(red: 0.02, green: 0.05, blue: 0.02), Color.black]
                                : [deepGreen, Color(red: 0.02, green: 0.04, blue: 0.02)],
                            center: .center, startRadius: 0, endRadius: diameter * 0.43
                        ))
                        .frame(width: diameter * 0.859, height: diameter * 0.859)

                    // Hour markers with lume (dimmed in AOD)
                    lumeMarkers(diameter: diameter)

                    // Date window — hidden in AOD
                    if !isLuminanceReduced { depthsDateWindow(diameter: diameter, date: date) }

                    // Brand text — hidden in AOD
                    if !isLuminanceReduced { depthsBrand(diameter: diameter) }

                    // Broad-arrow hands
                    depthsHands(diameter: diameter, date: date)

                    // Center pin
                    Circle()
                        .fill(isLuminanceReduced ? Color(white: 0.3) : Color.red)
                        .frame(width: diameter * 0.025, height: diameter * 0.025)
                    Circle()
                        .fill(Color.black)
                        .frame(width: diameter * 0.01, height: diameter * 0.01)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Dive Bezel

    private func diveBezel(diameter: CGFloat, date: Date) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = diameter / 2
            let innerR = diameter * 0.41

            // Bezel ring — subtle radial shading for a domed, dimensional look
            let ring = Path(ellipseIn: CGRect(x: center.x - outerR, y: center.y - outerR,
                                               width: outerR * 2, height: outerR * 2))
            context.fill(ring, with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.24, green: 0.24, blue: 0.24),
                    bezelGray,
                    Color(red: 0.08, green: 0.08, blue: 0.08)
                ]),
                center: center, startRadius: innerR, endRadius: outerR
            ))

            // 60-minute scale ticks
            // Positions that carry a bezel number (10/20/30/40/50) have no
            // tick at all — the number itself is the marker, so nothing
            // draws a "bar" through/behind it.
            let numberTicks: Set<Int> = [10, 20, 30, 40, 50]
            for i in 0..<60 {
                if numberTicks.contains(i) { continue }
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                let tickOuter = outerR - diameter * 0.01
                let tickInner = i % 5 == 0 ? innerR + diameter * 0.02 : outerR - diameter * 0.03
                var tick = Path()
                tick.move(to: CGPoint(x: center.x + cosA * tickOuter, y: center.y + sinA * tickOuter))
                tick.addLine(to: CGPoint(x: center.x + cosA * tickInner, y: center.y + sinA * tickInner))
                context.stroke(tick, with: .color(.white.opacity(i % 5 == 0 ? 0.8 : 0.3)),
                               lineWidth: i % 5 == 0 ? 1.5 : 0.5)
            }

            // Bezel numbers (10, 20, 30, 40, 50)
            let numR = (outerR + innerR) / 2 + diameter * 0.01
            for n in [10, 20, 30, 40, 50] {
                let angle = Angle.degrees(Double(n) * 6 - 90)
                let pt = CGPoint(x: center.x + numR * CGFloat(cos(angle.radians)),
                                 y: center.y + numR * CGFloat(sin(angle.radians)))
                context.draw(
                    Text("\(n)").font(.system(size: diameter * WatchConstants.fontCaption, weight: .bold)).foregroundColor(lumeGreen),
                    at: pt
                )
            }

            // Triangle at 0
            let triTop = CGPoint(x: center.x, y: center.y - (outerR - diameter * 0.015))
            var tri = Path()
            tri.move(to: triTop)
            tri.addLine(to: CGPoint(x: center.x - diameter * 0.015, y: triTop.y + diameter * 0.025))
            tri.addLine(to: CGPoint(x: center.x + diameter * 0.015, y: triTop.y + diameter * 0.025))
            tri.closeSubpath()
            context.fill(tri, with: .color(lumeGreen))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Lume Markers

    private func lumeMarkers(diameter: CGFloat) -> some View {
        // HTML: markers translated to (markerR-12)=136px from center, then fillRect.
        // Major (3/6/9): 10×28px rect → center at 136, outer edge 150, inner 122.
        // Minor (others): 6×20px rect → center at 136, outer 146, inner 126.
        // In SwiftUI .offset(y:) moves the center, so: center = (136/396)*d = 0.343*d
        let centerR   = diameter * 0.343   // 136/396 — center of each marker rect
        let majW      = diameter * 0.025   // 10/396
        let majH      = diameter * 0.071   // 28/396
        let minW      = diameter * 0.015   //  6/396
        let minH      = diameter * 0.051   // 20/396

        return ZStack {
            // Triangle at 12 (HTML: moveTo(0,-10), lineTo(-6,6), lineTo(6,6))
            Canvas { context, size in
                let cx   = size.width / 2
                let cy   = size.height / 2
                // Triangle tip 10px above the translated center, base 6px below.
                // Translated center is at markerR-12 = 136px above watch center.
                let tipY  = cy - diameter * 0.343 - diameter * 0.025   // 10/396
                let baseY = cy - diameter * 0.343 + diameter * 0.015   //  6/396
                let hw    = diameter * 0.015                            //  6/396
                var path  = Path()
                path.move(to:    CGPoint(x: cx,      y: tipY))
                path.addLine(to: CGPoint(x: cx - hw, y: baseY))
                path.addLine(to: CGPoint(x: cx + hw, y: baseY))
                path.closeSubpath()
                context.fill(path, with: .color(lumeGreen.opacity(0.9)))
            }
            .allowsHitTesting(false)

            // Rectangle markers at 3, 6, 9
            ForEach([3, 6, 9], id: \.self) { hour in
                RoundedRectangle(cornerRadius: 1)
                    .fill(lumeGreen.opacity(0.85))
                    .frame(width: majW, height: majH)
                    .offset(y: -centerR)
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
            // Smaller rectangles at other hours
            ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                RoundedRectangle(cornerRadius: 1)
                    .fill(lumeGreen.opacity(0.60))
                    .frame(width: minW, height: minH)
                    .offset(y: -centerR)
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
        }
    }

    // MARK: - Date Window

    private func depthsDateWindow(diameter: CGFloat, date: Date) -> some View {
        let day = AngleCalculations.dayOfMonth(from: date)
        return ZStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.91, green: 0.91, blue: 0.91))
                .frame(width: diameter * 0.091, height: diameter * 0.056)
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color(red: 0.2, green: 0.2, blue: 0.2), lineWidth: 0.5)
                .frame(width: diameter * 0.091, height: diameter * 0.056)
            Text("\(day)")
                .font(.system(size: diameter * 0.04, weight: .bold))
                .foregroundColor(.black)
        }
        .offset(x: diameter * 0.202)
        .allowsHitTesting(false)
    }

    // MARK: - Brand Text

    private func depthsBrand(diameter: CGFloat) -> some View {
        ZStack {
            Text("DEPTHS")
                .font(.custom(WatchConstants.romanFontName, size: diameter * 0.038))
                .foregroundColor(lumeGreen.opacity(0.5))
                .offset(y: -diameter * 0.121)
            Text("300M  AUTOMATIC")
                .font(.custom(WatchConstants.romanFontName, size: diameter * 0.020))
                .foregroundColor(lumeGreen.opacity(0.3))
                .offset(y: -diameter * 0.083)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Hands

    private func depthsHands(diameter: CGFloat, date: Date) -> some View {
        let hourAngle   = Angle.degrees(AngleCalculations.hourAngle(from: date))
        let minuteAngle = Angle.degrees(AngleCalculations.minuteAngle(from: date))
        let secondAngle = Angle.degrees(AngleCalculations.secondAngle(from: date))
        let handDark    = isLuminanceReduced
            ? Color(red: 0.10, green: 0.10, blue: 0.10)
            : Color(red: 0.19, green: 0.19, blue: 0.19)

        return ZStack {
            // Hour hand
            diverHand(diameter: diameter, length: diameter * 0.232,
                      baseWidth: diameter * 0.025, tailLength: diameter * 0.030,
                      bodyColor: handDark, angle: hourAngle)

            // Minute hand
            diverHand(diameter: diameter, length: diameter * 0.328,
                      baseWidth: diameter * 0.020, tailLength: diameter * 0.030,
                      bodyColor: handDark, angle: minuteAngle)

            // Seconds — hidden in AOD
            if !isLuminanceReduced {
                Canvas { ctx, size in
                    let cx = size.width / 2, cy = size.height / 2
                    let sRad = secondAngle.radians - .pi / 2
                    let tipDist  = diameter * 0.354
                    let blobDist = tipDist - diameter * 0.025
                    let tx = cx + CGFloat(cos(sRad)) * tipDist
                    let ty = cy + CGFloat(sin(sRad)) * tipDist
                    let tailX = cx - CGFloat(cos(sRad)) * diameter * 0.056
                    let tailY = cy - CGFloat(sin(sRad)) * diameter * 0.056
                    let bx = cx + CGFloat(cos(sRad)) * blobDist
                    let by = cy + CGFloat(sin(sRad)) * blobDist
                    var needle = Path()
                    needle.move(to: CGPoint(x: tailX, y: tailY))
                    needle.addLine(to: CGPoint(x: tx, y: ty))
                    ctx.stroke(needle, with: .color(.red), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    ctx.fill(Path(ellipseIn: CGRect(x: bx - diameter*0.013, y: by - diameter*0.013,
                                                   width: diameter*0.025, height: diameter*0.025)),
                             with: .color(.red))
                }
                .allowsHitTesting(false)
            }
        }
    }

    /// Draws a diver broad-arrow hand as dark body + lume inlay strips.
    private func diverHand(diameter: CGFloat, length: CGFloat, baseWidth: CGFloat,
                           tailLength: CGFloat, bodyColor: Color, angle: Angle) -> some View {
        ZStack {
            // Dark body
            DiverHandShape(length: length, baseWidth: baseWidth, tailLength: tailLength)
                .fill(bodyColor)
                .shadow(color: .black.opacity(0.8), radius: 3, x: 1, y: 1)
                .frame(width: diameter, height: diameter)
                .rotationEffect(angle)

            // Lume inlay — shoulder strip (30–68%) + tip strip (78–100%)
            // Made thicker and brighter, with a soft glow, per design feedback.
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height / 2
                let hw = baseWidth / 1.8   // thicker inlay (was /4)
                let theta = angle.radians
                // Clockwise rotation in screen coords (y-down):
                // x' = x*cos(θ) - y*sin(θ),  y' = x*sin(θ) + y*cos(θ)

                let strips: [(CGFloat, CGFloat)] = [
                    (length * 0.30, length * 0.68),   // shoulder lume
                    (length * 0.78, length)            // tip lume
                ]
                for (yStart, yEnd) in strips {
                    let localCorners: [(CGFloat, CGFloat)] = [
                        (-hw, -yStart), (hw, -yStart), (hw, -yEnd), (-hw, -yEnd)
                    ]
                    var p = Path()
                    let pts = localCorners.map { (x, y) -> CGPoint in
                        let rx = x * CGFloat(cos(theta)) - y * CGFloat(sin(theta))
                        let ry = x * CGFloat(sin(theta)) + y * CGFloat(cos(theta))
                        return CGPoint(x: cx + rx, y: cy + ry)
                    }
                    p.move(to: pts[0])
                    pts.dropFirst().forEach { p.addLine(to: $0) }
                    p.closeSubpath()

                    ctx.drawLayer { layerCtx in
                        layerCtx.addFilter(.shadow(color: lumeGreen, radius: diameter * 0.02))
                        layerCtx.fill(p, with: .color(lumeGreen.opacity(0.95)))
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
