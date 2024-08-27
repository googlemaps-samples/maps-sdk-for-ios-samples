/*
 * Copyright 2020 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/Samples/StopoverViewController.h"

#import <CoreLocation/CoreLocation.h>

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif
#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoStringUtils.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoSwitch.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoUtilities.h"

/** The origin coordinations of demos. */
static const CLLocationCoordinate2D kSingaporeTunnelOriginCoord1 = {1.295720, 103.848683};
static const CLLocationCoordinate2D kSingaporeTunnelOriginCoord2 = {1.298818, 103.877174};
static const CLLocationCoordinate2D kJarkadaHighwayOriginCoord = {-6.126155, 106.849174};
static const CLLocationCoordinate2D kManilaHighwayOriginCoord = {14.502297, 121.0351525};

/** The destination coordinations of demos. */
static const CLLocationCoordinate2D kSingaporeTunnelDestCoord1 = {1.297535, 103.846630};
static const CLLocationCoordinate2D kSingaporeTunnelDestCoord2 = {1.302525, 103.878126};
static const CLLocationCoordinate2D kJarkadaHighwayDestCoord = {-6.122432, 106.859372};
static const CLLocationCoordinate2D kManilaHighwayDestCoord = {14.503486, 121.036674};

@implementation StopoverViewController {
  BOOL _vehicleStopover;
  NSInteger _travelID;
  GMSMapView *_mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _mapView = [[GMSMapView alloc] init];
  _mapView.navigationEnabled = YES;
  _mapView.cameraMode = GMSNavigationCameraModeFollowing;
  _mapView.travelMode = GMSNavigationTravelModeDriving;
  [self.mainStackView addArrangedSubview:_mapView];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.295720
                                                          longitude:103.848683
                                                               zoom:13];
  UIStackView *controls = self.controls;
  _mapView.camera = camera;
  _mapView.settings.recenterButtonEnabled = YES;
  [_mapView.locationSimulator simulateLocationAtCoordinate:kSingaporeTunnelOriginCoord1];
  [self.mainStackView addArrangedSubview:controls];

  // Add a button to request the route.
  UIButton *requestRouteButton =
      GMSNavigationCreateButton(self, @selector(requestRoute), @"Request route");
  [controls addArrangedSubview:requestRouteButton];

  // Add a button to clear the destination.
  UIButton *clearDestinationButton =
      GMSNavigationCreateButton(self, @selector(clearDestination), @"Clear destination");
  [controls addArrangedSubview:clearDestinationButton];

  // Add a stopover switch.
  UIView *stopoverSwitch = [NavDemoSwitch switchWithLabel:@"Vehicle Stopover"
                                                   target:self
                                                 selector:@selector(updateVehicleStopover:)];
  [controls addArrangedSubview:stopoverSwitch];

  // Add segmented controls to Travel ID.
  UISegmentedControl *travelIDControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateTravelID:), @[ @"Tunnel 1", @"Tunnel 2", @"Freeway 1", @"Freeway 2" ]);
  [controls addArrangedSubview:travelIDControl];
}

- (void)requestRoute {
  NSArray<GMSNavigationWaypoint *> *waypoints = [self createDestinationWaypoints];
  [_mapView.navigator clearDestinations];
  __weak StopoverViewController *weakSelf = self;
  GMSRouteStatusCallback callback = ^(GMSRouteStatus routeStatus) {
    [weakSelf handleRouteCallbackWithStatus:routeStatus];
  };
  [_mapView.navigator setDestinations:waypoints callback:callback];
}

/** Returns a list of destination waypoints based on the currently selected destination type. */
- (NSArray<GMSNavigationWaypoint *> *)createDestinationWaypoints {
  NSMutableArray<GMSNavigationMutableWaypoint *> *waypoints = [NSMutableArray array];
  switch (_travelID) {
    case 0: {
      GMSNavigationMutableWaypoint *waypoint =
          [[GMSNavigationMutableWaypoint alloc] initWithLocation:kSingaporeTunnelDestCoord1
                                                           title:@"Case 1 destination"];
      if (waypoint) {
        waypoint.vehicleStopover = _vehicleStopover;
        [waypoints addObject:waypoint];
      }
    } break;
    case 1: {
      GMSNavigationMutableWaypoint *waypoint =
          [[GMSNavigationMutableWaypoint alloc] initWithLocation:kSingaporeTunnelDestCoord2
                                                           title:@"Case 2 destination"];
      if (waypoint) {
        waypoint.vehicleStopover = _vehicleStopover;
        [waypoints addObject:waypoint];
      }
    } break;
    case 2: {
      GMSNavigationMutableWaypoint *waypoint =
          [[GMSNavigationMutableWaypoint alloc] initWithLocation:kJarkadaHighwayDestCoord
                                                           title:@"Case 3 destination"];
      if (waypoint) {
        waypoint.vehicleStopover = _vehicleStopover;
        [waypoints addObject:waypoint];
      }
    } break;
    case 3: {
      GMSNavigationMutableWaypoint *waypoint =
          [[GMSNavigationMutableWaypoint alloc] initWithLocation:kManilaHighwayDestCoord
                                                           title:@"Case 4 destination"];
      if (waypoint) {
        waypoint.vehicleStopover = _vehicleStopover;
        [waypoints addObject:waypoint];
      }
    } break;
  }
  return waypoints;
}

- (void)handleRouteCallbackWithStatus:(GMSRouteStatus)routeStatus {
  if (routeStatus != GMSRouteStatusOK) {
    // Show an error dialog to describe the failure.
    GMSNavigationPresentAlertController(self, GMSNavigationDemoMessageForRouteStatus(routeStatus),
                                        @"Route failed", @"OK");
  }
}

- (void)clearDestination {
  _mapView.navigator.guidanceActive = NO;
  [_mapView.navigator clearDestinations];
}

- (void)updateVehicleStopover:(NavDemoSwitch *)sender {
  _vehicleStopover = sender.on;
}

- (void)updateTravelID:(UISegmentedControl *)sender {
  _travelID = sender.selectedSegmentIndex;
  [self simulateToStartLocation];
}

- (void)simulateToStartLocation {
  CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
  switch (_travelID) {
    case 0:
      coordinate = kSingaporeTunnelOriginCoord1;
      break;
    case 1:
      coordinate = kSingaporeTunnelOriginCoord2;
      break;
    case 2:
      coordinate = kJarkadaHighwayOriginCoord;
      break;
    case 3:
      coordinate = kManilaHighwayOriginCoord;
      break;
  }

  if (CLLocationCoordinate2DIsValid(coordinate)) {
    [_mapView.locationSimulator simulateLocationAtCoordinate:coordinate];
  }
}
@end
