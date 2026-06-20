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

    // ─── Typography scale ──────────────────────────────────────────────
    // All sizes are ratios of watch diameter so they auto-scale across
    // sizes (40/41/45/46/49 mm). Calibrated so the smallest tier
    // (fontCaptionXS) clears Apple's ~11 pt readable floor on a typical
    // 198-pt-diameter Apple Watch screen. Use these named tiers in face
    // views instead of inline ratios — that way one knob retunes
    // legibility everywhere.
    //
    //   Ratio   ≈pt @198dia  Use for
    //   ─────   ───────────  ──────────────────────────────────────────
    static let fontCaptionXS:  CGFloat = 0.060   // ≈12 pt — tiny annotations, brand subtitles
    static let fontCaption:    CGFloat = 0.068   // ≈13.5 pt — labels (TMP, BAT, M/E/S, bezel #s)
    static let fontBody:       CGFloat = 0.075   // ≈15 pt — body text, paired weather icons
    static let fontValue:      CGFloat = 0.085   // ≈17 pt — primary data values (battery%, rain%)
    static let fontValueLg:    CGFloat = 0.100   // ≈20 pt — prominent data displays (temp, date)
    static let fontNumeral:    CGFloat = 0.090   // ≈18 pt — chapter-ring numerals
    static let fontNumeralLg:  CGFloat = 0.115   // ≈23 pt — prominent dial numerals
    static let fontHero:       CGFloat = 0.150   // ≈30 pt — hero hour numerals (pilot/field)
}
