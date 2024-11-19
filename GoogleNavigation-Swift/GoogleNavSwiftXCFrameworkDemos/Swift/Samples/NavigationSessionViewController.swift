/// Copyright 2024 Google LLC. All rights reserved.
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

/// A view that displays information about the current navigation session.
class NavigationSessionView: UIView {
  private lazy var label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 2
    label.textColor = .lightText
    label.lineBreakMode = .byWordWrapping
    return label
  }()

  private var navigator: GMSNavigator
  private lazy var timeFormatter = DateComponentsFormatter()
  private var navInfo: GMSNavigationNavInfo?

  init(frame: CGRect, navigator: GMSNavigator) {
    self.navigator = navigator
    super.init(frame: frame)

    navigator.add(self)
    self.backgroundColor = UIColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 1)

    addSubview(label)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      self.heightAnchor.constraint(equalToConstant: 100),
    ])
    label.text = labelText()
  }

  func labelText() -> String {
    guard navigator.isGuidanceActive else { return "Guidance not active" }

    let remainingTime = navigator.timeToNextDestination
    let remainingDistance = navigator.distanceToNextDestination
    let remainingTimeString = timeFormatter.string(from: remainingTime) ?? ""
    let remainingDistanceString = String(format: "%.1f", remainingDistance)
    var displayText =
      "Next stop Time: \(remainingTimeString) Distance: \(remainingDistanceString) m\n"
    if let fullInstructionText = navInfo?.currentStep?.fullInstructionText {
      displayText += fullInstructionText
    }
    return displayText
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension NavigationSessionView: GMSNavigatorListener {
  func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
    label.text = labelText()
  }

  func navigator(_ navigator: GMSNavigator, didUpdateRemainingTime time: TimeInterval) {
    label.text = labelText()
  }

  func navigator(_ navigator: GMSNavigator, didUpdateRemainingDistance distance: CLLocationDistance)
  {
    label.text = labelText()
  }

  func navigator(_ navigator: GMSNavigator, didUpdate navInfo: GMSNavigationNavInfo) {
    self.navInfo = navInfo
    label.text = labelText()
  }

  func navigatorDidChangeRoute(_ navigator: GMSNavigator) {
    label.text = labelText()
  }
}

class NavigationSessionViewController: BaseSampleViewController {

  // The navigation session for this demo.
  private lazy var navigationSession: GMSNavigationSession? = {
    let navigationSession = GMSNavigationServices.createNavigationSession()
    if let navigationSession = navigationSession {
      navigationSession.isStarted = true
    }
    return navigationSession
  }()

  private lazy var navigator: GMSNavigator? = {
    guard let navigationSession = navigationSession, let navigator = navigationSession.navigator
    else { return nil }
    navigator.add(self)
    navigator.voiceGuidance = .silent
    navigator.sendsBackgroundNotifications = false
    return navigator
  }()

  // The main map view.
  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView(frame: .zero)
    mapView.delegate = self
    mapView.isNavigationEnabled = false
    mapView.overrideUserInterfaceStyle = .unspecified
    mapView.isMyLocationEnabled = true
    mapView.settings.compassButton = true
    mapView.settings.showsDestinationMarkers = true
    mapView.cameraMode = .overview

    if let navigationSession = navigationSession {
      mapView.enableNavigation(with: navigationSession)
    }
    return mapView
  }()

  private lazy var turnByTurnNavigationSwitch: NavDemoSwitch = {
    let turnByTurnNavigationSwitch = NavDemoSwitch(
      title: "Turn-by-turn Navigation",
      onValueChanged: (target: self, action: #selector(turnByTurnNavigationChanged)))
    return turnByTurnNavigationSwitch
  }()

  private lazy var guidanceActiveSwitch: NavDemoSwitch = {
    let guidanceActiveSwitch = NavDemoSwitch(
      title: "Guidance Active",
      onValueChanged: (target: self, action: #selector(guidanceActiveChanged)))
    return guidanceActiveSwitch
  }()

  private lazy var simulationPausedSwitch: NavDemoSwitch = {
    let simulationPausedSwitch = NavDemoSwitch(
      title: "Simulation Paused",
      onValueChanged: (target: self, action: #selector(simulationPausedChanged)))
    return simulationPausedSwitch
  }()

  private lazy var voiceGuidanceSwitch: NavDemoSwitch = {
    let voiceGuidanceSwitch = NavDemoSwitch(
      title: "Voice Guidance",
      onValueChanged: (target: self, action: #selector(voiceGuidanceChanged)))
    return voiceGuidanceSwitch
  }()

  var waypoints: [GMSNavigationWaypoint] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    if let navigator = navigator {
      let navigationSessionView = NavigationSessionView(frame: .zero, navigator: navigator)
      self.primaryStackView.addArrangedSubview(navigationSessionView)
    }
    self.primaryStackView.addArrangedSubview(mapView)

    addMenuSubview(
      MenuUIHelpers.makeStackView(arrangedSubviews: [
        MenuUIHelpers.makeMenuButton(
          title: "Continue to next waypoint",
          onTouchUpInside: (target: self, action: #selector(continueToNextWaypoint))),
        MenuUIHelpers.makeMenuButton(
          title: "Clear all",
          onTouchUpInside: (target: self, action: #selector(clearDestinations))),
      ])
    )

    addMenuSubview(turnByTurnNavigationSwitch)
    addMenuSubview(guidanceActiveSwitch)
    addMenuSubview(simulationPausedSwitch)
    addMenuSubview(voiceGuidanceSwitch)
    addMenuSubview(
      MenuUIHelpers.makeSegmentedControl(
        title: "Simulated travel speed multiplier",
        segmentTitles: ["1x", "2x", "5x", "10x", "20x"],
        onValueChanged: (target: self, action: #selector(simulationSpeedMultiplierChanged))))
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    stopNavigation()
  }

  @objc private func continueToNextWaypoint() {
    guard let navigator = navigator else { return }
    navigator.setDestinations(waypoints) { [weak self] routeStatus in
      self?.handleRouteCallbackWithStatus(routeStatus)
    }
    updateControls()
  }

  private func handleRouteCallbackWithStatus(_ routeStatus: GMSRouteStatus) {
    switch routeStatus {
    case .OK:
      startNavigation()
    default:
      print("Error setting destinations: \(routeStatus)")
    }
  }

  @objc private func clearDestinations() {
    waypoints.removeAll()
    mapView.clear()
    navigationSession?.navigator?.clearDestinations()
    stopNavigation()
  }

  @objc func turnByTurnNavigationChanged(sender: UISwitch) {
    sender.isOn ? startNavigation() : stopNavigation()
    updateControls()
  }

  @objc func guidanceActiveChanged(sender: UISwitch) {
    guard let navigator = navigator else { return }
    navigator.isGuidanceActive = sender.isOn
  }

  @objc func simulationPausedChanged(sender: UISwitch) {
    guard let navigationSession = navigationSession,
      let locationSimulator = navigationSession.locationSimulator
    else { return }
    locationSimulator.isPaused = sender.isOn
  }

  @objc func voiceGuidanceChanged(sender: UISwitch) {
    guard let navigator = navigator else { return }
    navigator.voiceGuidance = sender.isOn ? .alertsAndGuidance : .silent
  }

  @objc func simulationSpeedMultiplierChanged(sender: UISegmentedControl) {
    guard let navigationSession = navigationSession,
      let locationSimulator = navigationSession.locationSimulator
    else { return }

    let speedMultiplierArray: [Float] = [1.0, 2.0, 5.0, 10.0, 20.0]
    let speedMultiplier = speedMultiplierArray[sender.selectedSegmentIndex]
    locationSimulator.speedMultiplier = speedMultiplier
  }

  private func startNavigation() {
    guard let navigationSession = navigationSession,
      let locationSimulator = navigationSession.locationSimulator, let navigator = navigator
    else { return }
    mapView.isMyLocationEnabled = false
    mapView.enableNavigation(with: navigationSession)
    navigationSession.locationSimulator?.simulateLocationsAlongExistingRoute()
    updateControls()
  }

  private func stopNavigation() {
    guard let navigationSession = navigationSession,
      let locationSimulator = navigationSession.locationSimulator, let navigator = navigator
    else { return }
    mapView.cameraMode = .overview
    mapView.isNavigationEnabled = false
    mapView.isMyLocationEnabled = true
    updateControls()
  }

  func updateControls() {
    guard let navigationSession = navigationSession, let navigator = navigator,
      let locationSimulator = navigationSession.locationSimulator
    else { return }
    turnByTurnNavigationSwitch.isOn = mapView.isNavigationEnabled
    guidanceActiveSwitch.isOn = navigator.isGuidanceActive
    simulationPausedSwitch.isOn = locationSimulator.isPaused
    voiceGuidanceSwitch.isOn = navigator.voiceGuidance != .silent
  }

}

extension NavigationSessionViewController: GMSNavigatorListener {
  func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
    stopNavigation()
  }
}

extension NavigationSessionViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    guard let navigationSession = navigationSession, let navigator = navigationSession.navigator
    else { return }

    guard !navigator.isGuidanceActive else {
      // Can't edit route while navigating
      return
    }

    let marker = GMSMarker(position: coordinate)
    marker.map = mapView

    guard let waypoint = GMSNavigationWaypoint(location: coordinate, title: "Waypoint") else {
      return
    }
    waypoints.append(waypoint)

    updateControls()

  }
}
