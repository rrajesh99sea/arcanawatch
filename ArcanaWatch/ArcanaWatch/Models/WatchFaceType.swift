import Foundation

/// All available watch face designs.
/// Curated to four keepers (per design review) plus a new Dual-Time face.
enum WatchFaceType: String, CaseIterable, Identifiable {
    case airfield
    case chronicler
    case depths
    case meridian
    case dualTime
    case sws

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .airfield:   return "Airfield"
        case .chronicler: return "Chronicler"
        case .depths:     return "Depths"
        case .meridian:   return "Meridian"
        case .dualTime:   return "Dual Time"
        case .sws:        return "SWS"
        }
    }
}
