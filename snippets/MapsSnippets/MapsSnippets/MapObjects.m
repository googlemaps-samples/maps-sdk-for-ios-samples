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

// [START maps_ios_map_objects_add]
#import "MapObjects.h"
@import GoogleMaps;

@implementation MapObjects

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                          longitude:103.848
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = mapView;
}

@end
// [END maps_ios_map_objects_add]

@interface MapObjectsExt : NSObject

@end

@implementation MapObjectsExt

- (void)mapType {
  // [START maps_ios_map_objects_map_type]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                          longitude:151.2086
                                                               zoom:6];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.mapType = kGMSTypeSatellite;
  // [END maps_ios_map_objects_map_type]

  // [START maps_ios_map_objects_indoor]
  mapView.indoorEnabled = NO;
  // [END maps_ios_map_objects_indoor]

  // [START maps_ios_map_objects_accessibility]
  mapView.accessibilityElementsHidden = NO;
  // [END maps_ios_map_objects_accessibility]

  // [START maps_ios_map_objects_my_location_enabled]
  mapView.myLocationEnabled = YES;
  // [END maps_ios_map_objects_my_location_enabled]

  // [START maps_ios_map_objects_my_location_log]
  NSLog(@"User's location: %@", mapView.myLocation);
  // [END maps_ios_map_objects_my_location_log]

  // [START maps_ios_map_objects_insets]
  // Insets are specified in this order: top, left, bottom, right
  UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 0.0, 0.0, 300.0);
  mapView.padding = mapInsets;
  // [END maps_ios_map_objects_insets]
}

@end
