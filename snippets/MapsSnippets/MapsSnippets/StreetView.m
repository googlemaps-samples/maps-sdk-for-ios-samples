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

// [START maps_ios_streetview_add]
#import "StreetView.h"
@import GoogleMaps;

@interface StreetView ()

@end

@implementation StreetView

- (void)loadView {
  GMSPanoramaView *panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
  self.view = panoView;

  [panoView moveNearCoordinate:CLLocationCoordinate2DMake(-33.732, 150.312)];
}

@end
// [END maps_ios_streetview_add]

@interface StreetViewExt : NSObject

@end

@implementation StreetViewExt

GMSPanoramaView *panoView;
GMSMapView *mapView;

- (void)extras {
  // [START maps_ios_streetview_gestures]
  [panoView setAllGesturesEnabled:NO];
  // [END maps_ios_streetview_gestures]

  // [START maps_ios_streetview_pov]
  panoView.camera = [GMSPanoramaCamera cameraWithHeading:180
                                                   pitch:-10
                                                    zoom:1];
  // [END maps_ios_streetview_pov]
  
  // [START maps_ios_streetview_markers]
  // Create a marker at the Eiffel Tower
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(48.858,2.294);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];

  // Add the marker to a GMSPanoramaView object named panoView
  marker.panoramaView = panoView;

  // Add the marker to a GMSMapView object named mapView
  marker.map = mapView;
  // [END maps_ios_streetview_markers]

  // [START maps_ios_streetview_marker_nil]
  marker.panoramaView = nil;
  // [END maps_ios_streetview_marker_nil]
}

@end
