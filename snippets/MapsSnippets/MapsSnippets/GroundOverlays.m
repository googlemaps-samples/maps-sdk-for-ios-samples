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


#import "GroundOverlays.h"
@import GoogleMaps;

@implementation GroundOverlays

GMSMapView *mapView;

- (void)addOverlay {
  // [START maps_ios_ground_overlays_add]
  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(40.712216,-74.22655);
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(40.773941,-74.12544);
  GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest
                                                                          coordinate:northEast];

  // Image from http://www.lib.utexas.edu/maps/historical/newark_nj_1922.jpg
  UIImage *icon = [UIImage imageNamed:@"newark_nj_1922"];
  // [START maps_ios_ground_overlays_modify]
  GMSGroundOverlay *overlay = [GMSGroundOverlay groundOverlayWithBounds:overlayBounds icon:icon];
  overlay.bearing = 0;
  overlay.map = mapView;
  // [END maps_ios_ground_overlays_add]

  // [START_EXCLUDE]
  // [START maps_ios_ground_overlays_remove]
  [mapView clear];
  // [END maps_ios_ground_overlays_remove]
  // [END_EXCLUDE]
  overlay.tappable = YES;
  // [END maps_ios_ground_overlays_modify]
}

@end
