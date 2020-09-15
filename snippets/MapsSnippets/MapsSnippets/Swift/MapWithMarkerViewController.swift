//
//  MapWithMarkerViewController.swift
//  MapsSnippets
//
//  Created by Chris Arriola on 9/14/20.
//  Copyright © 2020 Google. All rights reserved.
//

import UIKit
import GoogleMaps

class MapWithMarkerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // [START maps_ios_map_with_marker_create_map]
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        // [END maps_ios_map_with_marker_create_map]

        // [START maps_ios_map_with_marker_add_marker]
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        // [END maps_ios_map_with_marker_add_marker]
  }
}
