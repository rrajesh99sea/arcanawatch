import SwiftUI

enum WatchConstants {
    // Dial proportions (relative to diameter D)
    static let dialRatio: CGFloat       = 0.92
    static let bezelWidth: CGFloat      = 0.025

    // Baton indices
    static let batonLength: CGFloat     = 0.06
    static let batonWidth: CGFloat      = 0.01

    // Minute ticks
    static let minuteTickLength: CGFloat = 0.02
    static let minuteTickWidth: CGFloat  = 0.004

    // Hour hand
    static let hourHandLength: CGFloat   = 0.30
    static let hourHandBaseWidth: CGFloat = 0.032

    // Minute hand
    static let minuteHandLength: CGFloat    = 0.42
    static let minuteHandBaseWidth: CGFloat = 0.024

    // Subdials
    static let subdialDiameter: CGFloat  = 0.24
    static let subdialOffset: CGFloat    = 0.26

    // Center pin
    static let centerPinRadius: CGFloat  = 0.03
    static let centerDotRadius: CGFloat  = 0.01

    // Colors
    static let dialBlack   = Color(red: 0.04, green: 0.04, blue: 0.04)
    static let silverLight = Color(red: 0.91, green: 0.91, blue: 0.91)
    static let silver      = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let silverDark  = Color(red: 0.50, green: 0.50, blue: 0.50)
    static let tickGray    = Color(red: 0.33, green: 0.33, blue: 0.33)
    static let dateWhite   = Color(red: 0.96, green: 0.96, blue: 0.96)

    // Roman numeral positions (hours where Roman numerals appear)
    static let romanHours: [Int] = [12, 3, 9]

    // Baton index positions (skip 3, 6, 9, 12 — those have numerals or subdials)
    static let batonHours: [Int] = [1, 2, 4, 5, 7, 8, 10, 11]

    // Font
    static let romanFontName = "Georgia"
}
