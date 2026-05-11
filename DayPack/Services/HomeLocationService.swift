import CoreLocation
import Foundation
import SwiftUI
import UserNotifications

@Observable
final class HomeLocationService: NSObject, CLLocationManagerDelegate {
    enum Presence {
        case unknown
        case atHome
        case away
        case unavailable
    }

    static let shared = HomeLocationService()

    private let manager = CLLocationManager()
    private let latitudeKey = "home.latitude"
    private let longitudeKey = "home.longitude"
    private let radius: CLLocationDistance = 150

    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var currentLocation: CLLocation?
    private(set) var homeCoordinate: CLLocationCoordinate2D?
    private(set) var lastError: String?
    private(set) var presence: Presence = .unknown

    var hasHomeLocation: Bool { homeCoordinate != nil }
    var isAtHome: Bool { presence == .atHome }
    var isAwayFromHome: Bool { presence == .away }

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        loadHome()
        startMonitoringIfPossible()
    }

    func refreshLocationState() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            presence = .unavailable
            return
        }

        manager.requestLocation()
        requestCurrentRegionState()

        if let currentLocation {
            updatePresence(using: currentLocation)
        }
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func useCurrentLocationAsHome() {
        if let location = currentLocation {
            setHome(location.coordinate)
        } else {
            manager.requestLocation()
        }
    }

    func setHome(_ coordinate: CLLocationCoordinate2D) {
        homeCoordinate = coordinate
        UserDefaults.standard.set(coordinate.latitude, forKey: latitudeKey)
        UserDefaults.standard.set(coordinate.longitude, forKey: longitudeKey)
        if let currentLocation {
            updatePresence(using: currentLocation)
        } else {
            presence = .unknown
        }
        startMonitoringIfPossible()
    }

    func clearHome() {
        UserDefaults.standard.removeObject(forKey: latitudeKey)
        UserDefaults.standard.removeObject(forKey: longitudeKey)
        homeCoordinate = nil
        for region in manager.monitoredRegions where region.identifier == "home" {
            manager.stopMonitoring(for: region)
        }
        presence = .unknown
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
            startMonitoringIfPossible()
        } else {
            presence = .unavailable
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        if homeCoordinate == nil, let coordinate = currentLocation?.coordinate {
            setHome(coordinate)
        } else if let currentLocation {
            updatePresence(using: currentLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error.localizedDescription
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier == "home" else { return }
        presence = .away
        Task { await notifyDeparture() }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == "home" else { return }
        presence = .atHome
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier == "home" else { return }
        switch state {
        case .inside:
            presence = .atHome
        case .outside:
            presence = .away
        case .unknown:
            presence = .unknown
        }
    }

    private func loadHome() {
        guard UserDefaults.standard.object(forKey: latitudeKey) != nil,
              UserDefaults.standard.object(forKey: longitudeKey) != nil
        else { return }
        homeCoordinate = CLLocationCoordinate2D(
            latitude: UserDefaults.standard.double(forKey: latitudeKey),
            longitude: UserDefaults.standard.double(forKey: longitudeKey)
        )
    }

    private func startMonitoringIfPossible() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self),
              authorizationStatus == .authorizedAlways,
              let homeCoordinate
        else { return }

        for region in manager.monitoredRegions where region.identifier == "home" {
            manager.stopMonitoring(for: region)
        }

        let region = CLCircularRegion(center: homeCoordinate, radius: radius, identifier: "home")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        manager.startMonitoring(for: region)
        manager.requestState(for: region)
    }

    private func requestCurrentRegionState() {
        guard authorizationStatus == .authorizedAlways else { return }
        for region in manager.monitoredRegions where region.identifier == "home" {
            manager.requestState(for: region)
        }
    }

    private func updatePresence(using location: CLLocation) {
        guard let homeCoordinate else {
            presence = .unknown
            return
        }

        let home = CLLocation(latitude: homeCoordinate.latitude, longitude: homeCoordinate.longitude)
        presence = location.distance(from: home) <= radius ? .atHome : .away
    }

    private func notifyDeparture() async {
        let content = UNMutableNotificationContent()
        content.title = "Walk-Out Check"
        content.body = "You left home. Check your DayPack before you go."
        content.sound = .default
        content.userInfo = ["dayPackAction": "walkOut"]

        let request = UNNotificationRequest(
            identifier: "home.departure.\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}

private struct HomeLocationServiceKey: EnvironmentKey {
    static let defaultValue: HomeLocationService = .shared
}

extension EnvironmentValues {
    var homeLocationService: HomeLocationService {
        get { self[HomeLocationServiceKey.self] }
        set { self[HomeLocationServiceKey.self] = newValue }
    }
}
