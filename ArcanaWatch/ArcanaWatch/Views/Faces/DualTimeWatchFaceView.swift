import SwiftUI

/// Dual-time watch face — four analog dials in a 2×2 grid, each showing a different timezone.
/// No seconds hand. Dial background shifts with the local hour (night/dawn/day/dusk).
/// A date box shows the local calendar date, since timezones can differ by a day.
/// Tap any dial to cycle it through the city list.
struct DualTimeWatchFaceView: View {
    @ObservedObject var battery: BatteryModel
    @ObservedObject var weather: WeatherModel
    @ObservedObject var activity: ActivityModel

    static let cities: [DualTimeCity] = [
        DualTimeCity(code: "NYC", name: "New York",      identifier: "America/New_York"),
        DualTimeCity(code: "LON", name: "London",        identifier: "Europe/London"),
        DualTimeCity(code: "PAR", name: "Paris",         identifier: "Europe/Paris"),
        DualTimeCity(code: "DXB", name: "Dubai",         identifier: "Asia/Dubai"),
        DualTimeCity(code: "BLR", name: "Bengaluru",     identifier: "Asia/Kolkata"),
        DualTimeCity(code: "SIN", name: "Singapore",     identifier: "Asia/Singapore"),
        DualTimeCity(code: "TYO", name: "Tokyo",         identifier: "Asia/Tokyo"),
        DualTimeCity(code: "SYD", name: "Sydney",        identifier: "Australia/Sydney"),
        DualTimeCity(code: "LAX", name: "Los Angeles",   identifier: "America/Los_Angeles"),
        DualTimeCity(code: "SFO", name: "San Francisco", identifier: "America/Los_Angeles"),
        DualTimeCity(code: "DEL", name: "New Delhi",     identifier: "Asia/Kolkata"),
        DualTimeCity(code: "ZUR", name: "Zurich",        identifier: "Europe/Zurich"),
        DualTimeCity(code: "SEA", name: "Seattle",       identifier: "America/Los_Angeles"),
    ]

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    @AppStorage("dualTimeTLCity") private var tlCode: String = "NYC"
    @AppStorage("dualTimeTRCity") private var trCode: String = "LON"
    @AppStorage("dualTimeBLCity") private var blCode: String = "BLR"
    @AppStorage("dualTimeBRCity") private var brCode: String = "TYO"

    private let dialRim  = Color(red: 0.55, green: 0.57, blue: 0.62)
    private let chapter  = Color(red: 0.85, green: 0.87, blue: 0.92)
    private let accent   = Color(red: 0.92, green: 0.78, blue: 0.42)

    var body: some View {
        TimelineView(.periodic(from: .now, by: isLuminanceReduced ? 60 : 1)) { context in
            GeometryReader { geo in
                let w    = geo.size.width
                let h    = geo.size.height
                let gap  = min(w, h) * 0.03
                let diam = min((w - gap) / 2, (h - gap) / 2)
                let date = context.date

                ZStack {
                    (isLuminanceReduced ? Color.black : Color(red: 0.01, green: 0.02, blue: 0.04)).ignoresSafeArea()

                    VStack(spacing: gap) {
                        HStack(spacing: gap) {
                            miniDial(diameter: diam, date: date,
                                     city: cityFor(tlCode),
                                     onTap: { advance(&tlCode, excluding: [trCode, blCode, brCode]) })
                            miniDial(diameter: diam, date: date,
                                     city: cityFor(trCode),
                                     onTap: { advance(&trCode, excluding: [tlCode, blCode, brCode]) })
                        }
                        HStack(spacing: gap) {
                            miniDial(diameter: diam, date: date,
                                     city: cityFor(blCode),
                                     onTap: { advance(&blCode, excluding: [tlCode, trCode, brCode]) })
                            miniDial(diameter: diam, date: date,
                                     city: cityFor(brCode),
                                     onTap: { advance(&brCode, excluding: [tlCode, trCode, blCode]) })
                        }
                    }
                    .frame(width: w, height: h)
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Mini Dial

    @ViewBuilder
    private func miniDial(diameter: CGFloat,
                          date: Date,
                          city: DualTimeCity,
                          onTap: @escaping () -> Void) -> some View {
        let info   = timeInfo(for: date, in: city.identifier)
        let bgCol  = isLuminanceReduced ? Color.black : dialBackground(hour24: info.hour24)
        let r      = diameter / 2

        ZStack {
            // Background circle with time-of-day tint (black in AOD)
            Circle()
                .fill(bgCol)
                .frame(width: diameter, height: diameter)

            // Rim (dimmed in AOD)
            Circle()
                .strokeBorder(dialRim.opacity(isLuminanceReduced ? 0.20 : 0.65), lineWidth: max(1, diameter * 0.016))
                .frame(width: diameter, height: diameter)

            // Hour pips
            ForEach(0..<12, id: \.self) { i in
                let major = i % 3 == 0
                Rectangle()
                    .fill(chapter.opacity(major ? 0.90 : 0.60))
                    .frame(width: max(1, r * 0.034),
                           height: major ? r * 0.13 : r * 0.07)
                    .offset(y: -(r * 0.84 - (major ? r * 0.065 : r * 0.035)))
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            // City code — hidden in AOD
            if !isLuminanceReduced {
                Text(city.code)
                    .font(.system(size: diameter * 0.125, weight: .semibold, design: .rounded))
                    .foregroundColor(accent.opacity(0.90))
                    .offset(y: r * 0.22)
            }

            // Hands (hour + minute only)
            dualHands(diameter: diameter, info: info)

            // Center cap
            Circle()
                .fill(accent)
                .frame(width: r * 0.16, height: r * 0.16)
            Circle()
                .fill(bgCol)
                .frame(width: r * 0.076, height: r * 0.076)
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
        .onTapGesture(perform: onTap)
    }

    // MARK: - Hands (hour + minute, no seconds)

    @ViewBuilder
    private func dualHands(diameter: CGFloat, info: TimeInfo) -> some View {
        let r = diameter / 2
        ZStack {
            // Hour hand
            Capsule()
                .fill(chapter.opacity(0.95))
                .frame(width: r * 0.09, height: r * 0.62)
                .offset(y: -(r * 0.31))
                .rotationEffect(info.hourAngle)

            // Minute hand
            Capsule()
                .fill(chapter.opacity(0.95))
                .frame(width: r * 0.055, height: r * 0.84)
                .offset(y: -(r * 0.42))
                .rotationEffect(info.minuteAngle)
        }
    }

    // MARK: - Time-of-day background

    private func dialBackground(hour24: Int) -> Color {
        switch hour24 {
        case 22...23, 0..<5:  return Color(red: 0.016, green: 0.031, blue: 0.055) // deep night
        case 5..<7:            return Color(red: 0.075, green: 0.047, blue: 0.110) // pre-dawn
        case 7..<10:           return Color(red: 0.040, green: 0.082, blue: 0.125) // morning
        case 10..<17:          return Color(red: 0.047, green: 0.094, blue: 0.157) // day
        case 17..<20:          return Color(red: 0.110, green: 0.055, blue: 0.031) // dusk
        default:               return Color(red: 0.047, green: 0.031, blue: 0.094) // evening
        }
    }

    // MARK: - Time extraction

    struct TimeInfo {
        let hour24: Int
        let hourAngle: Angle
        let minuteAngle: Angle
    }

    private func timeInfo(for date: Date, in tzId: String) -> TimeInfo {
        let tz = TimeZone(identifier: tzId) ?? .current
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let c = cal.dateComponents([.hour, .minute, .second], from: date)
        let h24 = c.hour   ?? 0
        let m   = Double(c.minute ?? 0)
        let s   = Double(c.second ?? 0)
        let h12 = Double(h24 % 12)
        return TimeInfo(
            hour24:      h24,
            hourAngle:   .degrees((h12 + m / 60.0) * 30.0),
            minuteAngle: .degrees((m + s / 60.0) * 6.0)
        )
    }

    // MARK: - City helpers

    private func cityFor(_ code: String) -> DualTimeCity {
        DualTimeWatchFaceView.cities.first { $0.code == code }
            ?? DualTimeWatchFaceView.cities[0]
    }

    /// Advances `code` to the next city in the list, skipping any city whose
    /// timezone identifier is already shown in one of the other three dials
    /// (e.g. LAX and SFO share "America/Los_Angeles" — showing both is redundant).
    private func advance(_ code: inout String, excluding others: [String]) {
        let list = DualTimeWatchFaceView.cities
        let usedIdentifiers = Set(others.map { cityFor($0).identifier })
        let startIndex = list.firstIndex(where: { $0.code == code }) ?? 0

        var i = startIndex
        for _ in 0..<list.count {
            i = (i + 1) % list.count
            if !usedIdentifiers.contains(list[i].identifier) {
                code = list[i].code
                return
            }
        }
        // All other timezones are already in use elsewhere — fall back to a
        // plain advance so the tap still does something.
        code = list[(startIndex + 1) % list.count].code
    }
}

struct DualTimeCity: Hashable {
    let code: String       // 3-letter display code
    let name: String       // human-readable name
    let identifier: String // TimeZone identifier
}
