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

class BasicNavigationViewController: UIViewController {

  private enum ViewConstants {
    static let instructionsLabelHeight: CGFloat = 40
    static let instructionsLabelBackgroundColor: UIColor = .systemRed.withAlphaComponent(0.5)
    static let sampleStartingLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(
      40.74162563, -74.0048000)  //  A location near Google NYC.
    static let instructionsLabelText = "Long press on the map to add a destination."
  }

  lazy private var barButtonItem: UIBarButtonItem = {
    UIBarButtonItem(
      image: .init(systemName: "stop.fill"), style: .plain, target: self,
      action: #selector(stopNavigation))
  }()

  private lazy var mapView: GMSMapView = {
    let mapView = GMSMapView()
    mapView.isNavigationEnabled = true
    mapView.settings.compassButton = true
    mapView.delegate = self
    mapView.translatesAutoresizingMaskIntoConstraints = false
    return mapView
  }()

  private lazy var instructionsLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = ViewConstants.instructionsLabelText
    label.backgroundColor = ViewConstants.instructionsLabelBackgroundColor
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(mapView)
    view.addSubview(instructionsLabel)
    setupConstraints()

    mapView.locationSimulator?.simulateLocation(
      at: ViewConstants.sampleStartingLocation)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      instructionsLabel.topAnchor.constraint(equalTo: view.topAnchor),
      instructionsLabel.heightAnchor.constraint(
        equalToConstant: ViewConstants.instructionsLabelHeight),
      instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  private func requestRouteToCoordinate(_ coordinate: CLLocationCoordinate2D) {
    // This force-unwrap is safe because GMSNavigationWaypoint initializer returns a valid non-nil
    // object when a valid CLLocationCoordinate2D object is passed in. Validity of
    // CLLocationCoordinate2D is ensured by its own initializer.
    let destinations = [GMSNavigationWaypoint(location: coordinate, title: "Destination Point")!]
    mapView.navigator?.setDestinations(destinations) { [weak self] routeStatus in
      guard let self = self else { return }
      self.mapView.navigator?.isGuidanceActive = true
      self.mapView.locationSimulator?.simulateLocationsAlongExistingRoute()
      self.mapView.cameraMode = .following

      self.instructionsLabel.isHidden = true
      self.navigationItem.rightBarButtonItem = self.barButtonItem
    }
  }

  @objc private func stopNavigation() {
    mapView.locationSimulator?.stopSimulation()
    mapView.navigator?.isGuidanceActive = false
    mapView.navigator?.clearDestinations()

    instructionsLabel.isHidden = false
    navigationItem.rightBarButtonItem = nil
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopNavigation()
  }
}

// MARK: - GMSMapViewDelegate

extension BasicNavigationViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    requestRouteToCoordinate(coordinate)
  }
}
