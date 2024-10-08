/*
 * Copyright 2016 Google LLC. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
// [START maps_ios_sample_marker_info_window]
#import "GoogleMapsDemos/Samples/MarkerInfoWindowViewController.h"

#import "GoogleMapsDemos/UIViewController+GMSToastMessages.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MarkerInfoWindowViewController () <GMSMapViewDelegate>

@end

@implementation MarkerInfoWindowViewController {
  GMSMarker *_sydneyMarker;
  GMSMarker *_melbourneMarker;
  GMSMarker *_brisbaneMarker;
  UIView *_contentView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-37.81969
                                                          longitude:144.966085
                                                               zoom:4];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  _sydneyMarker = [[GMSMarker alloc] init];
  _sydneyMarker.title = @"Sydney";
  _sydneyMarker.snippet = @"Population: 4,605,992";
  _sydneyMarker.position = CLLocationCoordinate2DMake(-33.8683, 151.2086);
  _sydneyMarker.map = mapView;
  NSLog(@"sydneyMarker: %@", _sydneyMarker);

  _melbourneMarker.map = nil;
  _melbourneMarker = [[GMSMarker alloc] init];
  _melbourneMarker.title = @"Melbourne";
  _melbourneMarker.snippet = @"Population: 4,169,103";
  _melbourneMarker.position = CLLocationCoordinate2DMake(-37.81969, 144.966085);
  _melbourneMarker.map = mapView;
  NSLog(@"melbourneMarker: %@", _melbourneMarker);

  _brisbaneMarker.map = nil;
  _brisbaneMarker = [[GMSMarker alloc] init];
  _brisbaneMarker.title = @"Brisbane";
  _brisbaneMarker.snippet = @"Population: 2,189,878";
  _brisbaneMarker.position = CLLocationCoordinate2DMake(-27.4710107, 153.0234489);
  _brisbaneMarker.map = mapView;
  NSLog(@"brisbaneMarker: %@", _brisbaneMarker);

  _contentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aeroplane"]];

  mapView.delegate = self;
  self.view = mapView;
}

#pragma mark GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
  if (marker == _sydneyMarker) {
    return _contentView;
  }
  return nil;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
  if (marker == _brisbaneMarker) {
    return _contentView;
  }
  return nil;
}

- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker {
  NSString *message =
      [NSString stringWithFormat:@"Info window for marker %@ closed.", marker.title];
  [self gms_showToastWithMessage:message];
}

- (void)mapView:(GMSMapView *)mapView didLongPressInfoWindowOfMarker:(GMSMarker *)marker {
  NSString *message =
      [NSString stringWithFormat:@"Info window for marker %@ long pressed.", marker.title];
  [self gms_showToastWithMessage:message];
}

@end
// [END maps_ios_sample_marker_info_window]
