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


#import "Markers.h"
// [START maps_ios_markers_icon_view]
@import CoreLocation;
@import GoogleMaps;

@interface MarkerViewController : UIViewController <GMSMapViewDelegate>
@property (strong, nonatomic) GMSMapView *mapView;
@end

@implementation MarkerViewController {
  GMSMarker *_london;
  UIImageView *_londonView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:51.5
                                                          longitude:-0.127
                                                               zoom:14];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = _mapView;

  _mapView.delegate = self;

  UIImage *house = [UIImage imageNamed:@"House"];
  house = [house imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  _londonView = [[UIImageView alloc] initWithImage:house];
  _londonView.tintColor = [UIColor redColor];

  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(51.5, -0.127);
  _london = [GMSMarker markerWithPosition:position];
  _london.title = @"London";
  _london.iconView = _londonView;
  _london.tracksViewChanges = YES;
  _london.map = self.mapView;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
  [UIView animateWithDuration:5.0
                   animations:^{
    self->_londonView.tintColor = [UIColor blueColor];
  }
                   completion:^(BOOL finished) {
    // Stop tracking view changes to allow CPU to idle.
    self->_london.tracksViewChanges = NO;
  }];
}

@end
// [END maps_ios_markers_icon_view]

@implementation Markers

GMSMapView *mapView;

- (void)addMarker {
  // [START maps_ios_markers_add_marker]
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(10, 10);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  marker.title = @"Hello World";
  marker.map = mapView;
  // [END maps_ios_markers_add_marker]
}

- (void)removeMarker {
  // [START maps_ios_markers_remove_marker]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683
                                                          longitude:151.2086
                                                               zoom:6];
  mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  // ...
  [mapView clear];
  // [END maps_ios_markers_remove_marker]

  // [START maps_ios_markers_remove_marker_modifications]
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(10, 10);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  marker.map = mapView;
  // ...
  marker.map = nil;
  // [END maps_ios_markers_remove_marker_modifications]

  // [START maps_ios_markers_customize_marker_color]
  marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
  // [END maps_ios_markers_customize_marker_color]

  // [START maps_ios_markers_customize_marker_image]
  CLLocationCoordinate2D positionLondon = CLLocationCoordinate2DMake(51.5, -0.127);
  GMSMarker *london = [GMSMarker markerWithPosition:positionLondon];
  london.title = @"London";
  london.icon = [UIImage imageNamed:@"house"];
  london.map = mapView;
  // [END maps_ios_markers_customize_marker_image]

  // [START maps_ios_markers_opacity]
  marker.opacity = 0.6;
  // [END maps_ios_markers_opacity]
}

- (void)moreCustomizations {
  // [START maps_ios_markers_flatten]
  CLLocationCoordinate2D positionLondon = CLLocationCoordinate2DMake(51.5, -0.127);
  GMSMarker *londonMarker = [GMSMarker markerWithPosition:positionLondon];
  londonMarker.flat = YES;
  londonMarker.map = mapView;
  // [END maps_ios_markers_flatten]

  // [START maps_ios_markers_rotate]
  CLLocationDegrees degrees = 90;
  londonMarker.groundAnchor = CGPointMake(0.5, 0.5);
  londonMarker.rotation = degrees;
  londonMarker.map = mapView;
  // [END maps_ios_markers_rotate]
}

- (void)infoWindow {
  // [START maps_ios_markers_info_window_title]
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(51.5, -0.127);
  GMSMarker *london = [GMSMarker markerWithPosition:position];
  london.title = @"London";
  london.map = mapView;
  // [END maps_ios_markers_info_window_title]

  // [START maps_ios_markers_info_window_title_and_snippet]
  london.title = @"London";
  london.snippet = @"Population: 8,174,100";
  london.map = mapView;
  // [END maps_ios_markers_info_window_title_and_snippet]

  // [START maps_ios_markers_info_window_changes]
  london.tracksInfoWindowChanges = YES;
  // [END maps_ios_markers_info_window_changes]

  // [START maps_ios_markers_info_window_change_position]
  london.infoWindowAnchor = CGPointMake(0.5, 0.5);
  london.icon = [UIImage imageNamed:@"house"];
  london.map = mapView;
  // [END maps_ios_markers_info_window_change_position]
}

@end
