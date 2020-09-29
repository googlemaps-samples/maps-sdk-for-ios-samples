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


// [START maps_ios_map_styling_json_file]
#import "MapStyling.h"
@import GoogleMaps;

@interface MapStyling ()

@end

@implementation MapStyling

// Set the status bar style to complement night-mode.
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)loadView {
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                          longitude:151.20
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.myLocationEnabled = YES;

  NSBundle *mainBundle = [NSBundle mainBundle];
  NSURL *styleUrl = [mainBundle URLForResource:@"style" withExtension:@"json"];
  NSError *error;

  // Set the map style by passing the URL for style.json.
  GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];

  if (!style) {
    NSLog(@"The style definition could not be loaded: %@", error);
  }

  mapView.mapStyle = style;
  self.view = mapView;
}

@end
// [END maps_ios_map_styling_json_file]

@interface MapStylingStringResource : UIViewController

@end

// [START maps_ios_map_styling_string_resource]
@implementation MapStylingStringResource

// Paste the JSON string to use.
static NSString *const kMapStyle = @"JSON_STYLE_GOES_HERE";

// Set the status bar style to complement night-mode.
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)loadView {
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                          longitude:151.20
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.myLocationEnabled = YES;

  NSError *error;

  // Set the map style by passing a valid JSON string.
  GMSMapStyle *style = [GMSMapStyle styleWithJSONString:kMapStyle error:&error];

  if (!style) {
    NSLog(@"The style definition could not be loaded: %@", error);
  }

  mapView.mapStyle = style;
  self.view = mapView;
}

@end
// [END maps_ios_map_styling_string_resource]
