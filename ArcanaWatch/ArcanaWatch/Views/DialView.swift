import SwiftUI

/// The main dial: sunburst texture, minute ticks, baton indices, and Roman numerals.
struct DialView: View {
    let diameter: CGFloat

    private var dialRadius: CGFloat { diameter * WatchConstants.dialRatio / 2 }

    var body: some View {
        ZStack {
            sunburstDial
            minuteTicks
            batonIndices
            romanNumerals
        }
        .frame(width: diameter, height: diameter)
    }

    // MARK: - Sunburst texture

    private var sunburstDial: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = dialRadius
            let circle = Path(ellipseIn: CGRect(
                x: center.x - r, y: center.y - r,
                width: r * 2, height: r * 2
            ))
            // Base black fill
            context.fill(circle, with: .color(WatchConstants.dialBlack))
            // Sunburst: alternating subtle radial bands
            let slices = 72
            for i in 0..<slices {
                let startAngle = Angle.degrees(Double(i) * 360.0 / Double(slices))
                let endAngle = Angle.degrees(Double(i + 1) * 360.0 / Double(slices))
                var slicePath = Path()
                slicePath.move(to: center)
                slicePath.addArc(center: center, radius: r,
                                 startAngle: startAngle, endAngle: endAngle,
                                 clockwise: false)
                slicePath.closeSubpath()
                let alpha: Double = i % 2 == 0 ? 0.03 : 0.06
                context.fill(slicePath, with: .color(.white.opacity(alpha)))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Minute ticks

    private var minuteTicks: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerR = dialRadius - 2
            let tickLen = diameter * WatchConstants.minuteTickLength
            for i in 0..<60 {
                if i % 5 == 0 { continue }
                let angle = Angle.degrees(Double(i) * 6 - 90)
                let cosA = CGFloat(cos(angle.radians))
                let sinA = CGFloat(sin(angle.radians))
                let outer = CGPoint(x: center.x + cosA * outerR,
                                    y: center.y + sinA * outerR)
                let inner = CGPoint(x: center.x + cosA * (outerR - tickLen),
                                    y: center.y + sinA * (outerR - tickLen))
                var tick = Path()
                tick.move(to: outer)
                tick.addLine(to: inner)
                context.stroke(tick,
                               with: .color(WatchConstants.tickGray),
                               lineWidth: diameter * WatchConstants.minuteTickWidth)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Baton indices

    private var batonIndices: some View {
        ForEach(WatchConstants.batonHours, id: \.self) { hour in
            let angle = Angle.degrees(Double(hour) * 30)
            let outerR = dialRadius - 2
            let length = diameter * WatchConstants.batonLength
            let width = diameter * WatchConstants.batonWidth

            BatonIndexShape()
                .fill(
                    LinearGradient(
                        colors: [WatchConstants.silverDark,
                                 WatchConstants.silverLight,
                                 WatchConstants.silverDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: length)
                .offset(y: -(outerR - length / 2))
                .rotationEffect(angle)
        }
    }

    // MARK: - Roman numerals

    private var romanNumerals: some View {
        let r = dialRadius - diameter * WatchConstants.batonLength - diameter * 0.03

        return ForEach(WatchConstants.romanHours, id: \.self) { hour in
            let text = romanText(for: hour)
            let angle = Angle.degrees(Double(hour) * 30 - 90)
            let x = CGFloat(cos(angle.radians)) * r
            let y = CGFloat(sin(angle.radians)) * r

            Text(text)
                .font(.custom(WatchConstants.romanFontName, size: diameter * 0.055))
                .foregroundColor(WatchConstants.silver)
                .offset(x: x, y: y)
        }
    }

    private func romanText(for hour: Int) -> String {
        switch hour {
        case 12: return "XII"
        case 3:  return "III"
        case 9:  return "IX"
        default: return ""
        }
    }
}
