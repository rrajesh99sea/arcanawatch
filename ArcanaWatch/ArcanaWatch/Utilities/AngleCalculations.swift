import Foundation

/// Pure functions to compute rotation angles from a Date.
/// All angles are in degrees, with 0° = 12 o'clock, clockwise positive.
enum AngleCalculations {
    /// Hour hand angle with continuous movement influenced by minutes.
    static func hourAngle(from date: Date) -> Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date) % 12)
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        return (hour + minute / 60.0 + second / 3600.0) * 30.0
    }

    /// Minute hand angle with continuous movement influenced by seconds.
    static func minuteAngle(from date: Date) -> Double {
        let calendar = Calendar.current
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        return (minute + second / 60.0) * 6.0
    }

    /// Small seconds hand angle (ticks each second for mechanical feel).
    static func secondAngle(from date: Date) -> Double {
        let calendar = Calendar.current
        let second = Double(calendar.component(.second, from: date))
        return second * 6.0
    }

    /// Day of month (1–31).
    static func dayOfMonth(from date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
}
