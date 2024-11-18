/// Copyright 2020 Google LLC. All rights reserved.
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

import GoogleNavigation
import UIKit

class RoutingOptionsViewController: BaseSampleViewController {
  enum DestinationType: Int, CaseIterable, CustomStringConvertible {
    /// Use custom waypoints set by the user tapping on the map.
    case custom
    /// Use a waypoint created using coordinates.
    case coordinate
    /// Use a waypoints created using a place ID.
    case placeID
    /// Use multiple waypoints created using both coordinates and a place ID.
    case multi

    var description: String {
      switch self {
      case .custom:
        return "Custom"
      case .coordinate:
        return "Coordinate"
      case .placeID:
        return "PlaceID"
      case .multi:
        return "Multi"
      }
    }

    var instructionText: String {
      switch self {
      case .custom:
        return "Tap map to add waypoint."
      case .coordinate, .placeID, .multi:
        return #"Tap "Request route" for a preset destination."#
      }
    }
  }

  /// The main map view.
  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView()
    mapView.isNavigationEnabled = true
    mapView.settings.compassButton = true
    mapView.delegate = self
    return mapView
  }()

  /// Used to determine the type of waypoint destination(s) that will be used in this sample.
  private var destinationType: DestinationType = .custom {
    didSet {
      destinationTypeInstructionLabel.text = destinationType.instructionText
    }
  }

  /// The last type of waypoint destination(s) that was used in this sample.
  private var lastDestinationType: DestinationType = .custom

  /// Displays instructions for the current destination type.
  private lazy var destinationTypeInstructionLabel: UILabel = {
    let label = MenuUIHelpers.makeLabel(text: destinationType.instructionText)
    label.textAlignment = .center
    label.textColor = .systemRed
    return label
  }()

  /// Used to store custom waypoints set by the user.
  private var customWaypoints = [GMSNavigationWaypoint]()

  /// Returns the waypoints for the current destination type.
  private var currentWaypoints = [GMSNavigationWaypoint]()

  /// Receives a target distance from the user.
  private lazy var targetDistanceTextField: UITextField = {
    let textField = MenuUIHelpers.makeTextField(
      placeholder: "Target Distance (mi)",
      keyboardType: .numberPad)
    textField.addDoneCancelToolbar()
    return textField
  }()

  /// The routing options that will be passed to `setDestinations(_:routingOptions:callback:)`.
  private var routingOptions = GMSNavigationMutableRoutingOptions()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add a map.
    primaryStackView.insertArrangedSubview(mapView, at: 0)
    // Simulate at a fixed location near Stanford University.
    mapView.locationSimulator?.simulateLocation(
      at: CLLocationCoordinate2DMake(37.436367, -122.167312))

    addMenuSubview(destinationTypeInstructionLabel)

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

    // Add segmented controls to select the type of destinations.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Destination Type",
        segmentTitles: DestinationType.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(destinationTypeControlDidUpdate))))

    // Add segmented controls to select the travel mode.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Travel Mode",
        segmentTitles: GMSNavigationTravelMode.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(travelModeControlDidUpdate))))

    // Add an avoid highways switch.
    addMenuSubview(
      NavDemoSwitch(
        title: "Avoid highways",
        onValueChanged: (target: self, action: #selector(avoidHighwaysSwitchDidUpdate))))

    // Add an avoid tolls switch.
    addMenuSubview(
      NavDemoSwitch(
        title: "Avoid tolls",
        onValueChanged: (target: self, action: #selector(avoidTollsSwitchDidUpdate))))

    // Add segmented controls to select the routing strategy.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Routing Strategy",
        segmentTitles: GMSNavigationRoutingStrategy.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(routingStrategyControlDidUpdate))))
    targetDistanceTextField.isHidden = true
    // Add a text field to get user input. This text field will only be visible if the routing
    // strategy is `.deltaToTargetDistance`.
    addMenuSubview(targetDistanceTextField)

    // Add segmented controls to select the alternate routes strategy.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Alternate Routes Strategy",
        segmentTitles: GMSNavigationAlternateRoutesStrategy.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(alternateRoutesStrategyControlDidUpdate))))
  }

  private func createWaypoints() -> [GMSNavigationWaypoint] {
    switch destinationType {
    case .custom:
      return customWaypoints
    case .coordinate:
      if let ohloneCollege = GMSNavigationWaypoint(
        location: CLLocationCoordinate2DMake(37.529032, -121.918846),
        title: "Ohlone College")
      {
        return [ohloneCollege]
      }
    case .placeID:
      if let paramountTheatre = GMSNavigationWaypoint(
        placeID: "ChIJI2TVmK2Aj4ARxVVzT6uIQMw",
        title: "Paramount Theatre, Oakland")
      {
        return [paramountTheatre]
      }
    case .multi:
      if let ohloneCollege = GMSNavigationWaypoint(
        location: CLLocationCoordinate2DMake(37.529032, -121.918846),
        title: "Ohlone College"),
        let paramountTheatre = GMSNavigationWaypoint(
          placeID: "ChIJI2TVmK2Aj4ARxVVzT6uIQMw",
          title: "Paramount Theatre, Oakland")
      {
        return [ohloneCollege, paramountTheatre]
      }
    }
    return []
  }

  // MARK: - Menu handlers

  /// Requests a route with the selected destination type, travel mode and options.
  @objc private func requestRoute() {
    // If the destination type has changed, create new waypoints.
    if lastDestinationType != destinationType || currentWaypoints.isEmpty {
      currentWaypoints = createWaypoints()
      lastDestinationType = destinationType
    }

    // If the destination type is custom and new waypoints were created, update the custom waypoints
    if destinationType == .custom && !customWaypoints.isEmpty {
      currentWaypoints = customWaypoints
    }
    // Set the routing options target distance if `.deltaToTargetDistance` is the routing strategy.
    if routingOptions.routingStrategy == .deltaToTargetDistance
      && !targetDistanceTextField.isHidden,
      let value = Double(targetDistanceTextField.text ?? "")
    {
      let targetDistanceMiles = Measurement(value: value, unit: UnitLength.miles)
      let targetDistanceMeters = Int(targetDistanceMiles.converted(to: UnitLength.meters).value)
      // Convert the target distance from miles to meters.
      routingOptions.targetDistancesMeters = [targetDistanceMeters as NSNumber]
    }

    // Clear previous destinations and set the new destinations.
    let navigator = mapView.navigator
    clearRoute()
    navigator?.clearDestinations()
    navigator?.setDestinations(currentWaypoints, routingOptions: routingOptions) { routeStatus in
      self.handleRouteCallback(with: routeStatus)
    }
  }

  /// Clears the current route if one is loaded.
  @objc private func clearRoute() {
    mapView.navigator?.clearDestinations()
    if destinationType == .custom {
      customWaypoints.removeAll()
    }
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
  }

  /// Continues to the next destination in a multi-waypoint route.
  @objc private func continueToNextWaypoint() {
    if !currentWaypoints.isEmpty {
      currentWaypoints.removeFirst()
      if currentWaypoints.isEmpty {
        clearRoute()
      } else {
        requestRoute()
      }
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

  /// Updates the destination type.
  @objc private func destinationTypeControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    destinationType = DestinationType(rawValue: segmentedControl.selectedSegmentIndex) ?? .custom
  }

  /// Updates the travel mode.
  @objc private func travelModeControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    mapView.travelMode =
      GMSNavigationTravelMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .driving
  }

  /// Updates the 'avoid highways' setting.
  @objc private func avoidHighwaysSwitchDidUpdate(_ sender: UISwitch) {
    mapView.navigator?.avoidsHighways = sender.isOn
  }

  /// Updates the 'avoid tolls' setting.
  @objc private func avoidTollsSwitchDidUpdate(_ sender: UISwitch) {
    mapView.navigator?.avoidsTolls = sender.isOn
  }

  /// Updates the routing strategy.
  @objc private func routingStrategyControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    let newRoutingStrategy =
      GMSNavigationRoutingStrategy(rawValue: segmentedControl.selectedSegmentIndex) ?? .defaultBest

    // Show/hide the target distance textField as appropriate.
    if routingOptions.routingStrategy == .deltaToTargetDistance
      || newRoutingStrategy == .deltaToTargetDistance
    {
      UIView.animate(withDuration: BaseSampleViewController.menuAnimationsDuration) {
        self.targetDistanceTextField.isHidden = (newRoutingStrategy != .deltaToTargetDistance)
      }
    }

    routingOptions.routingStrategy = newRoutingStrategy
  }

  /// Updates the alternate routes strategy.
  @objc private func alternateRoutesStrategyControlDidUpdate(
    _ segmentedControl: UISegmentedControl
  ) {
    routingOptions.alternateRoutesStrategy =
      GMSNavigationAlternateRoutesStrategy(rawValue: segmentedControl.selectedSegmentIndex) ?? .all
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
  /// demonstration purposes.
  private func showErrorMessage(title: String, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(alertController, animated: true)
  }
}

// MARK: - Extensions

extension RoutingOptionsViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    guard destinationType == .custom else { return }

    // Create a waypoint at the location that was tapped on.
    let waypointTitle = "Custom waypoint \(customWaypoints.count)"
    guard
      let newWaypoint = GMSNavigationWaypoint(
        location: coordinate,
        title: waypointTitle)
    else {
      showErrorMessage(title: "Failed to create custom waypoint", message: nil)
      return
    }

    // Store the waypoint to use later when calling setDestinations.
    customWaypoints.append(newWaypoint)

    // Add a custom marker to make it easier to track where they've been placed. This is not a
    // necessary step and is just for convenience.
    let marker = GMSMarker(position: coordinate)
    marker.title = waypointTitle
    marker.map = mapView
  }
}

extension GMSNavigationTravelMode: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSNavigationTravelMode] {
    return [.driving, .cycling, .walking, .twoWheeler, .taxicab]
  }

  public var description: String {
    switch self {
    case .driving:
      return "Driving"
    case .cycling:
      return "Cycling"
    case .walking:
      return "Walking"
    case .twoWheeler:
      return "Two Wheeler"
    case .taxicab:
      return "Taxicab"
    @unknown default:
      fatalError()
    }
  }
}

extension GMSNavigationAlternateRoutesStrategy: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSNavigationAlternateRoutesStrategy] {
    return [.all, .none, .one]
  }

  public var description: String {
    switch self {
    case .all:
      return "All"
    case .none:
      return "None"
    case .one:
      return "One"
    @unknown default:
      fatalError()
    }
  }
}

extension GMSNavigationRoutingStrategy: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSNavigationRoutingStrategy] {
    return [.defaultBest, .shorter, .deltaToTargetDistance]
  }

  public var description: String {
    switch self {
    case .defaultBest:
      return "Default"
    case .shorter:
      return "Shorter"
    case .deltaToTargetDistance:
      return "Target Distance"
    @unknown default:
      fatalError()
    }
  }
}
