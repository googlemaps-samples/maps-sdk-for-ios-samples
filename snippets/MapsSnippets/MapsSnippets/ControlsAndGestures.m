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


#import "ControlsAndGestures.h"
@import GoogleMaps;

@interface ControlsAndGestures ()

@end

@implementation ControlsAndGestures

// [START maps_ios_controls_and_gestures_map]
- (void)loadView {
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                          longitude:103.848
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.settings.scrollGestures = NO;
  mapView.settings.zoomGestures = NO;
  self.view = mapView;
}
// [END maps_ios_controls_and_gestures_map]

- (void)viewDidLoad {
  [super viewDidLoad];

  // [START maps_ios_controls_and_gestures_compass]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.757815
                                                          longitude:-122.50764
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.settings.compassButton = YES;
  // [END maps_ios_controls_and_gestures_compass]

  // [START maps_ios_controls_and_gestures_my_location]
  mapView.settings.myLocationButton = YES;
  // [END maps_ios_controls_and_gestures_my_location]

  // [START maps_ios_controls_and_gestures_floor_picker]
  mapView.settings.indoorPicker = NO;
  // [END maps_ios_controls_and_gestures_floor_picker]
}

@end
