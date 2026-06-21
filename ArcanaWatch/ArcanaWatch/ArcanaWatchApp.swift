import SwiftUI
import WatchKit

// MARK: - Extended Runtime Session

/// Manages a WKExtendedRuntimeSession so the app keeps running in the
/// background when the wrist is lowered. Without this, watchOS terminates
/// the app after ~2 minutes and replaces it with the system watch face.
///
/// Strategy:
///  - Start an extended session on every background entry.
///  - Schedule a background-refresh task ~15 min out as a safety net; the
///    refresh handler restarts the session if it has lapsed.
///  - Chaining sessions directly from extendedRuntimeSessionWillExpire is
///    unreliable on watchOS, so the background-refresh is the primary renewal
///    mechanism after the first 30-minute window.
final class AppDelegate: NSObject, WKApplicationDelegate, WKExtendedRuntimeSessionDelegate {

    private var runtimeSession: WKExtendedRuntimeSession?

    // MARK: - WKApplicationDelegate

    func applicationDidEnterBackground() {
        startExtendedSession()
        scheduleBackgroundRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let refresh as WKApplicationRefreshBackgroundTask:
                // Restart the extended session and schedule the next refresh.
                startExtendedSession()
                scheduleBackgroundRefresh()
                refresh.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    // MARK: - Session management

    private func startExtendedSession() {
        // Skip if a session is already running or freshly started.
        switch runtimeSession?.state {
        case .running, .notStarted:
            return
        default:
            break
        }
        runtimeSession?.invalidate()
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
        runtimeSession = session
    }

    /// Schedule a background wakeup ~15 minutes from now.
    /// watchOS doesn't honour the exact date, but fires within a reasonable window.
    private func scheduleBackgroundRefresh() {
        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date(timeIntervalSinceNow: 15 * 60),
            userInfo: nil
        ) { _ in }
    }

    // MARK: - WKExtendedRuntimeSessionDelegate

    func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {}

    func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) {
        // Best-effort chain; may not be granted. The background-refresh
        // scheduled above is the reliable fallback.
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
