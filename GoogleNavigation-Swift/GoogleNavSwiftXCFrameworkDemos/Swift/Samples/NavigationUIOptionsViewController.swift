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

import Foundation
import GoogleNavigation
import UIKit

class NavigationUIOptionsViewController: BaseSampleViewController {
  private enum Constants {
    /// The standard padding to use for custom UI elements.
    static let standardPadding: CGFloat = 8.0

    /// The font name to use for a customized header.
    static let customizedHeaderFontName = "BradleyHandITCTT-Bold"
  }

  /// The time interval in seconds to wait before triggering the auto follow timer.
  private static let autoFollowTimeInterval = 5.0

  /// A sample coordinate in Sydney.
  private static let sampleCoordinate = CLLocationCoordinate2D(
    latitude: -33.857431,
    longitude: 151.211927)

  private static let customCameraModeTitle = "Custom"

  /// The main map view.
  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView()
    mapView.isNavigationEnabled = true
    mapView.cameraMode = .following
    mapView.settings.compassButton = true
    mapView.delegate = self
    mapView.navigator?.add(self)
    mapView.accessibilityElementsHidden = false
    return mapView
  }()

  /// Used to store waypoints set by the user.
  private var waypoints = [GMSNavigationWaypoint]()

  /// A custom floating button to continue to the next waypoint.
  ///
  /// It will only be enabled when navigation has arrived at a waypoint.
  private lazy var continueToNextWaypointButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .systemGray
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.lightText, for: .disabled)
    button.layer.cornerRadius = 5.0
    button.contentEdgeInsets = UIEdgeInsets(
      top: Constants.standardPadding,
      left: Constants.standardPadding,
      bottom: Constants.standardPadding,
      right: Constants.standardPadding)
    button.setTitle("Continue to next waypoint", for: .normal)
    button.addTarget(self, action: #selector(continueToNextWaypoint), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isEnabled = false
    return button
  }()

  /// Indicates whether the map is automatically recentered 5 seconds after the last time the user
  /// moved the map.
  private var isAutoFollowEnabled = false

  /// Timer used when auto follow mode is enabled.
  private var autoFollowTimer: Timer? = nil

  /// Displays waypoint information
  private var waypointInformationView: WaypointInformationView?

  override func viewDidLoad() {
    // The menu is not an overlay for this sample so it doesn't obscure any of the UI to better see
    // the changes. Must be set before calling `super.viewDidLoad()` since the menu is initialzed in
    // the super class.
    isMenuAnOverlay = false

    super.viewDidLoad()

    // Add a map.
    primaryStackView.insertArrangedSubview(mapView, at: 0)

    // Add `continueToNextWaypointButton` to the view hierarchy. It will be placed at the
    // bottom-center of the mapView.
    view.addSubview(continueToNextWaypointButton)
    let navFooterLayoutGuide = mapView.navigationFooterLayoutGuide
    // This constraint priority is set to `.defaultHigh` so the button can also be constrained to
    // the safe area insets.
    let buttonBottomConstraint = continueToNextWaypointButton.bottomAnchor.constraint(
      equalTo: navFooterLayoutGuide.topAnchor,
      constant: -Constants.standardPadding)
    buttonBottomConstraint.priority = .defaultHigh
    buttonBottomConstraint.isActive = true
    continueToNextWaypointButton.bottomAnchor.constraint(
      lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor
    ).isActive = true
    continueToNextWaypointButton.centerXAnchor.constraint(
      equalTo: navFooterLayoutGuide.centerXAnchor
    ).isActive = true

    // Add a label with instructions for adding waypoints.
    let instructionLabel = MenuUIHelpers.makeLabel(text: "Tap map to add waypoint.")
    instructionLabel.textAlignment = .center
    instructionLabel.textColor = .systemRed
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

    // Add buttons to simulate prompts and traffic incidents.
    addMenuSubview(
      MenuUIHelpers.makeStackView(arrangedSubviews: [
        MenuUIHelpers.makeMenuButton(
          title: "Simulate Prompt",
          onTouchUpInside: (target: self, action: #selector(simulatePrompt))),
        MenuUIHelpers.makeMenuButton(
          title: "Traffic Incident",
          onTouchUpInside: (target: self, action: #selector(simulateTrafficIncident))),
      ]))

    // Add segmented control to select the camera mode.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Camera mode",
        segmentTitles: GMSNavigationCameraMode.allCases.map(String.init(describing:))
          + [NavigationUIOptionsViewController.customCameraModeTitle],
        onValueChanged: (target: self, action: #selector(cameraModeControlDidUpdate)),
        selectedSegmentIndex: mapView.cameraMode.rawValue))

    // Add segmented control to select the following perspective.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Following perspective",
        segmentTitles: GMSNavigationCameraPerspective.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(cameraPerspectiveControlDidUpdate))))

    // Add a switch to toggle auto follow mode.
    addMenuSubview(
      NavDemoSwitch(
        title: "Auto follow mode",
        onValueChanged: (target: self, action: #selector(autoFollowModeSwitchDidUpdate))))

    // Add a switch to set mapViewMode.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Map View Mode",
        segmentTitles: GMSMapViewType.allCases.map(String.init(describing:)),
        onValueChanged: (target: self, action: #selector(mapViewModeControlDidUpdate)))
    )

    // Add segmented control to adjust frame rate.
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Frame Rate",
        segmentTitles: ["PowerSave", "Conservative", "Maximum"],
        onValueChanged: (target: self, action: #selector(frameRateControlDidUpdate)),
        selectedSegmentIndex: 2)
    )

    // Add a switch to toggle custom header colors.
    addMenuSubview(
      NavDemoSwitch(
        title: "Customized header",
        onValueChanged: (target: self, action: #selector(customizedHeaderSwitchDidUpdate))))

    // Add a switch to toggle fullscreen.
    addMenuSubview(
      NavDemoSwitch(
        title: "Fullscreen",
        onValueChanged: (target: self, action: #selector(fullscreenSwitchDidUpdate))))

    // Add a switch to toggle the header accessory view.
    addMenuSubview(
      NavDemoSwitch(
        title: "Header accessory view",
        onValueChanged: (target: self, action: #selector(headerAccessoryViewSwitchDidUpdate))))

    // Add a switch to toggle accessibility on mapView elements.
    addMenuSubview(
      NavDemoSwitch(
        title: "Hide accessibility elements",
        onValueChanged: (
          target: self, action: #selector(accessibilitySwitchDidUpdate)
        )))
  }

  // MARK: - Menu handlers

  /// Requests a route with the selected destination type, travel mode and options.
  @objc private func requestRoute() {
    // Clear any custom markers first to reduce clutter on the map.
    mapView.clear()

    // Clear previous destinations and set the new destinations.
    let navigator = mapView.navigator
    navigator?.clearDestinations()
    navigator?.setDestinations(waypoints) { routeStatus in
      self.handleRouteCallback(with: routeStatus)
    }
  }

  /// Clears the current route if one is loaded.
  @objc private func clearRoute() {
    mapView.navigator?.clearDestinations()
    waypoints.removeAll()
    mapView.clear()
  }

  /// Starts guidance.
  @objc private func startGuidance() {
    mapView.navigator?.isGuidanceActive = true
  }

  /// Stops guidance.
  @objc private func stopGuidance() {
    mapView.navigator?.isGuidanceActive = false
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

  /// Simulates a navigation prompt.
  @objc private func simulatePrompt() {
    mapView.locationSimulator?.simulateNavigationPrompt()
  }

  /// Simulates a traffic incident.
  @objc private func simulateTrafficIncident() {
    mapView.locationSimulator?.simulateTrafficIncidentReport()
  }

  /// Updates the camera mode.
  @objc private func cameraModeControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    if segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
      == NavigationUIOptionsViewController.customCameraModeTitle
    {
      // Animate the camera to center on the last waypoint in the list if it exists. Otherwise
      // animate to a sample coordinate with sample zoom/bearing/viewingAngle values.
      let coordinate =
        waypoints.last?.coordinate ?? NavigationUIOptionsViewController.sampleCoordinate
      mapView.animate(
        to: GMSCameraPosition(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          zoom: 13,
          bearing: 20,
          viewingAngle: 0))
    } else {
      mapView.cameraMode =
        GMSNavigationCameraMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .following
    }
  }

  /// Updates the camera perspective.
  @objc private func cameraPerspectiveControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    mapView.followingPerspective =
      GMSNavigationCameraPerspective(rawValue: segmentedControl.selectedSegmentIndex) ?? .tilted
  }

  @objc private func mapViewModeControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    mapView.mapType = GMSMapViewType.allCases[segmentedControl.selectedSegmentIndex]
  }

  /// Toggles auto follow mode, and if toggled off also invalidates the existing auto follow timer.
  @objc private func autoFollowModeSwitchDidUpdate(_ sender: UISwitch) {
    isAutoFollowEnabled = sender.isOn
    if !isAutoFollowEnabled {
      autoFollowTimer?.invalidate()
      autoFollowTimer = nil
    }
  }

  /// Toggles the accessibility of mapView elements.
  @objc private func accessibilitySwitchDidUpdate(_ sender: UISwitch) {
    mapView.accessibilityElementsHidden = sender.isOn
  }

  /// Customizes the header.
  @objc private func customizedHeaderSwitchDidUpdate(_ sender: UISwitch) {
    let settings = mapView.settings
    if sender.isOn {
      // Background colors.
      settings.navigationHeaderPrimaryBackgroundColor =
        UIColor(red: 0.0, green: 0.2, blue: 0.75, alpha: 1.0)
      settings.navigationHeaderSecondaryBackgroundColor =
        UIColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 1.0)
      settings.navigationHeaderPrimaryBackgroundColorNightMode =
        UIColor(red: 0.0, green: 0.15, blue: 0.5, alpha: 1.0)
      settings.navigationHeaderSecondaryBackgroundColorNightMode =
        UIColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 1.0)
      // Icon colors.
      settings.navigationHeaderLargeManeuverIconColor = .orange
      settings.navigationHeaderSmallManeuverIconColor = .yellow
      settings.navigationHeaderGuidanceRecommendedLaneColor = .orange
      // Text colors and fonts.
      settings.navigationHeaderNextStepTextColor = .yellow
      settings.navigationHeaderNextStepFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 16)
      settings.navigationHeaderDistanceValueTextColor = .lightGray
      settings.navigationHeaderDistanceValueFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 24)
      settings.navigationHeaderDistanceUnitsTextColor = .lightGray
      settings.navigationHeaderDistanceUnitsFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 18)
      settings.navigationHeaderInstructionsTextColor = .yellow
      settings.navigationHeaderInstructionsFirstRowFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 30)
      settings.navigationHeaderInstructionsSecondRowFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 24)
      settings.navigationHeaderInstructionsConjunctionsFont =
        UIFont(name: Constants.customizedHeaderFontName, size: 18)
    } else {
      // Background colors.
      settings.navigationHeaderPrimaryBackgroundColor = nil
      settings.navigationHeaderSecondaryBackgroundColor = nil
      settings.navigationHeaderPrimaryBackgroundColorNightMode = nil
      settings.navigationHeaderSecondaryBackgroundColorNightMode = nil
      // Icon colors.
      settings.navigationHeaderLargeManeuverIconColor = nil
      settings.navigationHeaderSmallManeuverIconColor = nil
      settings.navigationHeaderGuidanceRecommendedLaneColor = nil
      // Text colors and fonts.
      settings.navigationHeaderNextStepTextColor = nil
      settings.navigationHeaderNextStepFont = nil
      settings.navigationHeaderDistanceValueTextColor = nil
      settings.navigationHeaderDistanceValueFont = nil
      settings.navigationHeaderDistanceUnitsTextColor = nil
      settings.navigationHeaderDistanceUnitsFont = nil
      settings.navigationHeaderInstructionsTextColor = nil
      settings.navigationHeaderInstructionsFirstRowFont = nil
      settings.navigationHeaderInstructionsSecondRowFont = nil
      settings.navigationHeaderInstructionsConjunctionsFont = nil
    }
  }

  @objc private func frameRateControlDidUpdate(_ segmentedControl: UISegmentedControl) {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      mapView.preferredFrameRate = .powerSave
    case 1:
      mapView.preferredFrameRate = .conservative
    case 2:
      mapView.preferredFrameRate = .maximum
    default:
      mapView.preferredFrameRate = .maximum
    }
  }

  /// Updates the navigation bar for fullscreen.
  @objc private func fullscreenSwitchDidUpdate(_ sender: UISwitch) {
    navigationController?.setNavigationBarHidden(sender.isOn, animated: true)
  }

  /// Adds/removes a custom header accessory view.
  @objc private func headerAccessoryViewSwitchDidUpdate(_ sender: UISwitch) {
    guard sender.isOn else {
      mapView.setHeaderAccessory(nil)
      return
    }

    waypointInformationView = WaypointInformationView()
    mapView.setHeaderAccessory(waypointInformationView)
    updateWaypointInformationView()
  }

  // MARK: - Private helpers

  /// Handles a route response with the given success or failure status.
  private func handleRouteCallback(with routeStatus: GMSRouteStatus) {
    guard routeStatus == .OK else {
      // Show an error dialog to describe the failure.
      showErrorMessage(title: "Route failed", message: routeStatus.description)
      return
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

  /// Updates `waypointInformationView` by getting the remaining time and distance for the waypoints
  /// and passing it to `waypointInformationView`.
  private func updateWaypointInformationView() {
    guard let waypointInformationView = waypointInformationView,
      waypointInformationView.superview != nil, let navigator = mapView.navigator
    else { return }
    var waypointInformation = [String: WaypointInformationView.TimeAndDistance]()
    for waypoint in waypoints {
      let remainingTime = navigator.time(to: waypoint)
      let remainingDistance = navigator.distance(to: waypoint)
      guard remainingTime != CLTimeIntervalMax && remainingDistance != CLLocationDistanceMax else {
        waypointInformation[waypoint.title] = nil
        continue
      }
      waypointInformation[waypoint.title] = (remainingTime, remainingDistance)
    }
    waypointInformationView.waypointInformation = waypointInformation
    mapView.invalidateLayout(forAccessoryView: waypointInformationView)
  }

  // MARK: -

  /// Displays remaining time and distance information about upcoming waypoints.
  ///
  /// Can be used as a navigation accessory view.
  class WaypointInformationView: UIView, GMSNavigationAccessoryView {
    typealias TimeAndDistance = (time: TimeInterval, distance: CLLocationDistance)

    /// Data structure for the waypoint information that should be displayed.
    var waypointInformation: [String: TimeAndDistance?]? {
      didSet {
        guard let waypointInformation = waypointInformation, waypointInformation.count > 0 else {
          waypointInformationLabel.text = "No waypoint information received"
          return
        }

        var displayText = ""
        let timeFormatter = DateComponentsFormatter()
        for (waypointTitle, timeAndDistance) in waypointInformation.sorted(by: { $0.0 < $1.0 }) {
          guard let timeAndDistance = timeAndDistance else {
            displayText += "\(waypointTitle) (Unavailable)\n"
            continue
          }
          let formattedTime = timeFormatter.string(from: timeAndDistance.time) ?? "Unknown"
          let formattedDistance = String(format: "%.1f", timeAndDistance.distance)
          displayText +=
            "\(waypointTitle) (Time: \(formattedTime) Distance: \(formattedDistance) m)\n"
        }
        displayText.removeLast()
        waypointInformationLabel.text = displayText
      }
    }

    /// Label to display the data in `waypointInformation`.
    private lazy var waypointInformationLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.lineBreakMode = .byWordWrapping
      label.numberOfLines = 0
      label.textColor = .lightText
      return label
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      self.backgroundColor = UIColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 1.0)
      addSubview(waypointInformationLabel)
      NSLayoutConstraint.activate([
        waypointInformationLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
        waypointInformationLabel.leadingAnchor.constraint(
          equalTo: self.layoutMarginsGuide.leadingAnchor),
        waypointInformationLabel.trailingAnchor.constraint(
          equalTo: self.layoutMarginsGuide.trailingAnchor),
      ])
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func heightForAccessoryViewConstrained(to size: CGSize, on mapView: GMSMapView) -> CGFloat {
      let insetSize = CGSize(
        width: size.width - (self.layoutMargins.left + self.layoutMargins.right),
        height: size.height)
      let height =
        waypointInformationLabel.sizeThatFits(insetSize).height
        + self.layoutMargins.top + self.layoutMargins.bottom
      return height
    }
  }
}

// MARK: - NavigationUIOptionsViewController extensions

extension NavigationUIOptionsViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    // Create a waypoint at the location that was tapped on.
    let waypointTitle = "Waypoint \(waypoints.count)"
    guard
      let newWaypoint = GMSNavigationWaypoint(
        location: coordinate,
        title: waypointTitle)
    else {
      showErrorMessage(title: "Failed to create waypoint", message: nil)
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

  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    guard let isGuidanceActive = mapView.navigator?.isGuidanceActive,
      isAutoFollowEnabled && isGuidanceActive && gesture
    else { return }

    // Start/re-start the auto follow timer. Set the camera mode back to following when it fires.
    autoFollowTimer?.invalidate()
    autoFollowTimer = Timer.scheduledTimer(
      withTimeInterval: NavigationUIOptionsViewController.autoFollowTimeInterval,
      repeats: false
    ) { [weak self] timer in
      guard let self = self else { return }
      // Use `self.mapView` to prevent the map view from being retained longer than necessary if
      // this view controller and its map view are dismissed before the timer fires.
      if let isGuidanceActive = self.mapView.navigator?.isGuidanceActive, isGuidanceActive {
        self.mapView.cameraMode = .following
      }

      self.autoFollowTimer = nil
    }
  }
}

extension NavigationUIOptionsViewController: GMSNavigatorListener {
  func navigator(_ navigator: GMSNavigator, didUpdateRemainingTime time: TimeInterval) {
    // Update the waypoint information view since the remaining time has changed.
    updateWaypointInformationView()
  }

  func navigator(_ navigator: GMSNavigator, didUpdateRemainingDistance distance: CLLocationDistance)
  {
    // Update the waypoint information view since the remaining distance has changed.
    updateWaypointInformationView()
  }

  func navigatorDidChangeRoute(_ navigator: GMSNavigator) {
    // Disable `continueToNextWaypointButton` since it should only be enabled after arriving at a
    // waypoint.
    continueToNextWaypointButton.isEnabled = false
  }

  func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
    // Enable `continueToNextWaypointButton`.
    continueToNextWaypointButton.isEnabled = true
  }
}

// MARK: - Other extensions

extension GMSNavigationCameraMode: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSNavigationCameraMode] {
    return [.free, .following, .overview]
  }

  public var description: String {
    switch self {
    case .free:
      return "Free"
    case .following:
      return "Follow"
    case .overview:
      return "Overview"
    @unknown default:
      fatalError()
    }
  }
}

extension GMSNavigationCameraPerspective: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSNavigationCameraPerspective] {
    return [.tilted, .topDownNorthUp, .topDownHeadingUp]
  }

  public var description: String {
    switch self {
    case .tilted:
      return "Tilted"
    case .topDownNorthUp:
      return "Top-down north-up"
    case .topDownHeadingUp:
      return "Top-down heading-up"
    @unknown default:
      fatalError()
    }
  }
}

extension GMSMapViewType: CaseIterable, CustomStringConvertible {
  public static var allCases: [GMSMapViewType] {
    return [.normal, .satellite, .terrain, .hybrid]
  }

  public var description: String {
    switch self {
    case .normal:
      return "Normal"
    case .satellite:
      return "Satellite"
    case .terrain:
      return "Terrain"
    case .hybrid:
      return "Hybrid"
    case .none:
      fatalError()
    @unknown default:
      fatalError()
    }
  }
}
