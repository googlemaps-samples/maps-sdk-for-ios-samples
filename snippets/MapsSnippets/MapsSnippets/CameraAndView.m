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


#import "CameraAndView.h"
@import GoogleMaps;

@interface CameraAndView ()

@end

@implementation CameraAndView

GMSMapView *mapView;

- (void)viewDidLoad {
  [super viewDidLoad];
  // [START maps_ios_camera_and_view_position_1]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                          longitude:151.2086
                                                               zoom:16];
  mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
  // [END maps_ios_camera_and_view_position_1]

  // [START maps_ios_camera_and_view_position_2]
  mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
  // [END maps_ios_camera_and_view_position_2]

  // [START maps_ios_camera_and_view_move_1]
  GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                          longitude:151.2086
                                                               zoom:6];
  [mapView setCamera:sydney];
  // [END maps_ios_camera_and_view_move_1]

  // [START maps_ios_camera_and_view_move_2]
  GMSCameraPosition *fancy = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                         longitude:151.2086
                                                              zoom:6
                                                           bearing:30
                                                      viewingAngle:45];
  [mapView setCamera:fancy];
  // [END maps_ios_camera_and_view_move_2]

  // [START maps_ios_camera_and_view_move_animate]
  [mapView animateToViewingAngle:45];
  // [END maps_ios_camera_and_view_move_animate]

  // [START maps_ios_camera_and_view_move_update]
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(-33.8683, 151.2086);
  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(-33.994065, 151.251859);
  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                     coordinate:southWest];
  GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                           withPadding:50.0f];
  [mapView moveCamera:update];
  // [END maps_ios_camera_and_view_move_update]

  // [START maps_ios_camera_and_view_location_animate]
  [mapView animateToLocation:CLLocationCoordinate2DMake(-33.868, 151.208)];
  // [END maps_ios_camera_and_view_location_animate]

  // [START maps_ios_camera_and_view_location_set_camera]
  CLLocationCoordinate2D target =
      CLLocationCoordinate2DMake(-33.868, 151.208);
  mapView.camera = [GMSCameraPosition cameraWithTarget:target zoom:6];
  // [END maps_ios_camera_and_view_location_set_camera]

  // [START maps_ios_camera_and_view_zoom]
  [mapView animateToZoom:12];
  // [END maps_ios_camera_and_view_zoom]
}

- (void) minMaxZoom {
  // [START maps_ios_camera_and_view_min_max_zoom]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:41.887
                                                         longitude:-87.622
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero
                                          camera:camera];
  [mapView setMinZoom:10 maxZoom:15];
  // [END maps_ios_camera_and_view_min_max_zoom]

  // [START maps_ios_camera_and_view_min_max_zoom_2]
  [mapView setMinZoom:12 maxZoom:mapView.maxZoom];
  // [END maps_ios_camera_and_view_min_max_zoom_2]

  // [START maps_ios_camera_and_view_min_max_zoom_3]
  // Sets the zoom level to 4.
  GMSCameraPosition *camera2 = [GMSCameraPosition cameraWithLatitude:41.887
                                                           longitude:-87.622
                                                                zoom:4];
  GMSMapView *mapView2 = [GMSMapView mapWithFrame:CGRectZero
                                           camera:camera];
  // The current zoom, 4, is outside of the range. The zoom will change to 10.
  [mapView setMinZoom:10 maxZoom:15];
  // [END maps_ios_camera_and_view_min_max_zoom_3]

  // [START maps_ios_camera_and_view_bearing]
  [mapView animateToBearing:0];
  // [END maps_ios_camera_and_view_bearing]

  // [START maps_ios_camera_and_view_viewing_angle]
  [mapView animateToViewingAngle:45];
  // [END maps_ios_camera_and_view_viewing_angle]
}

- (void)cameraPosition {
  // [START maps_ios_camera_and_view_camera_position]
  CLLocationCoordinate2D vancouver = CLLocationCoordinate2DMake(49.26, -123.11);
  CLLocationCoordinate2D calgary = CLLocationCoordinate2DMake(51.05, -114.05);
  GMSCoordinateBounds *bounds =
      [[GMSCoordinateBounds alloc] initWithCoordinate:vancouver coordinate:calgary];
  GMSCameraPosition *camera = [mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
  mapView.camera = camera;
  // [END maps_ios_camera_and_view_camera_position]
}

- (void)cameraUpdate {
  // [START maps_ios_camera_and_view_camera_cameraupdate]
  // Zoom in one zoom level
  GMSCameraUpdate *zoomCamera = [GMSCameraUpdate zoomIn];
  [mapView animateWithCameraUpdate:zoomCamera];

  // Center the camera on Vancouver, Canada
  CLLocationCoordinate2D vancouver = CLLocationCoordinate2DMake(49.26, -123.11);
  GMSCameraUpdate *vancouverCam = [GMSCameraUpdate setTarget:vancouver];
  [mapView animateWithCameraUpdate:vancouverCam];

  // Move the camera 100 points down, and 200 points to the right.
  GMSCameraUpdate *downwards = [GMSCameraUpdate scrollByX:100.0 Y:200.0];
  [mapView animateWithCameraUpdate:downwards];
  // [END maps_ios_camera_and_view_camera_cameraupdate]
}
@end
