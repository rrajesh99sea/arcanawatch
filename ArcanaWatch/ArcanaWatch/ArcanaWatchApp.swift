import SwiftUI
import WatchKit

// MARK: - Extended Runtime Session

/// Manages a WKExtendedRuntimeSession so the app keeps running in the
/// background when the wrist is lowered. Without this, watchOS terminates
/// the app after ~2 minutes and replaces it with the system watch face.
final class AppDelegate: NSObject, WKApplicationDelegate, WKExtendedRuntimeSessionDelegate {

    private var runtimeSession: WKExtendedRuntimeSession?

    // Called when the wrist is lowered / display goes off.
    func applicationDidEnterBackground() {
        startExtendedSession()
    }

    private func startExtendedSession() {
        guard runtimeSession?.state != .running else { return }
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
        runtimeSession = session
    }

    // MARK: WKExtendedRuntimeSessionDelegate

    func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {}

    /// Called a few seconds before the session expires (~30 min limit).
    /// Restart immediately so coverage is continuous.
    func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) {
        runtimeSession = nil
        startExtendedSession()
    }

    func extendedRuntimeSession(_ session: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        runtimeSession = nil
    }
}

// MARK: - App

@main
struct ArcanaWatchApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            FaceCarouselView()
                .persistentSystemOverlays(.hidden)
        }
    }
}
