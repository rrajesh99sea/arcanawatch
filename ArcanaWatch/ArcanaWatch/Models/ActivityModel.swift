import Foundation
import HealthKit
import Combine

/// ObservableObject that provides today's activity ring progress via HealthKit.
final class ActivityModel: ObservableObject {
    /// Progress values as fraction of goal (0.0 = none, 1.0 = goal met, >1.0 = exceeded).
    @Published var moveProgress: Double = 0
    @Published var exerciseProgress: Double = 0
    @Published var standProgress: Double = 0
    @Published var isAuthorized = false

    private let store = HKHealthStore()
    private var timer: AnyCancellable?

    init() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        requestAuthorization()

        // Refresh every 60 seconds
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchActivityData()
            }
    }

    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.activitySummaryType()
        ]

        store.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success { self?.fetchActivityData() }
            }
        }
    }

    func fetchActivityData() {
        let calendar = Calendar.current
        let now = Date()
        _ = calendar.dateComponents([.year, .month, .day], from: now)

        var queryComponents = calendar.dateComponents([.year, .month, .day, .era], from: now)
        queryComponents.calendar = calendar
        let predicate = HKQuery.predicateForActivitySummary(with: queryComponents)

        let query = HKActivitySummaryQuery(predicate: predicate) { [weak self] _, summaries, _ in
            guard let summary = summaries?.first else { return }

            let moveBurned = summary.activeEnergyBurned.doubleValue(for: .kilocalorie())
            let moveGoal = summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie())
            let exerciseDone = summary.appleExerciseTime.doubleValue(for: .minute())
            let exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: .minute())
            let standDone = summary.appleStandHours.doubleValue(for: .count())
            let standGoal = summary.appleStandHoursGoal.doubleValue(for: .count())

            DispatchQueue.main.async {
                self?.moveProgress = moveGoal > 0 ? moveBurned / moveGoal : 0
                self?.exerciseProgress = exerciseGoal > 0 ? exerciseDone / exerciseGoal : 0
                self?.standProgress = standGoal > 0 ? standDone / standGoal : 0
            }
        }

        store.execute(query)
    }
}
