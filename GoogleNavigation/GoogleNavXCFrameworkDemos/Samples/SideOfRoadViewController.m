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

#import "GoogleNavXCFrameworkDemos/Samples/SideOfRoadViewController.h"

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
#import "GoogleNavXCFrameworkDemos/Samples/DirectionsListViewController.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoStringUtils.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoUtilities.h"

@implementation SideOfRoadViewController {
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
  UIStackView *controls = self.controls;
  [self.mainStackView addArrangedSubview:controls];

  // Add a button to request the route.
  UIButton *requestRouteButton =
      GMSNavigationCreateButton(self, @selector(requestRoute), @"Request route");
  [controls addArrangedSubview:requestRouteButton];

  // Add segmented controls to Travel ID.
  UISegmentedControl *travelIDControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateTravelID:),
      @[ @"Normal 1", @"Normal 2", @"Intersection", @"Multi_waypoint" ]);
  [controls addArrangedSubview:travelIDControl];

  // Add a button to provide the direction list.
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Direction"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(didTapDirectionsListButton:)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didTapDirectionsListButton:(id)sender {
  GMSNavigator *navigator = _mapView.navigator;
  if (navigator) {
    GMSNavigationDirectionsListController *directionsListController =
        [[GMSNavigationDirectionsListController alloc] initWithNavigator:navigator];
    DirectionsListViewController *viewController = [[DirectionsListViewController alloc] init];
    viewController.directionsListController = directionsListController;
    [self.navigationController pushViewController:viewController animated:YES];
  }
}

/** Starts guidance and starts simulating travel along the route. */
- (void)startGuidance {
  _mapView.cameraMode = GMSNavigationCameraModeOverview;
  _mapView.navigator.guidanceActive = YES;
  [_mapView.locationSimulator simulateLocationsAlongExistingRoute];
  _mapView.locationSimulator.paused = NO;
}

/** Requests a route with the selected destination type, travel mode and options. */
- (void)requestRoute {
  // Simulate at a fixed location near GWC1 so the behaviour of this demo is consistent.
  [_mapView.locationSimulator
      simulateLocationAtCoordinate:CLLocationCoordinate2DMake(37.423620, -122.091703)];
  NSArray<GMSNavigationWaypoint *> *waypoints = [self createDestinationWaypoints];
  [_mapView.navigator clearDestinations];
  __weak SideOfRoadViewController *weakSelf = self;
  GMSRouteStatusCallback callback = ^(GMSRouteStatus routeStatus) {
    [weakSelf handleRouteCallbackWithStatus:routeStatus];
  };
  [_mapView.navigator setDestinations:waypoints callback:callback];
}

/** Returns a list of destimation waypoints based on the currently selected destination type. */
- (NSArray<GMSNavigationWaypoint *> *)createDestinationWaypoints {
  NSMutableArray *waypoints = [NSMutableArray array];
  switch (_travelID) {
    case 0: {
      GMSNavigationWaypoint *waypoint = [[GMSNavigationWaypoint alloc]
              initWithLocation:CLLocationCoordinate2DMake(37.3671671, -122.0957)
                         title:@"Normal case 1"
          preferSameSideOfRoad:YES];
      if (waypoint) {
        [waypoints addObject:waypoint];
      }
    } break;
    case 1: {
      GMSNavigationWaypoint *waypoint = [[GMSNavigationWaypoint alloc]
              initWithLocation:CLLocationCoordinate2DMake(37.3671671, -122.09639)
                         title:@"Normal case 2"
          preferSameSideOfRoad:YES];
      if (waypoint) {
        [waypoints addObject:waypoint];
      }
    } break;
    case 2: {
      GMSNavigationWaypoint *waypoint = [[GMSNavigationWaypoint alloc]
                 initWithLocation:CLLocationCoordinate2DMake(37.396788, -122.114264)
                            title:@"Intersection"
          preferredSegmentHeading:270];
      if (waypoint) {
        [waypoints addObject:waypoint];
      }
    } break;
    case 3: {
      GMSNavigationWaypoint *waypoint1 = [[GMSNavigationWaypoint alloc]
              initWithLocation:CLLocationCoordinate2DMake(37.417399, -122.078371)
                         title:@"Multi-wayoint 1"
          preferSameSideOfRoad:YES];
      if (waypoint1) {
        [waypoints addObject:waypoint1];
      }
      GMSNavigationWaypoint *waypoint2 = [[GMSNavigationWaypoint alloc]
              initWithLocation:CLLocationCoordinate2DMake(37.407739, -122.094243)
                         title:@"Multi-waypoint 2"
          preferSameSideOfRoad:YES];
      if (waypoint2) {
        [waypoints addObject:waypoint2];
      }
      GMSNavigationWaypoint *waypoint3 = [[GMSNavigationWaypoint alloc]
              initWithLocation:CLLocationCoordinate2DMake(37.397747, -122.095886)
                         title:@"Multi-waypoint 3"
          preferSameSideOfRoad:YES];
      if (waypoint3) {
        [waypoints addObject:waypoint3];
      }

    } break;
  }
  return waypoints;
}

/** Handles a route response with the given success or failure status. */
- (void)handleRouteCallbackWithStatus:(GMSRouteStatus)routeStatus {
  if (routeStatus == GMSRouteStatusOK) {
    [self startGuidance];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  } else {
    // Show an error dialog to describe the failure.
    GMSNavigationPresentAlertController(self, GMSNavigationDemoMessageForRouteStatus(routeStatus),
                                        @"Route failed", @"OK");
  }
}

/** Updates the travel ID. */
- (void)updateTravelID:(UISegmentedControl *)sender {
  _travelID = sender.selectedSegmentIndex;
}
@end
