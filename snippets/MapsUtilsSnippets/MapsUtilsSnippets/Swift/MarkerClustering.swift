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

// [START maps_ios_marker_clustering_creation]
import GoogleMaps
import GoogleMapsUtils

class MarkerClustering: UIViewController, GMSMapViewDelegate {
  private var mapView: GMSMapView!
  private var clusterManager: GMUClusterManager!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the cluster manager with the supplied icon generator and
    // renderer.
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                                      renderer: renderer)

    // Register self to listen to GMSMapViewDelegate events.
    clusterManager.setMapDelegate(self)
    // [START_EXCLUDE]
    // [START maps_ios_marker_clustering_marker_individual]
    let position = CLLocationCoordinate2D(latitude: 47.60, longitude: -122.33)
    let marker = GMSMarker(position: position)
    clusterManager.add(marker)
    // [END maps_ios_marker_clustering_marker_individual]

    // [START maps_ios_marker_clustering_marker_array]
    let position1 = CLLocationCoordinate2D(latitude: 47.60, longitude: -122.33)
    let marker1 = GMSMarker(position: position1)

    let position2 = CLLocationCoordinate2D(latitude: 47.60, longitude: -122.46)
    let marker2 = GMSMarker(position: position2)

    let position3 = CLLocationCoordinate2D(latitude: 47.30, longitude: -122.46)
    let marker3 = GMSMarker(position: position3)

    let position4 = CLLocationCoordinate2D(latitude: 47.20, longitude: -122.23)
    let marker4 = GMSMarker(position: position4)

    let markerArray = [marker1, marker2, marker3, marker4]
    clusterManager.add(markerArray)
    // [END maps_ios_marker_clustering_marker_array]

    // [START maps_ios_marker_clustering_invoke]
    clusterManager.cluster()
    // [END maps_ios_marker_clustering_invoke]
    // [END_EXCLUDE]
  }
  // [START_EXCLUDE]
  // [START maps_ios_marker_clustering_events]
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    // center the map on tapped marker
    mapView.animate(toLocation: marker.position)
    // check if a cluster icon was tapped
    if marker.userData is GMUCluster {
      // zoom in on tapped cluster
      mapView.animate(toZoom: mapView.camera.zoom + 1)
      NSLog("Did tap cluster")
      return true
    }

    NSLog("Did tap a normal marker")
    return false
  }
  // [END maps_ios_marker_clustering_events]
  // [END_EXCLUDE]
}
// [END maps_ios_marker_clustering_creation]

