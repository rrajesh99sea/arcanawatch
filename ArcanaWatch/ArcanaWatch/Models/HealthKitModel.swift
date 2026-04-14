import Foundation
import HealthKit
import Combine

/// Streams live heart rate from HealthKit using an anchored object query.
final class HealthKitModel: ObservableObject {
    @Published var heartRate: Double?
    @Published var isAuthorized = false

    private let store = HKHealthStore()
    private var query: HKAnchoredObjectQuery?

    init() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        requestAuthorization()
    }

    func requestAuthorization() {
        guard let hrType = HKQuantityType.quantityType(
            forIdentifier: .heartRate
        ) else { return }

        store.requestAuthorization(toShare: nil, read: [hrType]) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success { self?.startQuery() }
            }
        }
    }

    private func startQuery() {
        guard let hrType = HKQuantityType.quantityType(
            forIdentifier: .heartRate
        ) else { return }

        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.process(samples: samples)
        }

        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.process(samples: samples)
        }

        self.query = query
        store.execute(query)
    }

    private func process(samples: [HKSample]?) {
        guard let quantitySamples = samples as? [HKQuantitySample],
              let latest = quantitySamples.last else { return }

        let bpm = latest.quantity.doubleValue(
            for: HKUnit.count().unitDivided(by: .minute())
        )

        DispatchQueue.main.async {
            self.heartRate = bpm
        }
    }

    deinit {
        if let query { store.stop(query) }
    }
}
