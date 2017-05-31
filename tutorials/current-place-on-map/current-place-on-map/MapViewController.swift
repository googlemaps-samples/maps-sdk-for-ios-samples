/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {

  var locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  var mapView: GMSMapView!
  var placesClient: GMSPlacesClient!
  var zoomLevel: Float = 15.0

  // An array to hold the list of likely places.
  var likelyPlaces: [GMSPlace] = []

  // The currently selected place.
  var selectedPlace: GMSPlace?

  // A default location to use when location permission is not granted.
  let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

  // Update the map once the user has made their selection.
  @IBAction func unwindToMain(segue: UIStoryboardSegue) {
    // Clear the map.
    mapView.clear()

    // Add a marker to the map.
    if selectedPlace != nil {
      let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
      marker.title = selectedPlace?.name
      marker.snippet = selectedPlace?.formattedAddress
      marker.map = mapView
    }

    listLikelyPlaces()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize the location manager.
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    locationManager.distanceFilter = 50
    locationManager.startUpdatingLocation()
    locationManager.delegate = self

    placesClient = GMSPlacesClient.shared()

    // Create a map.
    let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                          longitude: defaultLocation.coordinate.longitude,
                                          zoom: zoomLevel)
    mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
    mapView.settings.myLocationButton = true
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.isMyLocationEnabled = true

    // Add the map to the view, hide it until we've got a location update.
    view.addSubview(mapView)
    mapView.isHidden = true

    listLikelyPlaces()
  }

  // Populate the array with the list of likely places.
  func listLikelyPlaces() {
    // Clean up from previous sessions.
    likelyPlaces.removeAll()

    placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
      if let error = error {
        // TODO: Handle the error.
        print("Current Place error: \(error.localizedDescription)")
        return
      }

      // Get likely places and add to the list.
      if let likelihoodList = placeLikelihoods {
        for likelihood in likelihoodList.likelihoods {
          let place = likelihood.place
          self.likelyPlaces.append(place)
        }
      }
    })
  }

  // Prepare the segue.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToSelect" {
      if let nextViewController = segue.destination as? PlacesViewController {
        nextViewController.likelyPlaces = likelyPlaces
      }
    }
  }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")

    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          zoom: zoomLevel)

    if mapView.isHidden {
      mapView.isHidden = false
      mapView.camera = camera
    } else {
      mapView.animate(to: camera)
    }

    listLikelyPlaces()
  }

  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
      // Display the map using the default location.
      mapView.isHidden = false
    case .notDetermined:
      print("Location status not determined.")
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse:
      print("Location status is OK.")
    }
  }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}
