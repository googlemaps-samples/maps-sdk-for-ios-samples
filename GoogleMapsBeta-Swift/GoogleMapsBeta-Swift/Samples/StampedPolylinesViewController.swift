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

class StampedPolylinesViewController : UIViewController {
  private let strokeWidth: CGFloat = 20.0

  override func viewDidLoad() {
    super.viewDidLoad()

    let camera = GMSCameraPosition(target: CLLocationCoordinate2D.seattle, zoom: 14)
    let map = GMSMapView(frame: self.view.bounds, camera: camera)
    map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(map)

    // Make a texture stamped polyline.
    let path = GMSMutablePath()
    path.addCoordinate(CLLocationCoordinate2D.seattle, latOffset: 0.003, longOffset: -0.003)
    path.addCoordinate(CLLocationCoordinate2D.seattle, latOffset: -0.005, longOffset: -0.005)
    path.addCoordinate(CLLocationCoordinate2D.seattle, latOffset: -0.007, longOffset: 0.001)

    let stamp = UIImage(named: "voyager")!
    let solidStroke = GMSStrokeStyle.solidColor(.red)
    solidStroke.stampStyle = GMSTextureStyle(image: stamp)

    let texturePolyline = GMSPolyline(path: path)
    texturePolyline.strokeWidth = strokeWidth
    texturePolyline.spans = [GMSStyleSpan(style: solidStroke)]
    texturePolyline.map = map

    // Make a textured polyline using a clear stroke, with a gradient line behind it since
    // gradients aren't enabled yet for the same line.
    let texturePath = GMSMutablePath()
    texturePath.addCoordinate(CLLocationCoordinate2D.seattle, latOffset: -0.012, longOffset: 0)
    texturePath.addCoordinate(CLLocationCoordinate2D.seattle, latOffset: -0.012, longOffset: -0.008)

    let textureStamp = UIImage(named: "aeroplane")!
    let clearTextureStroke = GMSStrokeStyle.solidColor(.clear)
    clearTextureStroke.stampStyle = GMSTextureStyle(image: textureStamp)

    let clearTexturePolyline = GMSPolyline(path: texturePath)
    clearTexturePolyline.strokeWidth = strokeWidth * 1.5
    clearTexturePolyline.spans = [GMSStyleSpan(style: clearTextureStroke)]
    clearTexturePolyline.zIndex = 1
    clearTexturePolyline.map = map

    // Use the same path.
    let gradientStroke = GMSStrokeStyle.gradient(from: .magenta, to: .green)
    let gradientPolyline = GMSPolyline(path: texturePath)
    gradientPolyline.strokeWidth = strokeWidth * 1.5
    gradientPolyline.spans = [GMSStyleSpan(style: gradientStroke)]

    // Use a lower zIndex to put it behind the other line.
    gradientPolyline.zIndex = clearTexturePolyline.zIndex - 1
    gradientPolyline.map = map
  }
}

extension GMSMutablePath {
  func addCoordinate(_ coordinate: CLLocationCoordinate2D, latOffset: CLLocationDegrees, longOffset: CLLocationDegrees) {
    addLatitude(coordinate.latitude + latOffset, longitude: coordinate.longitude + longOffset)
  }
}
