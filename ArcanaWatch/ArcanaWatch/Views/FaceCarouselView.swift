import SwiftUI

/// Root view: horizontal swipe carousel of all watch faces.
/// Owns the shared data models and passes them to each face.
struct FaceCarouselView: View {
    @StateObject private var battery = BatteryModel()
    @StateObject private var weather = WeatherModel()
    @StateObject private var activity = ActivityModel()

    // Store an Int index rather than a String so TabView can bind directly
    // without an intermediate computed Binding, which is more reliable on watchOS.
    @AppStorage("selectedFaceIndex") private var selectedIndex: Int = 0

    @Environment(\.scenePhase) private var scenePhase
    /// True when the display enters low-power/always-on mode (wrist angled down).
    /// If the app has the com.apple.developer.aod-app entitlement this enables
    /// true always-on; without it, it still handles the dimmed appearance for
    /// the brief transition period before the screen turns off.
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    private let faces = WatchFaceType.allCases

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(faces.enumerated()), id: \.offset) { index, face in
                faceView(for: face)
                    .tag(index)
            }
        }
        .tabViewStyle(.carousel)
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        // Dim the face when luminance is reduced (wrist down / AOD mode).
        .overlay {
            if isLuminanceReduced {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        // Flush UserDefaults to disk on selection change so the value survives
        // watchOS terminating the app in the background.
        .onChange(of: selectedIndex) { _ in
            UserDefaults.standard.synchronize()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                UserDefaults.standard.synchronize()
            }
        }
    }

    @ViewBuilder
    private func faceView(for face: WatchFaceType) -> some View {
        switch face {
        case .airfield:
            AirfieldWatchFaceView(battery: battery, weather: weather, activity: activity)
        case .chronicler:
            ChroniclerWatchFaceView(battery: battery, weather: weather, activity: activity)
        case .depths:
            DepthsWatchFaceView(battery: battery, weather: weather, activity: activity)
        case .meridian:
            MeridianWatchFaceView(battery: battery, weather: weather, activity: activity)
        case .dualTime:
            DualTimeWatchFaceView(battery: battery, weather: weather, activity: activity)
        case .sws:
            SWSWatchFaceView(battery: battery, weather: weather, activity: activity)
        }
    }
}
