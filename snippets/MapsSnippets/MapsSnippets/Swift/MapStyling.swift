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

// [START maps_ios_map_styling_json_file]
import GoogleMaps

class MapStyling: UIViewController {

  // Set the status bar style to complement night-mode.
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

    do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }

    self.view = mapView
  }
}
// [END maps_ios_map_styling_json_file]

// [START maps_ios_map_styling_string_resource]
class MapStylingStringResource: UIViewController {

  let MapStyle = "JSON_STYLE_GOES_HERE"

  // Set the status bar style to complement night-mode.
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

    do {
      // Set the map style by passing a valid JSON string.
      mapView.mapStyle = try GMSMapStyle(jsonString: MapStyle)
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }

    self.view = mapView
  }
}
// [END maps_ios_map_styling_string_resource]
