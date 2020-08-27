//
//  CustomPOIBehaviorViewController.swift
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomPOIBehaviorViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let camera = GMSCameraPosition(latitude: 47.0169, longitude: -122.336471, zoom: 12)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    self.view = mapView
    
    // [START maps_custom_poi_behavior_collision]
    let position = CLLocationCoordinate2D(latitude: 47.0169, longitude: -122.336471)
    let marker = GMSMarker(position: position)
    marker.zIndex = 10
    marker.collisionBehavior = GMSCollisionBehavior.optionalAndHidesLowerPriority
    marker.map = mapView
    // [END maps_custom_poi_behavior_collision]
  }
}
