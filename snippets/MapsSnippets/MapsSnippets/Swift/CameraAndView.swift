//
//  CameraAndView.swift
//  MapsSnippets
//
//  Created by Chris Arriola on 10/2/20.
//  Copyright © 2020 Google. All rights reserved.
//

import GoogleMaps

class CmaeraAndView: UIViewController {

  var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // [START maps_ios_camera_and_view_position_1]
    let camera = GMSCameraPosition.camera(
      withLatitude: -33.8683,
      longitude: 151.2086,
      zoom: 16
    )
    mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
    // [END maps_ios_camera_and_view_position_1]

    // [START maps_ios_camera_and_view_position_2]
    mapView = GMSMapView(frame: self.view.bounds)
    // [END maps_ios_camera_and_view_position_2]

    // [START maps_ios_camera_and_view_move_1]
    let sydney = GMSCameraPosition.camera(
      withLatitude: -33.8683,
      longitude: 151.2086,
      zoom: 6
    )
    mapView.camera = sydney
    // [END maps_ios_camera_and_view_move_1]

    // [START maps_ios_camera_and_view_move_2]
    let fancy = GMSCameraPosition.camera(
      withLatitude: -33,
      longitude: 151,
      zoom: 6,
      bearing: 270,
      viewingAngle: 45
    )
    mapView.camera = fancy
    // [END maps_ios_camera_and_view_move_2]

    // [START maps_ios_camera_and_view_move_animate]
    mapView.animate(toViewingAngle: 45)
    // [END maps_ios_camera_and_view_move_animate]

    // [START maps_ios_camera_and_view_move_update]
    let northEast = CLLocationCoordinate2D(latitude: -33.8683, longitude: 151.2086)
    let southWest = CLLocationCoordinate2D(latitude: -33.994065, longitude: 151.251859)
    let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)

    let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
    mapView.moveCamera(update)
    // [END maps_ios_camera_and_view_move_update]

    // [START maps_ios_camera_and_view_location_animate]
    mapView.animate(toLocation: CLLocationCoordinate2D(latitude: -33.868, longitude: 151.208))
    // [END maps_ios_camera_and_view_location_animate]

    // [START maps_ios_camera_and_view_location_set_camera]
    let target = CLLocationCoordinate2D(latitude: -33.868, longitude: 151.208)
    mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 6)
    // [END maps_ios_camera_and_view_location_set_camera]

    // [START maps_ios_camera_and_view_zoom]
    mapView.animate(toZoom: 12)
    // [END maps_ios_camera_and_view_zoom]
  }

  func minMaxZoom() {
    // [START maps_ios_camera_and_view_min_max_zoom]
    let camera = GMSCameraPosition.camera(
      withLatitude: 41.887,
      longitude: -87.622,
      zoom: 12
    )
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.setMinZoom(10, maxZoom: 15)
    // [END maps_ios_camera_and_view_min_max_zoom]

    // [START maps_ios_camera_and_view_min_max_zoom_2]
    mapView.setMinZoom(12, maxZoom: mapView.maxZoom)
    // [END maps_ios_camera_and_view_min_max_zoom_2]

    // [START maps_ios_camera_and_view_min_max_zoom_3]
    // Sets the zoom level to 4.
    let camera2 = GMSCameraPosition.camera(
      withLatitude: 41.887,
      longitude: -87.622,
      zoom: 4
    )
    let mapView2 = GMSMapView.map(withFrame: .zero, camera: camera)

    // The current zoom, 4, is outside of the range. The zoom will change to 10.
    mapView.setMinZoom(10, maxZoom: 15)
    // [END maps_ios_camera_and_view_min_max_zoom_3]

    // [START maps_ios_camera_and_view_bearing]
    mapView.animate(toBearing: 0)
    // [END maps_ios_camera_and_view_bearing]

    // [START maps_ios_camera_and_view_viewing_angle]
    mapView.animate(toViewingAngle: 45)
    // [END maps_ios_camera_and_view_viewing_angle]
  }

  func cameraPosition() {
    // [START maps_ios_camera_and_view_camera_position]
    let vancouver = CLLocationCoordinate2D(latitude: 49.26, longitude: -123.11)
    let calgary = CLLocationCoordinate2D(latitude: 51.05,longitude: -114.05)
    let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
    let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
    mapView.camera = camera
    // [END maps_ios_camera_and_view_camera_position]
  }

  func cameraUpdate() {
    // [START maps_ios_camera_and_view_camera_cameraupdate]
    // Zoom in one zoom level
    let zoomCamera = GMSCameraUpdate.zoomIn()
    mapView.animate(with: zoomCamera)

    // Center the camera on Vancouver, Canada
    let vancouver = CLLocationCoordinate2D(latitude: 49.26, longitude: -123.11)
    let vancouverCam = GMSCameraUpdate.setTarget(vancouver)
    mapView.animate(with: vancouverCam)

    // Move the camera 100 points down, and 200 points to the right.
    let downwards = GMSCameraUpdate.scrollBy(x: 100, y: 200)
    mapView.animate(with: downwards)
    // [END maps_ios_camera_and_view_camera_cameraupdate]
  }
}
