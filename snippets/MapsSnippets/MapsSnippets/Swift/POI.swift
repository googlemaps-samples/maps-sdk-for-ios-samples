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

// [START maps_ios_poi_click_event_listening]
import GoogleMaps

class POI: UIViewController, GMSMapViewDelegate {

  override func loadView() {
    let camera = GMSCameraPosition.camera(
      withLatitude: 47.603,
      longitude:-122.331,
      zoom:14
    )
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.delegate = self
    self.view = mapView
  }

  func mapView(
    _ mapView: GMSMapView,
    didTapPOIWithPlaceID placeID: String,
    name: String,
    location: CLLocationCoordinate2D
  ) {
    print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
  }
}
// [END maps_ios_poi_click_event_listening]

class POIInfoWindow {
  // [START maps_ios_poi_info_window_details]
  // Declare GMSMarker instance at the class level.
  let infoMarker = GMSMarker()

  // Attach an info window to the POI using the GMSMarker.
  func mapView(
    _ mapView: GMSMapView,
    didTapPOIWithPlaceID placeID: String,
    name: String,
    location: CLLocationCoordinate2D
  ) {
    infoMarker.snippet = placeID
    infoMarker.position = location
    infoMarker.title = name
    infoMarker.opacity = 0;
    infoMarker.infoWindowAnchor.y = 1
    infoMarker.map = mapView
    mapView.selectedMarker = infoMarker
  }
  // [END maps_ios_poi_info_window_details]
}
