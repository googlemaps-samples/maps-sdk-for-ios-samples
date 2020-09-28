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
