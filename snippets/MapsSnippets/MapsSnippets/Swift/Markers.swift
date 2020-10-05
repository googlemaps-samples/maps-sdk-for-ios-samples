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


// [START maps_ios_markers_icon_view]
import CoreLocation
import GoogleMaps

class MarkerViewController: UIViewController, GMSMapViewDelegate {
  var mapView: GMSMapView!
  var london: GMSMarker?
  var londonView: UIImageView?

  override func viewDidLoad() {
    super.viewDidLoad()

    let camera = GMSCameraPosition.camera(
      withLatitude: 51.5,
      longitude: -0.127,
      zoom: 14
    )
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    view = mapView

    mapView.delegate = self

    let house = UIImage(named: "House")!.withRenderingMode(.alwaysTemplate)
    let markerView = UIImageView(image: house)
    markerView.tintColor = .red
    londonView = markerView

    let position = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.127)
    let marker = GMSMarker(position: position)
    marker.title = "London"
    marker.iconView = markerView
    marker.tracksViewChanges = true
    marker.map = mapView
    london = marker
  }

  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    UIView.animate(withDuration: 5.0, animations: { () -> Void in
      self.londonView?.tintColor = .blue
    }, completion: {(finished) in
      // Stop tracking view changes to allow CPU to idle.
      self.london?.tracksViewChanges = false
    })
  }
}
// [END maps_ios_markers_icon_view]

var mapView: GMSMapView!

func addMarker() {
  // [START maps_ios_markers_add_marker]
  let position = CLLocationCoordinate2D(latitude: 10, longitude: 10)
  let marker = GMSMarker(position: position)
  marker.title = "Hello World"
  marker.map = mapView
  // [END maps_ios_markers_add_marker]
}

func removeMarker() {
  // [START maps_ios_markers_remove_marker]
  let camera = GMSCameraPosition.camera(
    withLatitude: -33.8683,
    longitude: 151.2086,
    zoom: 6
  )
  let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
  // ...
  mapView.clear()
  // [END maps_ios_markers_remove_marker]

  // [START maps_ios_markers_remove_marker_modifications]
  let position = CLLocationCoordinate2D(latitude: 10, longitude: 10)
  let marker = GMSMarker(position: position)
  marker.map = mapView
  // ...
  marker.map = nil
  // [END maps_ios_markers_remove_marker_modifications]

  // [START maps_ios_markers_customize_marker_color]
  marker.icon = GMSMarker.markerImage(with: .black)
  // [END maps_ios_markers_customize_marker_color]

  // [START maps_ios_markers_customize_marker_image]
  let positionLondon = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.127)
  let london = GMSMarker(position: positionLondon)
  london.title = "London"
  london.icon = UIImage(named: "house")
  london.map = mapView
  // [END maps_ios_markers_customize_marker_image]

  // [START maps_ios_markers_opacity]
  marker.opacity = 0.6
  // [END maps_ios_markers_opacity]
}

func moreCustomizations() {
  // [START maps_ios_markers_flatten]
  let positionLondon = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.127)
  let londonMarker = GMSMarker(position: positionLondon)
  londonMarker.isFlat = true
  londonMarker.map = mapView
  // [END maps_ios_markers_flatten]

  // [START maps_ios_markers_rotate]
  let degrees = 90.0
  londonMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
  londonMarker.rotation = degrees
  londonMarker.map = mapView
  // [END maps_ios_markers_rotate]
}

func infoWindow() {
  // [START maps_ios_markers_info_window_title]
  let position = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.127)
  let london = GMSMarker(position: position)
  london.title = "London"
  london.map = mapView
  // [END maps_ios_markers_info_window_title]

  // [START maps_ios_markers_info_window_title_and_snippet]
  london.title = "London"
  london.snippet = "Population: 8,174,100"
  london.map = mapView
  // [END maps_ios_markers_info_window_title_and_snippet]

  // [START maps_ios_markers_info_window_changes]
  london.tracksInfoWindowChanges = true
  // [END maps_ios_markers_info_window_changes]

  // [START maps_ios_markers_info_window_change_position]
  london.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
  london.icon = UIImage(named: "house")
  london.map = mapView
  // [END maps_ios_markers_info_window_change_position]
}
