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


import GoogleMaps

class ControlsAndGestures : UIViewController {
  // [START maps_ios_controls_and_gestures_map]
  override func loadView() {
    let camera = GMSCameraPosition.camera(
      withLatitude: 1.285,
      longitude: 103.848,
      zoom: 12
    )

    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.settings.scrollGestures = false
    mapView.settings.zoomGestures = false
    self.view = mapView
  }
  // [END maps_ios_controls_and_gestures_map]

  override func viewDidLoad() {
    super.viewDidLoad()
    // [START maps_ios_controls_and_gestures_compass]
    let camera = GMSCameraPosition(latitude: 37.757815, longitude: -122.50764, zoom: 12)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    mapView.settings.compassButton = true
    // [END maps_ios_controls_and_gestures_compass]

    // [START maps_ios_controls_and_gestures_my_location]
    mapView.settings.myLocationButton = true
    // [END maps_ios_controls_and_gestures_my_location]

    // [START maps_ios_controls_and_gestures_floor_picker]
    mapView.settings.indoorPicker = false
    // [END maps_ios_controls_and_gestures_floor_picker]
  }
}
