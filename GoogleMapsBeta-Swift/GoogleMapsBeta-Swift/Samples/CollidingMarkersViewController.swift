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

class CollidingMarkersViewController: UIViewController {

  private var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let camera = GMSCameraPosition(target: CLLocationCoordinate2D.newYork, zoom: 14)

    mapView = GMSMapView(frame: self.view.bounds, camera: camera)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.view.addSubview(mapView)

    let requiredCollidingFirstPosition = CLLocationCoordinate2D(
      latitude: CLLocationCoordinate2D.newYork.latitude - 0.002,
      longitude: CLLocationCoordinate2D.newYork.longitude - 0.003
    )
    let requiredNonCollidingFirstPosition = CLLocationCoordinate2D(
      latitude: CLLocationCoordinate2D.newYork.latitude,
      longitude: CLLocationCoordinate2D.newYork.longitude - 0.003
    )
    let optionalFirstPosition = CLLocationCoordinate2D(
      latitude: CLLocationCoordinate2D.newYork.latitude - 0.001,
      longitude: CLLocationCoordinate2D.newYork.longitude
    )
    let markerSpacing: CLLocationDegrees = 0.004

    var markerCount = 0

    for i in 0...2 {
      for j in 0...2 {
        let _ = createNonCollidingMarker(
          latitude: requiredNonCollidingFirstPosition.latitude + (Double(i) * markerSpacing),
          longitude: requiredNonCollidingFirstPosition.longitude + (Double(j) * markerSpacing),
          zIndex: Int32(markerCount)
        )
        markerCount += 1

        let _ = createOptionalMarker(
          latitude: optionalFirstPosition.latitude + (Double(i) * markerSpacing),
          longitude: optionalFirstPosition.longitude + (Double(j) * markerSpacing),
          zIndex: Int32(markerCount)
        )
        markerCount += 1

        let _ = createRequiredMarker(
          latitude: requiredCollidingFirstPosition.latitude + (Double(i) * markerSpacing),
          longitude: requiredCollidingFirstPosition.longitude + (Double(j) * markerSpacing),
          zIndex: Int32(markerCount)
        )
        markerCount += 1
      }
    }
  }
  
  /// These are the "standard" markers - they will show up no matter what, and they don't have
  /// intersection or collision checking with map labels or other markers.
  private func createNonCollidingMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zIndex: Int32) -> GMSMarker {
    let marker = GMSMarker()
    marker.title = "Non-Colliding"
    marker.snippet = "zIndex: \(zIndex)"
    marker.zIndex = zIndex
    marker.isDraggable = true
    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    marker.icon = GMSMarker.markerImage(with: .blue)
    marker.map = mapView
    // No need for setting collision behavior since it's the default behavior, but setting to
    // GMSCollisionBehavior.required also works.
    return marker
  }

  /// These markers will show up if they aren't intersecting anything higher priority (required or
  /// higher zIndex optional markers), and they will hide intersecting normal map labels or lower
  /// zIndex optional markers.
  ///
  /// Note: While an optional marker is in the middle of being dragged, it is considered higher
  /// priority than other optional markers, regardless of zIndex. But once it has been dropped,
  /// priority goes back to zIndices.
  private func createOptionalMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zIndex: Int32) -> GMSMarker {
    let marker = GMSMarker()
    marker.title = "Optional"
    marker.snippet = "zIndex: \(zIndex)"
    marker.zIndex = zIndex
    marker.isDraggable = true
    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    marker.icon = GMSMarker.markerImage(with: .green)
    marker.collisionBehavior = .optionalAndHidesLowerPriority
    marker.map = mapView
    return marker;
  }

  /// These markers will always show up, and they will hide intersecting normal map labels or optional markers.
  private func createRequiredMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zIndex: Int32) -> GMSMarker {
    let marker = GMSMarker()
    marker.title = "Required"
    marker.snippet = "zIndex: \(zIndex)"
    marker.zIndex = zIndex
    marker.isDraggable = true
    marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    marker.icon = GMSMarker.markerImage(with: .green)
    marker.collisionBehavior = .requiredAndHidesOptional
    marker.map = mapView
    return marker
  }
}
