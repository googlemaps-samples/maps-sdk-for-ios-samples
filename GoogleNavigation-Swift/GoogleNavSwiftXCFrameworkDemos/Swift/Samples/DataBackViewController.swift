/// Copyright 2022 Google LLC. All rights reserved.
///
///
/// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
/// file except in compliance with the License. You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software distributed under
/// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
/// ANY KIND, either express or implied. See the License for the specific language governing
/// permissions and limitations under the License.

import Combine
import CoreLocation
import GoogleNavigation
import UIKit

/// Demonstrates data and events that can be returned via various callback mechanisms.
///
/// - Note: A real app may not use all the callback mechanisms. Several mechanisms are shown here
///   just to demonstrate.
class DataBackViewController: BaseSampleViewController {
  /// The main map view.
  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView()
    mapView.isNavigationEnabled = true
    mapView.settings.compassButton = true
    mapView.delegate = self
    return mapView
  }()

  private lazy var instructionLabel: UILabel = {
    let label = MenuUIHelpers.makeLabel(text: "Tap map to add waypoint.")
    label.textAlignment = .center
    label.textColor = .systemRed
    return label
  }()

  /// Used to store custom waypoints set by the user.
  private var waypoints = [GMSNavigationWaypoint]()

  private var previousNavState: GMSNavigationNavState?

  // MARK: - Use Combine to update the remaining time and distance label.

  @Published private var remainingTime: TimeInterval = 0
  @Published private var remainingDistance: CLLocationDistance = 0

  private lazy var timeAndDistanceLabel: UILabel = {
    let label = MenuUIHelpers.makeLabel(
      text: "Remaining Time: 0.0\nRemaining Distance: 0.0 meters",
      numberOfLines: 0)
    timeAndDistanceSubscriber = updatedTimeAndDistance.assign(to: \.text, on: label)
    return label
  }()

  private var updatedTimeAndDistance: AnyPublisher<String?, Never> {
    return Publishers.CombineLatest($remainingTime, $remainingDistance)
      .map { remainingTime, remainingDistance in
        guard remainingTime != CLTimeIntervalMax && remainingDistance != CLLocationDistanceMax
        else { return nil }
        return String(
          format: "Remaining Time: %.1f\nRemaining Distance: %.1f meters", remainingTime,
          remainingDistance)
      }
      .eraseToAnyPublisher()
  }

  // Hold a reference to the subscriber so it doesn't dealloc.
  private var timeAndDistanceSubscriber: AnyCancellable?

  // MARK: - Use AsyncStream to update the current road snapped location label.

  private var roadSnappedLocationUpdateContinuation: AsyncStream<CLLocation>.Continuation?

  private lazy var roadSnappedLocationLabel: UILabel = {
    // Create an AsyncStream and store the continuation to use in the delegate callback.
    Task {
      let locations = AsyncStream(CLLocation.self) { continuation in
        roadSnappedLocationUpdateContinuation = continuation
      }
      for await location in locations {
        roadSnappedLocationLabel.text = String(
          format: "Road snapped location: (%.8f, %.8f)",
          location.coordinate.latitude,
          location.coordinate.longitude)
      }
    }
    return MenuUIHelpers.makeLabel(text: "Road snapped location: (0, 0)", numberOfLines: 0)
  }()

  // MARK: - UIViewController methods.

  override func viewDidLoad() {
    super.viewDidLoad()

    if let navigator = mapView.navigator,
      let roadSnappedLocationProvider = mapView.roadSnappedLocationProvider
    {
      navigator.add(self)
      roadSnappedLocationProvider.add(self)
      roadSnappedLocationProvider.startUpdatingLocation()
    } else {
      // Normally there would be some fallback machansim in case the SDK fails to load.
      showErrorMessage(title: "SDK failure", message: "Google Navigation failed to load.")
    }

    // Add a map.
    primaryStackView.insertArrangedSubview(mapView, at: 0)

    // Add a label with instructions for adding waypoints.
    addMenuSubview(instructionLabel)

    // Add buttons to request/clear the route.
    addMenuSubview(
      MenuUIHelpers.makeStackView(arrangedSubviews: [
        MenuUIHelpers.makeMenuButton(
          title: "Request route",
          onTouchUpInside: (target: self, action: #selector(requestRoute))),
        MenuUIHelpers.makeMenuButton(
          title: "Clear route",
          onTouchUpInside: (target: self, action: #selector(clearRoute))),
      ]))

    // Add buttons to start/stop guidance.
    addMenuSubview(
      MenuUIHelpers.makeStackView(arrangedSubviews: [
        MenuUIHelpers.makeMenuButton(
          title: "Start guidance",
          onTouchUpInside: (target: self, action: #selector(startGuidance))),
        MenuUIHelpers.makeMenuButton(
          title: "Stop guidance",
          onTouchUpInside: (target: self, action: #selector(stopGuidance))),
      ]))

    // Add button to continue to the next waypoint.
    addMenuSubview(
      MenuUIHelpers.makeMenuButton(
        title: "Continue to next waypoint",
        onTouchUpInside: (target: self, action: #selector(continueToNextWaypoint))))

    // Add buttons to start/stop simulation.
    addMenuSubview(
      MenuUIHelpers.makeStackView(arrangedSubviews: [
        MenuUIHelpers.makeMenuButton(
          title: "Start simulation",
          onTouchUpInside: (target: self, action: #selector(startSimulation))),
        MenuUIHelpers.makeMenuButton(
          title: "Stop simulation",
          onTouchUpInside: (target: self, action: #selector(stopSimulation))),
      ]))

    // Add a label to display the remaining time and distance.
    addMenuSubview(timeAndDistanceLabel)

    // Add a label to display the current road snapped location.
    addMenuSubview(roadSnappedLocationLabel)
  }

  // MARK: - Menu handlers

  /// Requests a route with the selected destination type, travel mode and options.
  @objc private func requestRoute() {
    // Clear any custom markers first to reduce clutter on the map.
    mapView.clear()

    // Clear previous destinations and set the new destinations.
    let navigator = mapView.navigator
    navigator?.clearDestinations()
    navigator?.setDestinations(waypoints) { [weak self] routeStatus in
      self?.handleRouteCallback(with: routeStatus)
    }
  }

  /// Clears the current route if one is loaded.
  @objc private func clearRoute() {
    mapView.navigator?.clearDestinations()
    waypoints.removeAll()
    mapView.clear()
    mapView.cameraMode = .following
  }

  /// Starts guidance.
  @objc private func startGuidance() {
    mapView.cameraMode = .following
    mapView.navigator?.isGuidanceActive = true
  }

  /// Stops guidance.
  @objc private func stopGuidance() {
    mapView.navigator?.isGuidanceActive = false
    previousNavState = nil
  }

  /// Continues to the next destination in a multi-waypoint route.
  @objc private func continueToNextWaypoint() {
    if !waypoints.isEmpty {
      waypoints.removeFirst()
      requestRoute()
    }
  }

  /// Starts simulating along the current route.
  @objc private func startSimulation() {
    mapView.locationSimulator?.simulateLocationsAlongExistingRoute()
  }

  /// Stops the simulation, returning the user location marker to the GPS-reported location.
  @objc private func stopSimulation() {
    mapView.locationSimulator?.stopSimulation()
  }

  // MARK: - Private helpers

  /// Handles a route response with the given success or failure status.
  private func handleRouteCallback(with routeStatus: GMSRouteStatus) {
    if routeStatus == .OK {
      mapView.cameraMode = .overview
    } else {
      // Show an error dialog to describe the failure.
      let message = routeStatus.description
      showErrorMessage(title: "Route failed", message: message)
    }
  }

  /// Shows an error alert.
  ///
  /// - Note: This is not normally the best way to handle problems, but is used here for
  ///   demonstration purposes.
  private func showErrorMessage(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
}

// MARK: - GMSMapViewDelegate

extension DataBackViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    // Create a waypoint at the location that was tapped on.
    let waypointTitle = "Custom waypoint \(waypoints.count)"
    guard
      let newWaypoint = GMSNavigationWaypoint(
        location: coordinate,
        title: waypointTitle)
    else {
      showErrorMessage(title: "Failed to create custom waypoint", message: nil)
      return
    }

    // Store the waypoint to use later when calling setDestinations.
    waypoints.append(newWaypoint)

    // Add a custom marker to make it easier to track where they've been placed. This is not a
    // necessary step and is just for convenience.
    let marker = GMSMarker(position: coordinate)
    marker.title = waypointTitle
    marker.map = mapView
  }
}

// MARK: - GMSNavigatorListener

extension DataBackViewController: GMSNavigatorListener {
  func navigator(_ navigator: GMSNavigator, didUpdateRemainingTime time: TimeInterval) {
    remainingTime = time
  }

  func navigator(
    _ navigator: GMSNavigator,
    didUpdateRemainingDistance distance: CLLocationDistance
  ) {
    remainingDistance = distance
  }

  func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
    previousNavState = nil
    Task {
      await messagesView.add(message: "Arrived at \(waypoint.title)!")
    }
  }

  func navigator(_ navigator: GMSNavigator, didUpdate navInfo: GMSNavigationNavInfo) {
    let newNavState = navInfo.navState
    if newNavState != previousNavState {
      previousNavState = newNavState
      Task {
        await messagesView.add(message: "\(newNavState)")
      }
    }
  }
}

// MARK: - GMSRoadSnappedLocationProviderListener

extension DataBackViewController: GMSRoadSnappedLocationProviderListener {
  func locationProvider(
    _ locationProvider: GMSRoadSnappedLocationProvider,
    didUpdate location: CLLocation
  ) {
    roadSnappedLocationUpdateContinuation?.yield(location)
  }
}

// MARK: - Other Extensions

extension GMSNavigationNavState: CustomStringConvertible {
  public var description: String {
    switch self {
    case .rerouting:
      return "Rerouting"
    case .enroute:
      return "Enroute"
    case .stopped:
      return "Stopped"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("Invalid Nav State: \(self)")
    }
  }
}
