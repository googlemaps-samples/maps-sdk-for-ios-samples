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

class SideOfRoadViewController: BaseSampleViewController {

  /// Hard-coded example destination waypoints that demonstrate how the "side of road" feature
  /// works.
  private enum DestinationWaypoint: CaseIterable, CustomStringConvertible {
    case normal1
    case normal2
    case intersection
    case multiWaypoint

    var description: String {
      switch self {
      case .normal1:
        return "Normal 1"
      case .normal2:
        return "Normal 2"
      case .intersection:
        return "Intersection"
      case .multiWaypoint:
        return "Multi_waypoint"
      }
    }

    var waypoints: [GMSNavigationWaypoint] {
      var waypoints: [GMSNavigationWaypoint] = []
      switch self {
      case .normal1:
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.3671671, longitude: -122.0957),
          title: "Normal case 1", preferSameSideOfRoad: true)
        {
          waypoints.append(waypoint)
        }
      case .normal2:
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.3671671, longitude: -122.09639),
          title: "Normal case 2", preferSameSideOfRoad: true)
        {
          waypoints.append(waypoint)
        }
      case .intersection:
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.396788, longitude: -122.114264),
          title: "Intersection", preferredSegmentHeading: 270)
        {
          waypoints.append(waypoint)
        }
      case .multiWaypoint:
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.417399, longitude: -122.078371),
          title: "Multi-wayoint 1", preferSameSideOfRoad: true)
        {
          waypoints.append(waypoint)
        }
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.407739, longitude: -122.094243),
          title: "Multi-wayoint 2", preferSameSideOfRoad: true)
        {
          waypoints.append(waypoint)
        }
        if let waypoint = GMSNavigationWaypoint(
          location: CLLocationCoordinate2D(latitude: 37.397747, longitude: -122.095886),
          title: "Multi-wayoint 3", preferSameSideOfRoad: true)
        {
          waypoints.append(waypoint)
        }
      }
      return waypoints
    }
  }

  private let options: [DestinationWaypoint] = DestinationWaypoint.allCases

  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView()
    mapView.isNavigationEnabled = true
    mapView.cameraMode = .following
    mapView.settings.isRecenterButtonEnabled = false
    mapView.travelMode = .driving
    return mapView
  }()

  private lazy var requestRouteButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("Request route", for: .normal)
    button.addTarget(self, action: #selector(requestRoute), for: .touchUpInside)
    button.backgroundColor = .darkGray
    button.layer.cornerRadius = 5
    return button
  }()

  private lazy var travelIDControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: options.map { "\($0)" })
    segmentedControl.selectedSegmentIndex = 0
    return segmentedControl
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    // Add a map
    primaryStackView.insertArrangedSubview(mapView, at: 0)

    // Add a button to request the route.
    addMenuSubview(requestRouteButton)

    // Add segmented controls to Travel ID.
    addMenuSubview(travelIDControl)

    // Add a button to provide the direction list.
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Direction", style: .plain, target: self, action: #selector(tapDirectionsListButton))
    navigationItem.rightBarButtonItem?.isEnabled = false
  }

  /// Displays the directions list for the current route.
  @objc func tapDirectionsListButton() {
    guard let navigator = mapView.navigator else { return }
    let directionsListController = GMSNavigationDirectionsListController(navigator: navigator)
    let viewController = DirectionsListViewController()
    viewController.directionsListController = directionsListController
    navigationController?.pushViewController(viewController, animated: true)
  }

  /// Requests a route for the selected destination waypoint(s).
  @objc func requestRoute() {
    // Simulate at a fixed location near near Google HQ so the behaviour of this demo is consistent.
    mapView.locationSimulator?.simulateLocation(
      at: CLLocationCoordinate2D(latitude: 37.423620, longitude: -122.091703))
    let waypoints: [GMSNavigationWaypoint] = options[travelIDControl.selectedSegmentIndex].waypoints
    mapView.navigator?.clearDestinations()
    mapView.navigator?.setDestinations(waypoints) { [weak self] (routeStatus) in
      guard let self = self else { return }
      if routeStatus == .OK {
        self.mapView.cameraMode = .overview
        self.mapView.navigator?.isGuidanceActive = true
        self.mapView.locationSimulator?.simulateLocationsAlongExistingRoute()
        self.mapView.locationSimulator?.isPaused = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
      } else {
        // Show an error dialog to describe the failure.
        let message = routeStatus.description
        let alertController = UIAlertController(
          title: "Route failed", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true)
      }
    }
  }
}
