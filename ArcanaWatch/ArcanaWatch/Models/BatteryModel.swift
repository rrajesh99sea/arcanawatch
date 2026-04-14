import SwiftUI
import WatchKit
import Combine

/// ObservableObject that polls battery level every 60 seconds.
final class BatteryModel: ObservableObject {
    @Published var level: Float = 1.0

    private var timer: AnyCancellable?

    init() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        updateLevel()
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLevel()
            }
    }

    private func updateLevel() {
        let raw = WKInterfaceDevice.current().batteryLevel
        // batteryLevel returns -1 if monitoring is disabled
        level = raw >= 0 ? raw : 1.0
    }
}
