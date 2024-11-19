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

class StopoverViewController: BaseSampleViewController {

  /// Hard-coded example destination waypoints that can be used to demonstrate how the "vehcile
  /// stopover" flag affects routes.
  private enum DestinationWaypoint: CaseIterable, CustomStringConvertible {
    case tunnel1
    case tunnel2
    case freeway1
    case freeway2

    var description: String {
      switch self {
      case .tunnel1:
        return "Tunnel 1"
      case .tunnel2:
        return "Tunnel 2"
      case .freeway1:
        return "Freeway 1"
      case .freeway2:
        return "Freeway 2"
      }
    }

    var waypoints: [GMSNavigationMutableWaypoint] {
      let title = "Stopover destination"
      var waypoints: [GMSNavigationMutableWaypoint] = []
      switch self {
      case .tunnel1:
        if let waypoint = GMSNavigationMutableWaypoint(
          location: CLLocationCoordinate2D(latitude: 1.297535, longitude: 103.846630),
          title: title)
        {
          waypoints.append(waypoint)
        }
      case .tunnel2:
        if let waypoint = GMSNavigationMutableWaypoint(
          location: CLLocationCoordinate2D(latitude: 1.302525, longitude: 103.878126),
          title: title)
        {
          waypoints.append(waypoint)
        }
      case .freeway1:
        if let waypoint = GMSNavigationMutableWaypoint(
          location: CLLocationCoordinate2D(latitude: -6.122432, longitude: 106.859372),
          title: title)
        {
          waypoints.append(waypoint)
        }
      case .freeway2:
        if let waypoint = GMSNavigationMutableWaypoint(
          location: CLLocationCoordinate2D(latitude: 14.503486, longitude: 121.036674),
          title: title)
        {
          waypoints.append(waypoint)
        }
      }
      return waypoints
    }

    var startCoordinate: CLLocationCoordinate2D {
      switch self {
      case .tunnel1:
        return CLLocationCoordinate2D(latitude: 1.295720, longitude: 103.848683)
      case .tunnel2:
        return CLLocationCoordinate2D(latitude: 1.298818, longitude: 103.877174)
      case .freeway1:
        return CLLocationCoordinate2D(latitude: -6.126155, longitude: 106.849174)
      case .freeway2:
        return CLLocationCoordinate2D(latitude: 14.502297, longitude: 121.0351525)
      }
    }
  }
  private let options: [DestinationWaypoint] = DestinationWaypoint.allCases
  private var vehicleStopover = false

  private lazy var mapView: GMSMapView = {
    let camera = GMSCameraPosition(latitude: 1.295720, longitude: 103.848683, zoom: 13)
    let options = GMSMapViewOptions()
    options.camera = camera
    options.frame = .zero
    let mapView = GMSMapView(options: options)
    mapView.isNavigationEnabled = true
    mapView.cameraMode = .following
    mapView.settings.isRecenterButtonEnabled = true
    mapView.travelMode = .driving
    return mapView
  }()

  private lazy var travelIDControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: options.map { "\($0)" })
    segmentedControl.addTarget(self, action: #selector(simulateToStartLocation), for: .valueChanged)
    segmentedControl.selectedSegmentIndex = 0
    return segmentedControl
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    // Add a map.
    primaryStackView.insertArrangedSubview(mapView, at: 0)
    mapView.locationSimulator?.simulateLocation(at: DestinationWaypoint.tunnel1.startCoordinate)

    // Add a button to request the route.
    addMenuSubview(
      MenuUIHelpers.makeMenuButton(
        title: "Request route", onTouchUpInside: (target: self, action: #selector(requestRoute))))

    // Add a button to clear the destination.
    addMenuSubview(
      MenuUIHelpers.makeMenuButton(
        title: "Clear destination",
        onTouchUpInside: (target: self, action: #selector(clearDestination))))

    // Add a stopover switch.
    addMenuSubview(
      NavDemoSwitch(
        title: "Vehicle Stopover",
        onValueChanged: (target: self, action: #selector(updateVehicleStopover))))

    // Add segmented controls to Travel ID.
    addMenuSubview(travelIDControl)
  }

  @objc func requestRoute() {
    let waypoints: [GMSNavigationMutableWaypoint] = options[travelIDControl.selectedSegmentIndex]
      .waypoints
    waypoints.forEach { (waypoint) in
      waypoint.vehicleStopover = vehicleStopover
    }
    mapView.navigator?.clearDestinations()
    mapView.navigator?.setDestinations(waypoints) { [weak self] (routeStatus) in
      self?.handleRouteCallback(with: routeStatus)
    }
  }

  /// Handles a route response with the given success or failure status.
  private func handleRouteCallback(with routeStatus: GMSRouteStatus) {
    guard routeStatus != .OK else { return }
    // Show an error dialog to describe the failure.
    let message = routeStatus.description
    let alertController = UIAlertController(
      title: "Route failed", message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(defaultAction)
    present(alertController, animated: true)
  }

  @objc func clearDestination() {
    guard let navigator = mapView.navigator else { return }
    navigator.isGuidanceActive = false
    navigator.clearDestinations()
  }

  @objc func simulateToStartLocation() {
    let startCoordinate = options[travelIDControl.selectedSegmentIndex].startCoordinate
    if CLLocationCoordinate2DIsValid(startCoordinate) {
      mapView.locationSimulator?.simulateLocation(at: startCoordinate)
    }
  }

  @objc func updateVehicleStopover(sender: UISwitch) {
    vehicleStopover = sender.isOn
  }
}
