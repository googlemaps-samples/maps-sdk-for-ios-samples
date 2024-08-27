/*
 * Copyright 2017 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/Samples/RoutingOptionsViewController.h"

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

static const double kMetersPerMile = 1609.34;

/* Accessibility identifier for the scroll view that contains the controls at the bottom. */
static NSString *const kControlsScrollViewIdentifier = @"ControlsScrollView";

/** The type of destination(s) that will be used to request the route. */
typedef NS_ENUM(NSInteger, DestinationType) {
  /** Custom destination waypoinds will be used.*/
  DestinationTypeCustom = 0,

  /** A single coordinate destination waypoint will be used. */
  DestinationTypeCoordinate,

  /** A single PlaceID destination waypoint will be used. */
  DestinationTypePlaceID,

  /** Multiple destination waypoints will be used. */
  DestinationTypeMultiple,
};

/** Helper function to deal with the nullable initializer of GMSNavigationWaypoint. */
static void AddWaypoint(NSMutableArray<GMSNavigationWaypoint *> *waypoints,
                        GMSNavigationWaypoint *_Nullable maybeWaypoint) {
  if (maybeWaypoint) {
    GMSNavigationWaypoint *waypoint = maybeWaypoint;
    [waypoints addObject:waypoint];
  }
}

/** Creates a test location-based waypoint. */
static GMSNavigationWaypoint *_Nullable CreateLocationWaypoint() {
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.1013611111, -122.2551666667);
  NSString *title = @"United Financial Processing Group, Inc.";
  return [[GMSNavigationWaypoint alloc] initWithLocation:coordinate title:title];
}

/** Creates a test place-ID-based waypoint. */
static GMSNavigationWaypoint *_Nullable CreatePlaceWaypoint() {
  return [[GMSNavigationWaypoint alloc] initWithPlaceID:@"ChIJrXBqznMrm4ARMkLvKBKQYKQ"
                                                  title:@"Sacramento Airport"];
}

/** Returns a list of waypoints based on the currently selected destination type. */
static NSArray<GMSNavigationWaypoint *> *_Nullable CreateWaypoints(
    DestinationType destinationType) {
  NSMutableArray<GMSNavigationWaypoint *> *waypoints =
      [NSMutableArray<GMSNavigationWaypoint *> array];

  switch (destinationType) {
    case DestinationTypeCustom:
      return nil;
      break;
    case DestinationTypeCoordinate:
      AddWaypoint(waypoints, CreateLocationWaypoint());
      break;
    case DestinationTypePlaceID:
      AddWaypoint(waypoints, CreatePlaceWaypoint());
      break;
    case DestinationTypeMultiple:
      AddWaypoint(waypoints, CreateLocationWaypoint());
      AddWaypoint(waypoints, CreatePlaceWaypoint());
      break;
  }
  return waypoints;
}

@interface RoutingOptionsViewController () <GMSNavigatorListener,
                                            GMSRoadSnappedLocationProviderListener,
                                            GMSMapViewDelegate>

@end

@implementation RoutingOptionsViewController {
  DestinationType _destinationType;
  UILabel *_distanceTimeLabel;
  UILabel *_roadSnappedLocationLabel;
  UILabel *_routeInstructionLabel;
  UIButton *_continueToNextWaypointButton;
  NSMutableArray<GMSNavigationWaypoint *> *_waypoints;
  BOOL _isCustomRoutes;
  GMSNavigationMutableRoutingOptions *_routingOptions;
  UITextField *_targetDistanceTextField;
  GMSMapView *_mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIStackView *controls = self.controls;
  _mapView = [[GMSMapView alloc] init];
  _mapView.navigationEnabled = YES;
  _mapView.cameraMode = GMSNavigationCameraModeFollowing;
  _mapView.travelMode = GMSNavigationTravelModeDriving;
  [self.mainStackView addArrangedSubview:_mapView];
  _mapView.delegate = self;
  [_mapView.navigator addListener:self];
  _mapView.navigator.voiceGuidance = GMSNavigationVoiceGuidanceAlertsAndGuidance;
  _mapView.settings.compassButton = YES;
  _mapView.locationSimulator.speedMultiplier = 5.0f;
  [_mapView.roadSnappedLocationProvider addListener:self];
  [_mapView.roadSnappedLocationProvider startUpdatingLocation];
  _isCustomRoutes = YES;
  _routingOptions = [[GMSNavigationMutableRoutingOptions alloc]
      initWithRoutingStrategy:GMSNavigationRoutingStrategyDefaultBest];

  // Add a scroll view to contain the controls.
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.accessibilityIdentifier = kControlsScrollViewIdentifier;
  [self.mainStackView addArrangedSubview:scrollView];
  [scrollView.heightAnchor constraintEqualToConstant:240.f].active = YES;
  [scrollView addSubview:controls];

  // Constrain the width of the controls to the main view to enforce vertical scrolling.
  [controls.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
  [controls.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

  // Constrain the controls to be positioned vertically inside the scroll view.
  [controls.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
  [controls.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor].active = YES;

  // Add each of the controls to the container view.
  [self addControls];

  // Simulate at a fixed location near Stanford University so the behaviour of this demo is
  // consistent.
  [_mapView.locationSimulator
      simulateLocationAtCoordinate:CLLocationCoordinate2DMake(37.436367, -122.167312)];
  _waypoints = [NSMutableArray array];
}

#pragma mark - Private

/** Creates the UI controls and adds them to the controls container. */
- (void)addControls {
  UIStackView *controls = self.controls;

  // Add buttons to request and clear routes.
  _routeInstructionLabel =
      GMSNavigationCreateLabelWithText(@"Tap the map to add a custom destination.");
  [controls addArrangedSubview:_routeInstructionLabel];
  UIStackView *routeControls = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:routeControls];
  [routeControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(requestRoute),
                                                              @"Request route")];
  [routeControls
      addArrangedSubview:GMSNavigationCreateButton(self, @selector(clearRoute), @"Clear route")];

  // Add buttons to start and stop guidance.
  UIStackView *guidanceControls = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:guidanceControls];
  [guidanceControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(startGuidance),
                                                                 @"Start guidance")];
  [guidanceControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(stopGuidance),
                                                                 @"Stop guidance")];

  // Add button to go to next waypoint.
  _continueToNextWaypointButton = GMSNavigationCreateButton(
      self, @selector(continueToNextDestination), @"Continue to next waypoint");
  [_continueToNextWaypointButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  [_continueToNextWaypointButton setTitleColor:UIColor.lightTextColor
                                      forState:UIControlStateDisabled];
  [controls addArrangedSubview:_continueToNextWaypointButton];

  // Add buttons to start and stop simulation of travel along the route.
  UIStackView *simulationControls = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:simulationControls];
  [simulationControls
      addArrangedSubview:GMSNavigationCreateButton(self, @selector(simulateCurrentRoute),
                                                   @"Start simulating")];
  [simulationControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(stopSimulation),
                                                                   @"Stop simulating")];

  // Add segmented controls to select the type of destinations.
  UILabel *destinationTypeLabel = GMSNavigationCreateLabelWithText(@"Destination Type");
  [controls addArrangedSubview:destinationTypeLabel];
  UISegmentedControl *destinationTypeSegmentedControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateDestinationType:), @[ @"Custom", @"Coordinate", @"PlaceID", @"Multi" ]);
  [controls addArrangedSubview:destinationTypeSegmentedControl];

  // Add segmented controls to select the travel mode.
  UILabel *travelModeLabel = GMSNavigationCreateLabelWithText(@"Travel Mode");
  [controls addArrangedSubview:travelModeLabel];
  UISegmentedControl *travelModeSegmentedControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateTravelMode:), @[ @"Driving", @"Cycling", @"Walking" ]);
  [controls addArrangedSubview:travelModeSegmentedControl];

  // Add an avoid highways switch.
  NavDemoSwitch *avoidHighwaysSwitch =
      [NavDemoSwitch switchWithLabel:@"Avoid highways"
                              target:self
                            selector:@selector(updateAvoidsHighways:)];
  [controls addArrangedSubview:avoidHighwaysSwitch];

  // Add an avoid tolls switch.
  NavDemoSwitch *avoidTollsSwitch = [NavDemoSwitch switchWithLabel:@"Avoid tolls"
                                                            target:self
                                                          selector:@selector(updateAvoidsTolls:)];
  [controls addArrangedSubview:avoidTollsSwitch];

  // Add segmented controls to select the routing strategy.
  UILabel *routingStrategyLabel = GMSNavigationCreateLabelWithText(@"Routing Strategy");
  [controls addArrangedSubview:routingStrategyLabel];
  UISegmentedControl *routingStrategySegmentedControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateRoutingStrategy:), @[ @"Default", @"Shorter", @"Target Distance" ]);
  [controls addArrangedSubview:routingStrategySegmentedControl];

  // Create text field for delta target distance.
  _targetDistanceTextField = [[UITextField alloc] init];
  _targetDistanceTextField.placeholder = @"Target Distance (mi)";
  _targetDistanceTextField.keyboardType = UIKeyboardTypeNumberPad;
  _targetDistanceTextField.hidden = YES;
  [_targetDistanceTextField createDoneCancelToolBar];
  [controls addArrangedSubview:_targetDistanceTextField];

  // Add segmented controls to select the alternate routes strategy.
  UILabel *alternateRoutesLabel = GMSNavigationCreateLabelWithText(@"Alternate Routes Strategy");
  [controls addArrangedSubview:alternateRoutesLabel];
  UISegmentedControl *alternateRoutesSegmentedControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updateAlternateRoutesStrategy:), @[ @"All", @"None", @"One" ]);
  [controls addArrangedSubview:alternateRoutesSegmentedControl];

  // Add route and location information labels.
  _distanceTimeLabel = GMSNavigationCreateLabelWithText(@"");
  [self updateTimesAndDistances];
  [controls addArrangedSubview:_distanceTimeLabel];
  _roadSnappedLocationLabel = GMSNavigationCreateLabelWithText(@"ROAD-SNAPPED LOCATION\n");
  [controls addArrangedSubview:_roadSnappedLocationLabel];
}

/** Requests a route with the selected destination type, travel mode and options. */
- (void)requestRoute {
  if ((_destinationType != DestinationTypeCustom) && !_waypoints.count) {
    NSArray<GMSNavigationWaypoint *> *waypoints = CreateWaypoints(_destinationType);
    if (waypoints) {
      [_waypoints addObjectsFromArray:waypoints];
    }
  }
  [_mapView clear];
  [_mapView.navigator clearDestinations];
  if (_routingOptions.routingStrategy == GMSNavigationRoutingStrategyDeltaToTargetDistance &&
      !_targetDistanceTextField.isHidden) {
    double distance =
        ((_targetDistanceTextField.text ? [_targetDistanceTextField.text doubleValue] : 0) *
         kMetersPerMile);
    NSArray<NSNumber *> *temp = @[ @(distance) ];
    _routingOptions.targetDistancesMeters = temp;
  }
  __weak RoutingOptionsViewController *weakSelf = self;
  GMSRouteStatusCallback callback = ^(GMSRouteStatus routeStatus) {
    [weakSelf handleRouteCallbackWithStatus:routeStatus];
  };
  _continueToNextWaypointButton.enabled = NO;
  [_mapView.navigator setDestinations:_waypoints routingOptions:_routingOptions callback:callback];
}

/** Handles a route response with the given success or failure status. */
- (void)handleRouteCallbackWithStatus:(GMSRouteStatus)routeStatus {
  if (routeStatus == GMSRouteStatusOK) {
    _mapView.cameraMode = GMSNavigationCameraModeOverview;
  } else {
    // Show an error dialog to describe the failure.
    GMSNavigationPresentAlertController(self, GMSNavigationDemoMessageForRouteStatus(routeStatus),
                                        @"Route failed", @"OK");
  }
  _continueToNextWaypointButton.enabled = (_waypoints.count > 1);
}

/** Updates the destination type. */
- (void)updateDestinationType:(UISegmentedControl *)sender {
  _routeInstructionLabel.text = sender.selectedSegmentIndex == 0
                                    ? @"Tap the map to add a custom destination."
                                    : @"Tap \"Request Route\" for a preset destination.";
  _isCustomRoutes = sender.selectedSegmentIndex == 0 ? YES : NO;
  _destinationType = (DestinationType)(sender.selectedSegmentIndex);
  [_waypoints removeAllObjects];
}

/** Updates the travel mode. */
- (void)updateTravelMode:(UISegmentedControl *)sender {
  _mapView.travelMode = (GMSNavigationTravelMode)sender.selectedSegmentIndex;
}

/** Updates the routing strategy. */
- (void)updateRoutingStrategy:(UISegmentedControl *)sender {
  GMSNavigationRoutingStrategy newRoutingStrategy =
      (GMSNavigationRoutingStrategy)(sender.selectedSegmentIndex);
  if (_routingOptions.routingStrategy == GMSNavigationRoutingStrategyDeltaToTargetDistance ||
      newRoutingStrategy == GMSNavigationRoutingStrategyDeltaToTargetDistance) {
    [UIView animateWithDuration:0.3
                     animations:^{
                       _targetDistanceTextField.hidden =
                           newRoutingStrategy != GMSNavigationRoutingStrategyDeltaToTargetDistance;
                     }];
  }
  _routingOptions.routingStrategy = newRoutingStrategy;
}

/** Updates the alternate routes strategy. */
- (void)updateAlternateRoutesStrategy:(UISegmentedControl *)sender {
  _routingOptions.alternateRoutesStrategy =
      (GMSNavigationAlternateRoutesStrategy)sender.selectedSegmentIndex;
}

/** Updates the 'avoid highways' setting. */
- (void)updateAvoidsHighways:(NavDemoSwitch *)sender {
  _mapView.navigator.avoidsHighways = sender.on;
}

/** Updates the 'avoid tolls' setting. */
- (void)updateAvoidsTolls:(NavDemoSwitch *)sender {
  _mapView.navigator.avoidsTolls = sender.on;
}

/** Clears the current route if one is loaded. */
- (void)clearRoute {
  [_mapView.navigator clearDestinations];
  [_mapView clear];
  [_waypoints removeAllObjects];
}

/** Starts guidance. */
- (void)startGuidance {
  _mapView.navigator.guidanceActive = YES;
}

/** Stops guidance. */
- (void)stopGuidance {
  _mapView.navigator.guidanceActive = NO;
}

/** Continues to the next destination in a multi-waypoint route. */
- (void)continueToNextDestination {
  if (!_waypoints.count) {
    return;
  }
  [_waypoints removeObjectAtIndex:0];

  [self requestRoute];
}

/** Starts simulating along the current route. */
- (void)simulateCurrentRoute {
  [_mapView.locationSimulator simulateLocationsAlongExistingRoute];
}

/** Stops the simulation, returning the user location marker to the GPS-reported location. */
- (void)stopSimulation {
  [_mapView.locationSimulator stopSimulation];
}

/**
 * Formats the time and distance to each waypoint as text and displays it in the appropriate label.
 */
- (void)updateTimesAndDistances {
  NSMutableArray<NSString *> *timesAndDistances = [[NSMutableArray alloc] init];
  for (GMSNavigationWaypoint *waypoint in _waypoints) {
    NSTimeInterval time = [_mapView.navigator timeToWaypoint:waypoint];
    CLLocationDistance distance = [_mapView.navigator distanceToWaypoint:waypoint];
    if (time != CLTimeIntervalMax && distance != CLLocationDistanceMax) {
      NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
      NSString *timeString = [dateComponentsFormatter stringFromTimeInterval:time];
      [timesAndDistances
          addObject:[NSString stringWithFormat:@"%@\n  time:%@ dist:%.1fm", waypoint.title,
                                               timeString, distance]];
    } else {
      [timesAndDistances addObject:[NSString stringWithFormat:@"%@: unavailable.", waypoint.title]];
    }
  }
  NSString *timesAndDistancesText = [timesAndDistances componentsJoinedByString:@"\n"];
  _distanceTimeLabel.text =
      [NSString stringWithFormat:@"TIMES AND DISTANCES\n%@", timesAndDistancesText];
}

#pragma mark GMSMapViewDelegate

/**
 * Adds a marker at the coordinate tapped by the user. Locations are then added to the _waypoints
 * array. These waypoints will be used when creating routes.
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  if (_isCustomRoutes) {
    GMSNavigationWaypoint *newWaypoint =
        [[GMSNavigationWaypoint alloc] initWithLocation:coordinate title:@"Custom Waypoint"];
    if (newWaypoint) {
      [_waypoints addObject:newWaypoint];
      GMSMarker *newWaypointMarker = [GMSMarker markerWithPosition:coordinate];
      newWaypointMarker.title = @"Custom Waypoint";
      newWaypointMarker.map = mapView;
    }
  }
}

#pragma mark GMSRoadSnappedLocationProviderListener

- (void)locationProvider:(GMSRoadSnappedLocationProvider *)locationProvider
       didUpdateLocation:(nonnull CLLocation *)location {
  // Format the road-snapped location as text and display it in the appropriate label.
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  dateFormat.dateFormat = @"YYYY-MM-dd\'  \'HH:mm:ss";
  NSString *dateString = [dateFormat stringFromDate:location.timestamp];
  NSString *locationText = [NSString
      stringWithFormat:
          @"ROAD-SNAPPED LOCATION\n"
          @"Lat: %f\rLng: %f\rAlt: %f\rhAcc: %f\rvAcc: %f\rCourse: %f\rSpeed: %f\rhTime: %@",
          location.coordinate.latitude, location.coordinate.longitude, location.altitude,
          location.horizontalAccuracy, location.verticalAccuracy, location.course, location.speed,
          dateString];
  _roadSnappedLocationLabel.text = locationText;
}

#pragma mark GMSNavigatorListener

- (void)navigator:(GMSNavigator *)navigator didUpdateRemainingTime:(NSTimeInterval)time {
  [self updateTimesAndDistances];
}

- (void)navigator:(GMSNavigator *)navigator
    didUpdateRemainingDistance:(CLLocationDistance)distance {
  [self updateTimesAndDistances];
}

@end
