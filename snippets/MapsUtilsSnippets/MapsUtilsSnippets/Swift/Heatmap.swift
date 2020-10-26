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


import GoogleMapsUtils

// [START maps_ios_heatmap_simple]
class Heatmap: UIViewController {

  private var mapView: GMSMapView!
  private var heatmapLayer: GMUHeatmapTileLayer!

  override func viewDidLoad() {
    super.viewDidLoad()
    heatmapLayer = GMUHeatmapTileLayer()
    heatmapLayer.map = mapView
  }

  // [START_EXCLUDE]
  func customize() {
    // [START maps_ios_heatmap_customize_gradient]
    let gradientColors: [UIColor] = [.green, .red]
    let gradientStartPoints: [NSNumber] = [0.2, 1.0]
    heatmapLayer.gradient = GMUGradient(
      colors: gradientColors,
      startPoints: gradientStartPoints,
      colorMapSize: 256
    )
    // [END maps_ios_heatmap_customize_gradient]

    // [START maps_ios_heatmap_customize_opacity]
    heatmapLayer.opacity = 0.7
    // [END maps_ios_heatmap_customize_opacity]

    // [START maps_ios_heatmap_remove]
    heatmapLayer.map = nil
    // [END maps_ios_heatmap_remove]
  }
  // [END_EXCLUDE]

  func addHeatmap() {

    // Get the data: latitude/longitude positions of police stations.
    guard let path = Bundle.main.url(forResource: "police_stations", withExtension: "json") else {
      return
    }
    guard let data = try? Data(contentsOf: path) else {
      return
    }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
      return
    }
    guard let object = json as? [[String: Any]] else {
      print("Could not read the JSON.")
      return
    }

    var list = [GMUWeightedLatLng]()
    for item in object {
      let lat = item["lat"] as! CLLocationDegrees
      let lng = item["lng"] as! CLLocationDegrees
      let coords = GMUWeightedLatLng(
        coordinate: CLLocationCoordinate2DMake(lat, lng),
        intensity: 1.0
      )
      list.append(coords)
    }

    // Add the latlngs to the heatmap layer.
    heatmapLayer.weightedData = list
  }
}
// [END maps_ios_heatmap_simple]
