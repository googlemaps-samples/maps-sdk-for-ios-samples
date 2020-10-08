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


// [START maps_ios_events_map_view_delegate]
@import GoogleMaps;

@interface Events : UIViewController <GMSMapViewDelegate>

@end
// [END maps_ios_events_map_view_delegate]

@implementation Events
// [START_EXCLUDE]
// [START maps_ios_events_map_view_did_tap_coordinate]
- (void)loadView {
  [super loadView];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                          longitude:103.848
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.delegate = self;
  self.view = mapView;
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}
// [END maps_ios_events_map_view_did_tap_coordinate]
// [START maps_ios_events_map_view_geocoder]
GMSGeocoder *geocoder;

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  [mapView clear];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
  id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
    if (error != nil) {
      return;
    }
    GMSReverseGeocodeResult *result = response.firstResult;
    GMSMarker *marker = [GMSMarker markerWithPosition:cameraPosition.target];
    marker.title = result.lines[0];
    marker.snippet = result.lines[1];
    marker.map = mapView;
  };
  [geocoder reverseGeocodeCoordinate:cameraPosition.target completionHandler:handler];
}
// [END maps_ios_events_map_view_geocoder]
// [END_EXCLUDE]
@end
