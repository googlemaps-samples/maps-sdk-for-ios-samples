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

// [START maps_ios_map_objects_add]
import GoogleMaps

class MapObjects : UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let camera = GMSCameraPosition(latitude: 1.285, longitude: 103.848, zoom: 12)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    self.view = mapView
  }
}
// [END maps_ios_map_objects_add]

extension MapObjects {
  private func mapType() {
    // [START maps_ios_map_objects_map_type]
    let camera = GMSCameraPosition.camera(withLatitude: -33.8683, longitude: 151.2086, zoom: 6)
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.mapType = .satellite
    // [END maps_ios_map_objects_map_type]

    // [START maps_ios_map_objects_indoor]
    mapView.isIndoorEnabled = false
    // [END maps_ios_map_objects_indoor]

    // [START maps_ios_map_objects_accessibility]
    mapView.accessibilityElementsHidden = false
    // [END maps_ios_map_objects_accessibility]

    // [START maps_ios_map_objects_my_location_enabled]
    mapView.isMyLocationEnabled = true
    // [END maps_ios_map_objects_my_location_enabled]

    // [START maps_ios_map_objects_my_location_log]
    print("User's location: \(String(describing: mapView.myLocation))")
    // [END maps_ios_map_objects_my_location_log]

    // [START maps_ios_map_objects_insets]
    // Insets are specified in this order: top, left, bottom, right
    let mapInsets = UIEdgeInsets(top: 100.0, left: 0.0, bottom: 0.0, right: 300.0)
    mapView.padding = mapInsets
    // [END maps_ios_map_objects_insets]
  }
}
