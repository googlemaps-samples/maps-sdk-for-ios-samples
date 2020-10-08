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

// [START maps_ios_tile_layers_subclass]
class TestTileLayer: GMSSyncTileLayer {
  override func tileFor(x: UInt, y: UInt, zoom: UInt) -> UIImage? {
    // On every odd tile, render an image.
    if (x % 2 == 1) {
      return UIImage(named: "australia")
    } else {
      return kGMSTileLayerNoTile
    }
  }
}

// [END maps_ios_tile_layers_subclass]

class TileLayers {
  var mapView: GMSMapView!

  func tileLayers() {
    // [START maps_ios_tile_layers_add]
    let floor = 1

    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
    let urls: GMSTileURLConstructor = { (x, y, zoom) in
      let url = "https://www.example.com/floorplans/L\(floor)_\(zoom)_\(x)_\(y).png"
      return URL(string: url)
    }

    // Create the GMSTileLayer
    let layer = GMSURLTileLayer(urlConstructor: urls)

    // Display on the map at a specific zIndex
    layer.zIndex = 100
    layer.map = mapView
    // [END maps_ios_tile_layers_add]
  }

  func tileLayer() {
    // [START maps_ios_tile_layers_subclass_init]
    let layer = TestTileLayer()
    layer.map = mapView
    // [END maps_ios_tile_layers_subclass_init]

    // [START maps_ios_tile_layers_clear]
    layer.clearTileCache()
    // [END maps_ios_tile_layers_clear]
  }
}
