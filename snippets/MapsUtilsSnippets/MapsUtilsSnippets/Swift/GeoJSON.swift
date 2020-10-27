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

// [START maps_ios_geojson]
import GoogleMapsUtils

class GeoJSON {
  private var mapView: GMSMapView!

  func renderGeoJSON() {
    guard let path = Bundle.main.path(forResource: "GeoJSON_sample", ofType: "json") else {
      return
    }

    let url = URL(fileURLWithPath: path)

    let geoJsonParser = GMUGeoJSONParser(url: url)
    geoJsonParser.parse()

    let renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
    renderer.render()
  }
}
// [END maps_ios_geojson]
