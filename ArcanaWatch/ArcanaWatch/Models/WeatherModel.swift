import Foundation
import WeatherKit
import CoreLocation

/// ObservableObject that provides current temperature and rain data via WeatherKit.
final class WeatherModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var temperatureValue: Double = 0      // degrees Fahrenheit
    @Published var rainChance: Double = 0             // 0.0–1.0
    @Published var isRaining: Bool = false
    @Published var conditionSymbol: String = "sun.max" // SF Symbol name

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var refreshTask: Task<Void, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        fetchWeather(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently handle — will retry on next location update
    }

    // MARK: - Weather Fetching

    private func fetchWeather(for location: CLLocation) {
        refreshTask?.cancel()
        refreshTask = Task { @MainActor in
            do {
                let current = try await WeatherService.shared.weather(
                    for: location,
                    including: .current
                )

                self.temperatureValue = current.temperature.converted(to: .fahrenheit).value
                self.conditionSymbol = current.symbolName

                let rainy = current.condition == .rain ||
                            current.condition == .heavyRain ||
                            current.condition == .drizzle
                self.isRaining = rainy

                // Derive rain likelihood from current conditions
                if rainy {
                    self.rainChance = 0.85
                } else {
                    self.rainChance = current.humidity > 0.8 ? 0.3 : 0.05
                }
            } catch {
                // Weather unavailable — keep defaults
            }
        }
    }

    /// Call periodically to refresh (e.g. every 15 minutes).
    func refresh() {
        if let location = lastLocation {
            fetchWeather(for: location)
        } else {
            locationManager.requestLocation()
        }
    }
}
