// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


// [START maps_ios_events_map_view_delegate]
import GoogleMaps

class Events: UIViewController, GMSMapViewDelegate {
  // [START_EXCLUDE]
  // [START maps_ios_events_map_view_did_tap_coordinate]
  override func loadView() {
    super.loadView()
    let camera = GMSCameraPosition.camera(
      withLatitude: 1.285,
      longitude: 103.848,
      zoom: 12
    )
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.delegate = self
    self.view = mapView
  }

  // MARK: GMSMapViewDelegate

  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
  }
  // [END maps_ios_events_map_view_did_tap_coordinate]
  // [START maps_ios_events_map_view_geocoder]
  let geocoder = GMSGeocoder()

  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    mapView.clear()
  }

  func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
      geocoder.reverseGeocodeCoordinate(cameraPosition.target) { (response, error) in
        guard error == nil else {
          return
        }

        if let result = response?.firstResult() {
          let marker = GMSMarker()
          marker.position = cameraPosition.target
          marker.title = result.lines?[0]
          marker.snippet = result.lines?[1]
          marker.map = mapView
        }
      }
    }
  // [END maps_ios_events_map_view_geocoder]
  // [END_EXCLUDE]
}
// [END maps_ios_events_map_view_delegate]
