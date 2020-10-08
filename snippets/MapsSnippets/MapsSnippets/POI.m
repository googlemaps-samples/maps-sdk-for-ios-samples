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

// [START maps_ios_poi_click_event_listening]
#import "POI.h"
@import GoogleMaps;

@interface POI () <GMSMapViewDelegate>

@end

@implementation POI

- (void)loadView {
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.603
                                                            longitude:-122.331
                                                                 zoom:14];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.delegate = self;
  self.view = mapView;
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
  NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
}

@end
// [END maps_ios_poi_click_event_listening]

@interface POIInfoWindow : NSObject

@end

@implementation POIInfoWindow

// [START maps_ios_poi_info_window_details]
// Declare a GMSMarker instance at the class level.
GMSMarker *infoMarker;

// Attach an info window to the POI using the GMSMarker.
- (void)mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
  infoMarker = [GMSMarker markerWithPosition:location];
  infoMarker.snippet = placeID;
  infoMarker.title = name;
  infoMarker.opacity = 0;
  CGPoint pos = infoMarker.infoWindowAnchor;
  pos.y = 1;
  infoMarker.infoWindowAnchor = pos;
  infoMarker.map = mapView;
  mapView.selectedMarker = infoMarker;
}
// [END maps_ios_poi_info_window_details]

@end
