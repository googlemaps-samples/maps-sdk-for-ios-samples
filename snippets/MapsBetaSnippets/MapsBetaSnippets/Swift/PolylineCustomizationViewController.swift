//
//  PolylineCustomizationViewController.swift
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

import UIKit
import GoogleMaps

class PolylineCustomizationViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let camera = GMSCameraPosition(latitude: 47.0169, longitude: -122.336471, zoom: 12)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    self.view = mapView
    
    // [START maps_polyline_customization]
    let path = GMSMutablePath()
    path.addLatitude(-37.81319, longitude: 144.96298)
    path.addLatitude(-31.95285, longitude: 115.85734)
    let polyline = GMSPolyline(path: path)
    let redWithStamp = GMSStrokeStyle.solidColor(.red)

    let image = UIImage(named: "imageFromBundleOrAsset")! // Image could be from anywhere
    redWithStamp.stampStyle = GMSTextureStyle(image: image)

    let span = GMSStyleSpan(style: redWithStamp)
    polyline.spans = [span]
    polyline.map = mapView
    // [END maps_polyline_customization]
  }
}
