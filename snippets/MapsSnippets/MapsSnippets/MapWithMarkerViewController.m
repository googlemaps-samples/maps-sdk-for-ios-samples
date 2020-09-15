//
//  MapWithMarkerViewController.m
//  MapsSnippets
//
//  Created by Chris Arriola on 9/14/20.
//  Copyright © 2020 Google. All rights reserved.
//

#import "MapWithMarkerViewController.h"
@import GoogleMaps;

@interface MapWithMarkerViewController ()

@end

@implementation MapWithMarkerViewController

- (void)loadView {
  [super loadView];
  // [START maps_ios_map_with_marker_create_map]
  // Create a GMSCameraPosition that tells the map to display the
  // coordinate -33.86,151.20 at zoom level 6.
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                          longitude:151.20
                                                               zoom:6.0];
  GMSMapView *mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
  self.view = mapView;
  // [END maps_ios_map_with_marker_create_map]

  // [START maps_ios_map_with_marker_add_marker]
  // Creates a marker in the center of the map.
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
  marker.title = @"Sydney";
  marker.snippet = @"Australia";
  marker.map = mapView;
  // [END maps_ios_map_with_marker_add_marker]
}

@end
