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

#import "GoogleNavXCFrameworkDemos/Samples/NavUIOptionsViewController.h"

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

/* Accessibility identifier for the scroll view that contains the controls at the bottom. */
static NSString *const kControlsScrollViewIdentifier = @"ControlsScrollView";

/** The list of choices for map view type. */
static const GMSMapViewType kMapViewTypeChoices[] = {
    kGMSTypeNormal,
    kGMSTypeSatellite,
    kGMSTypeTerrain,
    kGMSTypeHybrid,
};

static const NSInteger kCustomCameraModeIndex = 3;

/**
 * Simple pair structure that contains a time and distance value for waypoints. This is mainly used
 * for the header accessory view and WaypointInformationView features.
 */
@interface TimeAndDistance : NSObject

@property(nonatomic, readwrite) NSTimeInterval durationSeconds;
@property(nonatomic, readwrite) CLLocationDistance distanceMeters;

@end

/**
 * WaypointInformationView is a small blue view right below the navigation header view, which is
 * activated when a route with waypoints is created, guidance started, and header accessory view is
 * turned on (in that order). This information box shows the time and distance between the current
 * position and the user created waypoints along the route.
 */
@interface WaypointInformationView : UIView <GMSNavigationAccessoryView>

/** This superclass initializer is not supported. */
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 * The information that should be displayed on the view for each waypoint. Waypoints are named
 * based on the order they come in.
 */
@property(nonatomic) NSDictionary<NSString *, TimeAndDistance *> *waypointInformation;

@end

/** The height of the control pane when it is expanded. */
static const CGFloat kControlsHeightExpanded = 200.f;

/** The font for text in the customized header. */
static NSString *const kCustomizedHeaderFont = @"BradleyHandITCTT-Bold";

/** The standard padding to use when laying out UI elements. */
static const CGFloat kStandardPadding = 8.0;

@implementation NavUIOptionsViewController {
  NSLayoutConstraint *_controlsHeightConstraint;

  /**
   * Indicates whether the map is automatically recentered 5 seconds after the last time the user
   * moved the map.
   */
  BOOL _isAutoFollowEnabled;

  /** Timer used when auto follow mode is enabled. */
  NSTimer *_autoFollowTimer;

  /** Waypoint view for accessory header. */
  WaypointInformationView *_waypointInformationView;

  /** Tapped locations on map as waypoints. */
  NSMutableArray<GMSNavigationWaypoint *> *_waypoints;

  UIButton *_continueToNextWaypointButton;

  GMSMapView *_mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _waypoints = [NSMutableArray array];

  // Add a map.
  _mapView = [[GMSMapView alloc] init];
  _mapView.navigationEnabled = YES;
  _mapView.cameraMode = GMSNavigationCameraModeFollowing;
  _mapView.travelMode = GMSNavigationTravelModeDriving;
  [self.mainStackView addArrangedSubview:_mapView];
  _mapView.settings.compassButton = YES;
  _mapView.delegate = self;
  _mapView.accessibilityElementsHidden = NO;
  [_mapView.navigator addListener:self];

  // Add the controls to the container.
  [self addControls];
}

/** Creates the UI controls and adds them to the view hierarchy. */
- (void)addControls {
  UIStackView *controls = self.controls;

  // Creates the Continue to Next Waypoint button. It is only enabled when the user arrives at a
  // waypoint.
  _continueToNextWaypointButton = GMSNavigationCreateButton(self, @selector(continueToNextWaypoint),
                                                            @"Continue to next waypoint");
  _continueToNextWaypointButton.translatesAutoresizingMaskIntoConstraints = NO;
  _continueToNextWaypointButton.backgroundColor = UIColor.systemGrayColor;
  _continueToNextWaypointButton.hidden = YES;
  [_continueToNextWaypointButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  [_continueToNextWaypointButton setTitleColor:UIColor.lightTextColor
                                      forState:UIControlStateDisabled];
  [_continueToNextWaypointButton.layer setCornerRadius:5.0];
  [_continueToNextWaypointButton setEnabled:NO];
  [_continueToNextWaypointButton
      setContentEdgeInsets:UIEdgeInsetsMake(kStandardPadding, kStandardPadding, kStandardPadding,
                                            kStandardPadding)];
  [self.view addSubview:_continueToNextWaypointButton];

  // Constrain the next waypoint button to be centered and slightly above the menu.
  UILayoutGuide *navFooterLayoutGuide = _mapView.navigationFooterLayoutGuide;
  NSLayoutConstraint *buttonBottomConstraint = [_continueToNextWaypointButton.bottomAnchor
      constraintEqualToAnchor:navFooterLayoutGuide.topAnchor
                     constant:-kStandardPadding];
  buttonBottomConstraint.priority = UILayoutPriorityDefaultHigh;
  [buttonBottomConstraint setActive:YES];
  [[_continueToNextWaypointButton.bottomAnchor
      constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor] setActive:YES];
  [[_continueToNextWaypointButton.centerXAnchor
      constraintEqualToAnchor:navFooterLayoutGuide.centerXAnchor] setActive:YES];

  // Add a scroll view to contain the controls.
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.accessibilityIdentifier = kControlsScrollViewIdentifier;
  [self.mainStackView addArrangedSubview:scrollView];
  _controlsHeightConstraint =
      [scrollView.heightAnchor constraintEqualToConstant:kControlsHeightExpanded];
  _controlsHeightConstraint.active = YES;
  [scrollView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
  [scrollView addSubview:controls];

  // Constrain controls width to the main view to enforce vertical scrolling.
  [controls.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
  [controls.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

  // Constrain controls to be positioned vertically inside the scroll view.
  [controls.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
  [controls.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor].active = YES;

  // Add buttons to request a route and clear the current route.
  UILabel *mapInstructionLabel = GMSNavigationCreateLabelWithText(@"Tap map to add waypoint.");
  [controls addArrangedSubview:mapInstructionLabel];
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

  // Add buttons to start and stop simulation.
  UIStackView *simulationControls = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:simulationControls];
  [simulationControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(startSimulation),
                                                                   @"Start simulation")];
  [simulationControls addArrangedSubview:GMSNavigationCreateButton(self, @selector(stopSimulation),
                                                                   @"Stop simulation")];

  // Add buttons to simulate prompts and traffic incident reports. */
  UIStackView *promptIncidentButtons = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:promptIncidentButtons];
  UIButton *promptButton =
      GMSNavigationCreateButton(self, @selector(simulatePrompt), @"Simulate prompt");
  [promptIncidentButtons addArrangedSubview:promptButton];
  UIButton *trafficIncidentButton =
      GMSNavigationCreateButton(self, @selector(simulateTrafficReport), @"Traffic Incident");
  [promptIncidentButtons addArrangedSubview:trafficIncidentButton];

  // Add a segmented control to select the following camera perspective.
  UILabel *cameraModeLabel = GMSNavigationCreateLabelWithText(@"Camera Mode");
  [controls addArrangedSubview:cameraModeLabel];
  UISegmentedControl *cameraModeSegmentedControl =
      GMSNavigationCreateSegmentedControl(self, @selector(cameraModeControlDidUpdate:),
                                          @[ @"Free", @"Follow", @"Overview", @"Custom" ]);
  [controls addArrangedSubview:cameraModeSegmentedControl];

  // Add a segmented control to select the following camera perspective.
  UILabel *followingPerspectiveLabel = GMSNavigationCreateLabelWithText(@"Following perspective");
  [controls addArrangedSubview:followingPerspectiveLabel];

  UISegmentedControl *perspectiveSegmentedControl = GMSNavigationCreateSegmentedControl(
      self, @selector(updatePerspective:), @[ @"Tilted", @"Top-down north", @"Top-down heading" ]);
  [controls addArrangedSubview:perspectiveSegmentedControl];

  // Add a segmented control to select the map view type.
  [controls addArrangedSubview:GMSNavigationCreateLabelWithText(@"Map View Type")];
  UISegmentedControl *mapViewTypeControl = [[UISegmentedControl alloc] init];
  [mapViewTypeControl addTarget:self
                         action:@selector(mapTypeControlDidUpdate:)
               forControlEvents:UIControlEventValueChanged];
  NSUInteger mapViewTypeChoiceCount = sizeof(kMapViewTypeChoices) / sizeof(GMSMapViewType);
  for (NSUInteger i = 0; i < mapViewTypeChoiceCount; i++) {
    [mapViewTypeControl insertSegmentWithTitle:GMSMapViewTypeToString(kMapViewTypeChoices[i])
                                       atIndex:i
                                      animated:NO];
  }
  mapViewTypeControl.selectedSegmentIndex = 0;
  [controls addArrangedSubview:mapViewTypeControl];

  // Add a button to collapse the UI controls area to make the map occupy the full screen.
  UIButton *collapseButton =
      GMSNavigationCreateButton(self, @selector(toggleMenuCollapsed), @"Menu");
  collapseButton.translatesAutoresizingMaskIntoConstraints = NO;
  collapseButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
  [self.view addSubview:collapseButton];
  [collapseButton.heightAnchor constraintEqualToConstant:28.f].active = YES;
  [collapseButton.widthAnchor constraintEqualToConstant:70.f].active = YES;
  [collapseButton.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor].active = YES;
  [collapseButton.bottomAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;

  // Add a switch to enable and disable the auto follow mode.
  SEL autoFollowModeSelector = @selector(autoFollowModeSwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Auto follow mode"
                                                       target:self
                                                     selector:autoFollowModeSelector]];

  // Add a switch to enable and disable the customized header.
  SEL customizedHeaderSelector = @selector(customizedHeaderSwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Customized header"
                                                       target:self
                                                     selector:customizedHeaderSelector]];

  // Add a switch to enable and disable fullscreen.
  SEL fullscreenSelector = @selector(fullscreenSwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Fullscreen"
                                                       target:self
                                                     selector:fullscreenSelector]];

  // Add a switch to enable and disable the header accessory view.
  SEL accessoryViewSelector = @selector(accessoryViewSwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Header accessory view"
                                                       target:self
                                                     selector:accessoryViewSelector]];

  // Add a switch to enable and disable destination markers.
  SEL destinationMarkersSelector = @selector(destinationMarkersSwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Destination Markers"
                                                 initialState:YES
                                                       target:self
                                                     selector:destinationMarkersSelector]];

  // Add a switch to enable and disable accessibility on mapView elements.
  SEL accessibilitySwitchDidUpdate = @selector(accessibilitySwitchDidUpdate:);
  [controls addArrangedSubview:[NavDemoSwitch switchWithLabel:@"Hide accessibility elements"
                                                 initialState:NO
                                                       target:self
                                                     selector:accessibilitySwitchDidUpdate]];
}

- (void)fullscreenSwitchDidUpdate:(NavDemoSwitch *)sender {
  [self.navigationController setNavigationBarHidden:sender.on animated:YES];
}

- (void)accessoryViewSwitchDidUpdate:(NavDemoSwitch *)sender {
  if (!sender.on) {
    [_mapView setHeaderAccessoryView:nil];
  } else {
    _waypointInformationView = [[WaypointInformationView alloc] init];
    [_mapView setHeaderAccessoryView:_waypointInformationView];
    [self updateWaypointInformationView];
  }
}

/** Requests a route with the selected destination type, travel mode and options. */
- (void)requestRoute {
  NSArray<GMSNavigationWaypoint *> *waypoints = _waypoints;
  [_mapView clear];
  [_mapView.navigator clearDestinations];
  __weak NavUIOptionsViewController *weakSelf = self;
  GMSRouteStatusCallback callback = ^(GMSRouteStatus routeStatus) {
    [weakSelf handleRouteCallbackWithStatus:routeStatus];
  };
  [_mapView.navigator setDestinations:waypoints callback:callback];
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
}

/**
 * Updates the header accessory view based on the waypoints remaining and their respective
 * distances and times.
 */
- (void)updateWaypointInformationView {
  if (_waypointInformationView == nil || _mapView.navigator == nil) {
    return;
  }
  GMSNavigator *navigator = _mapView.navigator;
  NSMutableDictionary<NSString *, TimeAndDistance *> *waypointInformation =
      [[NSMutableDictionary alloc] init];
  for (GMSNavigationWaypoint *waypoint in _waypoints) {
    NSTimeInterval time = [navigator timeToWaypoint:waypoint];
    CLLocationDistance distance = [navigator distanceToWaypoint:waypoint];
    if (time == CLTimeIntervalMax || distance == CLLocationDistanceMax) {
      waypointInformation[waypoint.title] = nil;
      continue;
    }
    TimeAndDistance *newTimeAndDistanceObject = [[TimeAndDistance alloc] init];
    newTimeAndDistanceObject.distanceMeters = distance;
    newTimeAndDistanceObject.durationSeconds = time;
    waypointInformation[waypoint.title] = newTimeAndDistanceObject;
  }
  _waypointInformationView.waypointInformation = waypointInformation;
  [_mapView invalidateLayoutForAccessoryView:_waypointInformationView];
}

/** Requests a route from a simulated location to a canned destination. */
- (void)simulateLocationAndFetchRoute {
  // Simulate at a fixed location in Sydney so the behavior of this demo is consistent.
  CLLocationCoordinate2D pyrmont = CLLocationCoordinate2DMake(-33.869097, 151.193590);
  [_mapView.locationSimulator simulateLocationAtCoordinate:pyrmont];

  // Request the route.
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(-34.4269596, 150.8883194);
  GMSNavigationWaypoint *destination =
      [[GMSNavigationWaypoint alloc] initWithLocation:coordinate title:@"Woollongong Station"];
  [_mapView.navigator setDestinations:@[ destination ]
                             callback:^(GMSRouteStatus routeStatus) {
                               if (routeStatus != GMSRouteStatusOK) {
                                 NSLog(@"Route failed.");
                               }
                             }];
}

/** Toggles the menu between the expanded and collapsed states. */
- (void)toggleMenuCollapsed {
  [UIView animateWithDuration:0.4
                   animations:^{
                     _controlsHeightConstraint.constant =
                         (_controlsHeightConstraint.constant == 0.f) ? kControlsHeightExpanded
                                                                     : 0.f;
                     [self.view layoutIfNeeded];
                   }];
}

/** Starts simulating along the given route and waypoints. */
- (void)startSimulation {
  [_mapView.locationSimulator simulateLocationsAlongExistingRoute];
}

/** Stops the simulation. */
- (void)stopSimulation {
  [_mapView.locationSimulator stopSimulation];
}

/** Sends a simulated nav prompt */
- (void)simulatePrompt {
  [_mapView.locationSimulator simulateNavigationPrompt];
}

/** Simulates a traffic incident report. */
- (void)simulateTrafficReport {
  [_mapView.locationSimulator simulateTrafficIncidentReport];
}

/** Clears the current route. */
- (void)clearRoute {
  [_mapView clear];
  [_waypoints removeAllObjects];
  [_mapView.navigator clearDestinations];
}

/** Starts guidance. */
- (void)startGuidance {
  _mapView.navigator.guidanceActive = YES;
}

/** Stops guidance. */
- (void)stopGuidance {
  _mapView.navigator.guidanceActive = NO;
}

/** Continues to the next user generated waypoint along the route. */
- (void)continueToNextWaypoint {
  if (!_waypoints.count) {
    return;
  }
  [_waypoints removeObjectAtIndex:0];

  [self requestRoute];
}

/** Updates the camera perspective. */
- (void)updatePerspective:(UISegmentedControl *)sender {
  _mapView.followingPerspective = (GMSNavigationCameraPerspective)sender.selectedSegmentIndex;
}

/** Updates the camera perspective. */
- (void)cameraModeControlDidUpdate:(UISegmentedControl *)sender {
  if (sender.selectedSegmentIndex == kCustomCameraModeIndex) {
    [_mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:-33.857431
                                                                  longitude:151.211927
                                                                       zoom:13.f
                                                                    bearing:20.f
                                                               viewingAngle:0.f]];
  } else {
    _mapView.cameraMode = (GMSNavigationCameraMode)sender.selectedSegmentIndex;
  }
}

- (void)autoFollowModeSwitchDidUpdate:(NavDemoSwitch *)sender {
  _isAutoFollowEnabled = sender.on;
  if (!_isAutoFollowEnabled) {
    [_autoFollowTimer invalidate];
    _autoFollowTimer = nil;
  }
}

/** Updates the header to use customized settings. */
- (void)customizedHeaderSwitchDidUpdate:(NavDemoSwitch *)sender {
  GMSUISettings *settings = _mapView.settings;
  if (sender.on) {
    // Background colors.
    settings.navigationHeaderPrimaryBackgroundColor = [UIColor colorWithRed:0.0
                                                                      green:0.2
                                                                       blue:0.75
                                                                      alpha:1.0];
    settings.navigationHeaderSecondaryBackgroundColor = [UIColor colorWithRed:0.0
                                                                        green:0.2
                                                                         blue:0.5
                                                                        alpha:1.0];
    settings.navigationHeaderPrimaryBackgroundColorNightMode = [UIColor colorWithRed:0.0
                                                                               green:0.15
                                                                                blue:0.5
                                                                               alpha:1.0];
    settings.navigationHeaderSecondaryBackgroundColorNightMode = [UIColor colorWithRed:0.0
                                                                                 green:0.15
                                                                                  blue:0.35
                                                                                 alpha:1.0];

    // Icon colors.
    settings.navigationHeaderLargeManeuverIconColor = UIColor.orangeColor;
    settings.navigationHeaderSmallManeuverIconColor = UIColor.yellowColor;
    settings.navigationHeaderGuidanceRecommendedLaneColor = UIColor.orangeColor;

    // Text colors and fonts.
    settings.navigationHeaderNextStepTextColor = UIColor.yellowColor;
    settings.navigationHeaderNextStepFont = [UIFont fontWithName:kCustomizedHeaderFont size:16];
    settings.navigationHeaderDistanceValueTextColor = UIColor.lightGrayColor;
    settings.navigationHeaderDistanceValueFont = [UIFont fontWithName:kCustomizedHeaderFont
                                                                 size:24];
    settings.navigationHeaderDistanceUnitsTextColor = UIColor.lightGrayColor;
    settings.navigationHeaderDistanceUnitsFont = [UIFont fontWithName:kCustomizedHeaderFont
                                                                 size:18];
    settings.navigationHeaderInstructionsFirstRowFont = [UIFont fontWithName:kCustomizedHeaderFont
                                                                        size:30];
    settings.navigationHeaderInstructionsTextColor = UIColor.yellowColor;
    settings.navigationHeaderInstructionsSecondRowFont = [UIFont fontWithName:kCustomizedHeaderFont
                                                                         size:24];
    settings.navigationHeaderInstructionsConjunctionsFont =
        [UIFont fontWithName:kCustomizedHeaderFont size:18];
  } else {
    // Background colors.
    settings.navigationHeaderPrimaryBackgroundColor = nil;
    settings.navigationHeaderSecondaryBackgroundColor = nil;
    settings.navigationHeaderPrimaryBackgroundColorNightMode = nil;
    settings.navigationHeaderSecondaryBackgroundColorNightMode = nil;

    // Icon colors.
    settings.navigationHeaderLargeManeuverIconColor = nil;
    settings.navigationHeaderSmallManeuverIconColor = nil;
    settings.navigationHeaderGuidanceRecommendedLaneColor = nil;

    // Text colors and fonts.
    settings.navigationHeaderNextStepTextColor = nil;
    settings.navigationHeaderNextStepFont = nil;
    settings.navigationHeaderDistanceValueTextColor = nil;
    settings.navigationHeaderDistanceValueFont = nil;
    settings.navigationHeaderDistanceUnitsTextColor = nil;
    settings.navigationHeaderDistanceUnitsFont = nil;
    settings.navigationHeaderInstructionsTextColor = nil;
    settings.navigationHeaderInstructionsFirstRowFont = nil;
    settings.navigationHeaderInstructionsSecondRowFont = nil;
    settings.navigationHeaderInstructionsConjunctionsFont = nil;
  }
}

- (void)destinationMarkersSwitchDidUpdate:(NavDemoSwitch *)sender {
  _mapView.settings.showsDestinationMarkers = sender.on;
}

- (void)accessibilitySwitchDidUpdate:(NavDemoSwitch *)sender {
  _mapView.accessibilityElementsHidden = sender.on;
}

- (void)mapTypeControlDidUpdate:(UISegmentedControl *)mapTypeControl {
  _mapView.mapType = kMapViewTypeChoices[mapTypeControl.selectedSegmentIndex];
}

#pragma mark - GMSNavigationListener

/** Update header accessory view when distance is updated. */
- (void)navigator:(GMSNavigator *)navigator
    didUpdateRemainingDistance:(CLLocationDistance)distance {
  [self updateWaypointInformationView];
}

/** Update header accessory view when time remaining is updated. */
- (void)navigator:(GMSNavigator *)navigator didUpdateRemainingTime:(NSTimeInterval)time {
  [self updateWaypointInformationView];
}

/** Continuing to the next waypoint isn't allowed when not at a waypoint.  */
- (void)navigatorDidChangeRoute:(GMSNavigator *)navigator {
  _continueToNextWaypointButton.hidden = YES;
  [_continueToNextWaypointButton setEnabled:NO];
}

/** Arriving at a waypoint should enable the functionality to go to the next waypoint. */
- (void)navigator:(GMSNavigator *)navigator didArriveAtWaypoint:(GMSNavigationWaypoint *)waypoint {
  _continueToNextWaypointButton.hidden = NO;
  [_continueToNextWaypointButton setEnabled:YES];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
  if (!_isAutoFollowEnabled) return;
  if (!_mapView.navigator.guidanceActive) return;
  if (!gesture) return;

  [_autoFollowTimer invalidate];
  _autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(recenterMap)
                                                    userInfo:nil
                                                     repeats:NO];
}

/** Recenters the map. */
- (void)recenterMap {
  if (_mapView.navigator.guidanceActive) {
    _mapView.cameraMode = GMSNavigationCameraModeFollowing;
  }

  [_autoFollowTimer invalidate];
  _autoFollowTimer = nil;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  NSString *waypointID = [[NSString alloc] initWithFormat:@"Waypoint %lu", [_waypoints count] + 1];
  GMSNavigationWaypoint *newWaypoint = [[GMSNavigationWaypoint alloc] initWithLocation:coordinate
                                                                                 title:waypointID];
  if (newWaypoint) {
    [_waypoints addObject:newWaypoint];
    GMSMarker *newWaypointMarker = [GMSMarker markerWithPosition:coordinate];
    newWaypointMarker.title = waypointID;
    newWaypointMarker.map = mapView;
  }
}

@end

#pragma mark - Helper Class Implementation

@implementation TimeAndDistance
@end

@implementation WaypointInformationView {
  UILabel *_waypointInformationLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  self.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.15 blue:0.35 alpha:1.0];

  // Sets the label details in the header accessory view's waypoint information view
  _waypointInformationLabel = [[UILabel alloc] init];
  _waypointInformationLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _waypointInformationLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _waypointInformationLabel.numberOfLines = 0;
  _waypointInformationLabel.textColor = UIColor.lightTextColor;
  [self addSubview:_waypointInformationLabel];
  [NSLayoutConstraint activateConstraints:@[
    [_waypointInformationLabel.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
    [_waypointInformationLabel.leadingAnchor
        constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
    [_waypointInformationLabel.trailingAnchor
        constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]
  ]];
  return self;
}

/** Sets the text field of the waypoint information view based on the waypoints. */
- (void)setWaypointInformation:(NSDictionary<NSString *, TimeAndDistance *> *)waypointInformation {
  _waypointInformation = waypointInformation;
  if (!waypointInformation || waypointInformation.count <= 0) {
    _waypointInformationLabel.text = @"No waypoint information received";
    return;
  }
  NSDateComponentsFormatter *timeFormatter = [[NSDateComponentsFormatter alloc] init];
  NSMutableString *displayText = [NSMutableString string];

  // Sort based on the next waypoint.
  NSArray<NSString *> *sortedKeys =
      [[waypointInformation allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *key in sortedKeys) {
    if (waypointInformation[key] == nil) {
      [displayText appendString:[NSString stringWithFormat:@"%@ Unvavailable", key]];
    } else {
      NSString *formattedTime =
          [timeFormatter stringFromTimeInterval:waypointInformation[key].durationSeconds]
              ?: @"Unknown";
      NSString *formattedDistance =
          [NSString stringWithFormat:@"%.1f", waypointInformation[key].distanceMeters];
      [displayText appendString:[NSString stringWithFormat:@"%@ Time: %@ Distance %@ m\n", key,
                                                           formattedTime, formattedDistance]];
    }
  }

  if ([[displayText substringFromIndex:[displayText length] - 1] isEqualToString:@"\n"]) {
    _waypointInformationLabel.text = [displayText substringToIndex:[displayText length] - 1];
  } else {
    _waypointInformationLabel.text = displayText;
  }
}

- (CGFloat)heightForAccessoryViewConstrainedToSize:(CGSize)size onMapView:(GMSMapView *)mapView {
  UIEdgeInsets layoutMargins = self.layoutMargins;
  size.width = size.width - (layoutMargins.left + layoutMargins.right);
  return [_waypointInformationLabel sizeThatFits:size].height + layoutMargins.top +
         layoutMargins.bottom;
}

@end
