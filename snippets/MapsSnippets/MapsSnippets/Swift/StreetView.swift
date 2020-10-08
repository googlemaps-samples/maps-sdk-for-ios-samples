//
//  StreetView.swift
//  MapsSnippets
//
//  Created by Chris Arriola on 9/29/20.
//  Copyright © 2020 Google. All rights reserved.
//

// [START maps_ios_streetview_add]
import GoogleMaps

class StreetView: UIViewController {
  // [START_EXCLUDE silent]
  var panoView: GMSPanoramaView!
  var mapView: GMSMapView!
  // [END_EXCLUDE]

  override func loadView() {
    let panoView = GMSPanoramaView(frame: .zero)
    self.view = panoView

    panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: -33.732, longitude: 150.312))
  }
}
// [END maps_ios_streetview_add]

extension StreetView {
  func extras() {
    // [START maps_ios_streetview_gestures]
    panoView.setAllGesturesEnabled(false)
    // [END maps_ios_streetview_gestures]

    // [START maps_ios_streetview_pov]
    panoView.camera = GMSPanoramaCamera(heading: 180, pitch: -10, zoom: 1)
    // [END maps_ios_streetview_pov]

    // [START maps_ios_streetview_markers]
    // Create a marker at the Eiffel Tower
    let position = CLLocationCoordinate2D(latitude: 48.858, longitude: 2.294)
    let marker = GMSMarker(position: position)

    // Add the marker to a GMSPanoramaView object named panoView
    marker.panoramaView = panoView

    // Add the marker to a GMSMapView object named mapView
    marker.map = mapView
    // [END maps_ios_streetview_markers]

    // [START maps_ios_streetview_marker_nil]
    marker.panoramaView = nil
    // [END maps_ios_streetview_marker_nil]
  }
}
