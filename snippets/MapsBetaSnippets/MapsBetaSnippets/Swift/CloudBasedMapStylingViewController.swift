//
//  CloudBasedMapStylingViewController.swift
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

import UIKit
import GoogleMaps

class CloudBasedMapStylingViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // [START maps_cloud_based_map_styling_init]
    let camera = GMSCameraPosition(latitude: 47.0169, longitude: -122.336471, zoom: 12)
    let mapID = GMSMapID(identifier: "<YOUR MAP ID>")
    let mapView = GMSMapView(frame: .zero, mapID: mapID, camera: camera)
    self.view = mapView
    // [END maps_cloud_based_map_styling_init]
  }
}
