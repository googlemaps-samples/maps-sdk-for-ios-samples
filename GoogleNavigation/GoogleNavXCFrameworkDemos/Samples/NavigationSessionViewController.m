/*
 * Copyright 2023 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/Samples/NavigationSessionViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayConnectionManager.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySharedState.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoStringUtils.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoSwitch.h"
#import "GoogleNavXCFrameworkDemos/Utils/NavDemoUtilities.h"

/* Accessibility identifier for the scroll view that contains the controls at the bottom. */
static NSString *const kControlsScrollViewIdentifier = @"ControlsScrollView";

/** Object representing a planned stop (marker, waypoint, order). */
@interface Stop : GMSMarker <CarPlaySharedDestination>

/** The navigation waypoint for the marker. */
@property(nonatomic, nonnull, readonly) GMSNavigationWaypoint *waypoint;

/** Sequence number. These should be assigned serially starting at zero. */
@property(nonatomic, readonly) int32_t sequenceNumber;

/** Whether the user has navigated to this stop yet. Setting this updates the icon. */
@property(nonatomic) BOOL completed;

+ (instancetype)markerWithPosition:(CLLocationCoordinate2D)position NS_UNAVAILABLE;

+ (instancetype)stopWithWaypoint:(GMSNavigationWaypoint *)waypoint
                  sequenceNumber:(int32_t)sequenceNumber;

@property(nonatomic, readonly, nullable)
    CarPlaySharedDestinationIconViewCreationBlock iconViewCretator;

@end

@implementation Stop {
  UIImage *_cachedCircleImage;  // Lazily initialized, access via @c circleImage property.
}

+ (instancetype)stopWithWaypoint:(GMSNavigationWaypoint *)waypoint
                  sequenceNumber:(int32_t)sequenceNumber {
  Stop *stop = [super markerWithPosition:waypoint.coordinate];
  if (stop) {
    stop->_waypoint = waypoint;
    stop->_sequenceNumber = sequenceNumber;
    stop->_completed = NO;
    stop.title = waypoint.title;
    [stop setMarker:stop];
  }
  return stop;
}

- (BOOL)isMarker {
  return YES;
}

- (BOOL)isTrip {
  return !_completed;
}

- (void)setCompleted:(BOOL)completed {
  if (completed != _completed) {
    _completed = completed;
    _cachedCircleImage = nil;
    [self setMarker:self];
  }
}

- (UIImage *)circleImage {
  if (!_cachedCircleImage) {
    NSString *imageName = [NSString stringWithFormat:@"%d.circle.fill", _sequenceNumber];
    UIImage *_Nullable circleImage = [UIImage systemImageNamed:imageName];
    UIColor *circleColor = _completed ? UIColor.grayColor : UIColor.systemRedColor;
    _cachedCircleImage = [circleImage imageWithTintColor:circleColor
                                           renderingMode:UIImageRenderingModeAlwaysOriginal];
  }
  return _cachedCircleImage;
}

- (void)setMarker:(GMSMarker *)marker {
  // This needs to use a view because the tint color and other effects won't work otherwise.
  marker.iconView = [[UIImageView alloc] initWithImage:self.circleImage];
  marker.groundAnchor = CGPointMake(0.5, 0.5);
}

- (CarPlaySharedDestinationIconViewCreationBlock)iconViewCreator {
  return ^UIView *_Nonnull(id<CarPlaySharedDestination> genericDestination) {
    return [[UIImageView alloc] initWithImage:self.circleImage];
  };
}

@end

/** NavigationSessionView displays information about the current navigation session. */
@interface NavigationSessionView : UIView <GMSNavigatorListener>

/** This superclass initializer is not supported. */
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame
                    navigator:(GMSNavigator *)navigator NS_DESIGNATED_INITIALIZER;

@end

@implementation NavigationSessionView {
  GMSNavigator *_navigator;
  UILabel *_label;
  NSDateComponentsFormatter *_timeFormatter;
  GMSNavigationNavInfo *_Nullable _navInfo;
}

- (instancetype)initWithFrame:(CGRect)frame navigator:(GMSNavigator *)navigator {
  self = [super initWithFrame:frame];
  if (self) {
    _navigator = navigator;
    [navigator addListener:self];
    self.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.15 blue:0.35 alpha:1.0];

    _timeFormatter = [[NSDateComponentsFormatter alloc] init];

    // Sets the label details in the header accessory view's waypoint information view
    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.numberOfLines = 2;
    _label.textColor = UIColor.lightTextColor;
    [self addSubview:_label];
    CGFloat newHeight = [_label sizeThatFits:self.superview.bounds.size].height +
                        self.layoutMargins.top + self.layoutMargins.bottom + 150;
    [NSLayoutConstraint activateConstraints:@[
      [_label.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
      [_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
      [_label.bottomAnchor constraintEqualToAnchor:self.layoutMarginsGuide.bottomAnchor],
      [self.heightAnchor constraintEqualToConstant:newHeight],
    ]];
    [self updateLabel];
  }
  return self;
}

/** Refreshes the content of the label based on the navigator and navInfo. */
- (void)updateLabel {
  NSMutableString *displayText = [NSMutableString string];
  if (!_navigator.guidanceActive) {
    [displayText appendString:@"Guidance not active."];
  } else {
    NSTimeInterval timeRemaining = _navigator.timeToNextDestination;
    CLLocationDistance distanceRemaining = _navigator.distanceToNextDestination;
    NSString *formattedTime = [_timeFormatter stringFromTimeInterval:timeRemaining];
    NSString *formattedDistance = [NSString stringWithFormat:@"%.1f", distanceRemaining];
    [displayText appendString:[NSString stringWithFormat:@"Next stop Time: %@ Distance %@ m\n",
                                                         formattedTime, formattedDistance]];
    NSString *fullInstructionText = _navInfo.currentStep.fullInstructionText;
    if (fullInstructionText) {
      [displayText appendString:fullInstructionText];
    }
  }
  if ([[displayText substringFromIndex:displayText.length - 1] isEqualToString:@"\n"]) {
    [displayText deleteCharactersInRange:NSMakeRange(displayText.length - 1U, 1U)];
  }
  _label.text = displayText;
}

- (void)navigator:(GMSNavigator *)navigator
    didUpdateRemainingDistance:(CLLocationDistance)distance {
  [self updateLabel];
}

- (void)navigator:(GMSNavigator *)navigator didUpdateRemainingTime:(NSTimeInterval)time {
  [self updateLabel];
}

- (void)navigator:(GMSNavigator *)navigator didArriveAtWaypoint:(GMSNavigationWaypoint *)waypoint {
  [self updateLabel];
}

- (void)navigator:(GMSNavigator *)navigator didUpdateNavInfo:(GMSNavigationNavInfo *)navInfo {
  _navInfo = navInfo;
  [self updateLabel];
}

@end

/** The height of the control pane when it is expanded. */
static const CGFloat kControlsHeightExpanded = 200.f;

@interface NavigationSessionViewController () <CarPlayConnectionManagerDelegate,
                                               GMSMapViewDelegate,
                                               GMSNavigatorListener,
                                               GMSRoadSnappedLocationProviderListener> {
  GMSNavigationSession *_navigationSession;

  /** Whether NavSDK is currently fetching a route. */
  BOOL _routeRequestInFlight;

  /** Whether a route to the next stop has been fetched by NavSDK. */
  BOOL _routeAvailable;

  /** Constraint for the height of the controls view. */
  NSLayoutConstraint *_controlsHeightConstraint;

  /** Subview showing information about the navigation session. */
  NavigationSessionView *_navigationSessionView;

  /** All stops (including already-completed ones). */
  NSMutableArray<Stop *> *_stops;

  /**
   * The number of completed stops.
   *
   * When guidance is active, the current stop is _stops[_completedStopCount].
   */
  NSUInteger _completedStopCount;

  /** If we have a route, this polyline gives the current path to the first stop. */
  GMSPolyline *_routePolyline;

  // UI Elements the view controller need references to.
  UILabel *_tapOnMapToAddDestinationsPrompt;
  UIButton *_continueToNextWaypointButton;
  NavDemoSwitch *_guidanceActiveSwitch;
  NavDemoSwitch *_simulateLocationWhenDepartingSwitch;
  NavDemoSwitch *_simulationPausedSwitch;
  NavDemoSwitch *_voiceGuidanceSwitch;
  NavDemoSwitch *_backgroundNotificationsSwitch;
  NavDemoSwitch *_turnByTurnNavigationSwitch;
  NavDemoSwitch *_clearAllStopsSimulationSwitch;
  GMSCameraPosition *_cameraPositionBeforeTurnByTurn;
  GMSMapView *_mapView;
}

@end

@implementation NavigationSessionViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _stops = [NSMutableArray<Stop *> array];
  _completedStopCount = 0U;

  // Create the navigation session.
  _navigationSession = [GMSNavigationServices createNavigationSession];
  GMSRoadSnappedLocationProvider *roadSnappedLocationProvider =
      _navigationSession.roadSnappedLocationProvider;
  [roadSnappedLocationProvider startUpdatingLocation];
  GMSNavigator *navigator = _navigationSession.navigator;
  [navigator addListener:self];
  navigator.voiceGuidance = GMSNavigationVoiceGuidanceSilent;
  navigator.sendsBackgroundNotifications = NO;
  _navigationSession.started = YES;

  CarPlayConnectionManager *carPlayConnectionManager = CarPlayConnectionManager.sharedManager;
  carPlayConnectionManager.delegate = self;
  CarPlaySharedState *carPlaySharedState = CarPlaySharedState.sharedState;
  carPlaySharedState.enabled = YES;
  carPlaySharedState.navigationSession = _navigationSession;
  [self updateCarPlaySharedStateDestinations];

  // Push the stack view below the navigation bar (it turns out most demos don't care about this).
  self.mainStackView.distribution = UIStackViewDistributionFill;

  _navigationSessionView = [[NavigationSessionView alloc] initWithFrame:CGRectZero
                                                              navigator:navigator];
  [self.mainStackView addArrangedSubview:_navigationSessionView];

  // Add a map.
  _mapView = [[GMSMapView alloc] init];
  // Associate the map view with the above navigation session.
  [_mapView enableNavigationWithSession:_navigationSession];
  // We don't want turn-by-turn navigation right now, so turn that back off.
  _mapView.navigationEnabled = NO;
  [self.mainStackView addArrangedSubview:_mapView];
  [self.mainStackView setNeedsLayout];
  // Opt the mapView into automatic dark mode switching. Dark mode setting would take effect only if
  // navigationEnabled is NO.
  _mapView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
  _mapView.settings.compassButton = YES;
  _mapView.settings.showsDestinationMarkers = NO;
  _mapView.delegate = self;
  _mapView.myLocationEnabled = YES;
  _mapView.roadSnappedMyLocationSource = roadSnappedLocationProvider;
  carPlaySharedState.roadSnappedMyLocationSource = roadSnappedLocationProvider;
  [roadSnappedLocationProvider addListener:self];

  // Add the controls to the container.
  [self addControls];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  CarPlaySharedState.sharedState.enabled = NO;
  CarPlaySharedState.sharedState.turnByTurnGuidanceActive = NO;
}

/** Creates the UI controls and adds them to the view hierarchy. */
- (void)addControls {
  UIStackView *controls = self.controls;

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
  _tapOnMapToAddDestinationsPrompt = GMSNavigationCreateLabelWithText(@"Tap map to add waypoint.");
  [controls addArrangedSubview:_tapOnMapToAddDestinationsPrompt];

  UIStackView *routeControls = GMSNavigationCreateHorizontalStackView();
  [controls addArrangedSubview:routeControls];

  _continueToNextWaypointButton =
      GMSNavigationCreateButton(self, @selector(continueToNextStop), @"Go to next stop");
  [routeControls addArrangedSubview:_continueToNextWaypointButton];
  [_continueToNextWaypointButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  [_continueToNextWaypointButton setTitleColor:UIColor.lightTextColor
                                      forState:UIControlStateDisabled];
  [_continueToNextWaypointButton setTitle:@"No stop" forState:UIControlStateDisabled];
  _continueToNextWaypointButton.enabled = NO;

  [routeControls
      addArrangedSubview:GMSNavigationCreateButton(self, @selector(clearAll), @"Clear all")];

  // Add switch to enable the turn-by-turn navigation UI for the session.
  _turnByTurnNavigationSwitch =
      [NavDemoSwitch switchWithLabel:@"Turn-by-turn Navigation"
                              target:self
                            selector:@selector(turnByTurnNavigationChanged:)];
  // Disabled for now because there is no destination.
  _turnByTurnNavigationSwitch.enabled = NO;
  [controls addArrangedSubview:_turnByTurnNavigationSwitch];

  // Add switch allows pausing guidance while navigating.
  _guidanceActiveSwitch = [NavDemoSwitch switchWithLabel:@"Guidance active"
                                                  target:self
                                                selector:@selector(changeGuidanceActive:)];
  [controls addArrangedSubview:_guidanceActiveSwitch];

  // Add switch to turn voice guidance on or off.
  _voiceGuidanceSwitch = [NavDemoSwitch switchWithLabel:@"Voice Guidance"
                                                 target:self
                                               selector:@selector(voiceGuidanceChanged:)];
  [controls addArrangedSubview:_voiceGuidanceSwitch];

  // Add switch to turn background notifications on or off.
  _backgroundNotificationsSwitch =
      [NavDemoSwitch switchWithLabel:@"Background Notifications Enabled"
                              target:self
                            selector:@selector(backgroundNotificationsChanged:)];
  _backgroundNotificationsSwitch.enabled = NO;
  [controls addArrangedSubview:_backgroundNotificationsSwitch];

  // Location simulation controls.
  UILabel *locationSimulationLabel = GMSNavigationCreateLabelWithText(@"Location Simulation");
  locationSimulationLabel.textAlignment = NSTextAlignmentLeft;  // Default is center.
  [controls addArrangedSubview:locationSimulationLabel];

  // Add switch for temporarily pausing location simulation.
  _simulationPausedSwitch = [NavDemoSwitch switchWithLabel:@"Simulation paused"
                                                    target:self
                                                  selector:@selector(simulationPausedDidChange:)];
  [controls addArrangedSubview:_simulationPausedSwitch];

  // Add a segmented control for the simulation speed multiplier.
  UIView *simulationTimeScaleSegmentedControl =
      [self segmentedControlWithTitles:@[ @"1x", @"2x", @"5x", @"10x", @"20x" ]
                             labelText:@"Simulated travel speed multiplier"
                              selector:@selector(simulationTimeScaleMultiplierSelected:)
                  selectedSegmentIndex:2];
  [controls addArrangedSubview:simulationTimeScaleSegmentedControl];

  // Add a segmented control for dark mode type. Dark mode setting would take effect only if
  // navigationEnabled is NO.
  NSArray<NSString *> *_darkModeTypes = @[ @"Follows Device", @"Light", @"Dark" ];
  UIView *darkModeTypeControl =
      [self segmentedControlWithTitles:_darkModeTypes
                              selector:@selector(darkModeTypeControlChanged:)
                  selectedSegmentIndex:0];
  [controls addArrangedSubview:darkModeTypeControl];

  // Add switch for whether to simulate location to the next stop when departing.
  // This defaults to on if we're running on simulator, but off if we're running on a real device.
  _simulateLocationWhenDepartingSwitch =
      [NavDemoSwitch switchWithLabel:@"Simulate route when departing"
                        initialState:YES
                              target:nil
                            selector:NULL];
  [controls addArrangedSubview:_simulateLocationWhenDepartingSwitch];

  // Add a switch that controls whether or not the Clear All button stops simulation.
  // Not clearing simulation can be useful when trying to simulate re-routing.
  _clearAllStopsSimulationSwitch = [NavDemoSwitch switchWithLabel:@"Clear All stops simulation"
                                                     initialState:YES
                                                           target:nil
                                                         selector:NULL];
  [controls addArrangedSubview:_clearAllStopsSimulationSwitch];

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
}

- (void)updateControls {
  GMSNavigator *navigator = _navigationSession.navigator;
  BOOL guidanceActive = navigator.guidanceActive;

  _tapOnMapToAddDestinationsPrompt.enabled = !guidanceActive;
  if (guidanceActive) {
    [_continueToNextWaypointButton setTitle:@"En route" forState:UIControlStateDisabled];
  } else if (_routeRequestInFlight) {
    [_continueToNextWaypointButton setTitle:@"Fetching route" forState:UIControlStateDisabled];
  } else if (_stops.count == 0U) {
    [_continueToNextWaypointButton setTitle:@"No destination" forState:UIControlStateDisabled];
  } else {
    [_continueToNextWaypointButton setTitle:@"All complete" forState:UIControlStateDisabled];
  }
  _continueToNextWaypointButton.enabled =
      (!guidanceActive) && (_stops.count > _completedStopCount) && (!_routeRequestInFlight);
  _guidanceActiveSwitch.on = guidanceActive;
  _simulationPausedSwitch.on = _navigationSession.locationSimulator.paused;
  _backgroundNotificationsSwitch.enabled = guidanceActive;
  _turnByTurnNavigationSwitch.enabled = guidanceActive || _mapView.navigationEnabled;
  _turnByTurnNavigationSwitch.on = CarPlaySharedState.sharedState.turnByTurnGuidanceActive;
}

/** Requests a route with the selected stop type, travel mode and options. */
- (void)continueToNextStop {
  if (_completedStopCount >= _stops.count) {
    return;
  }
  _routeRequestInFlight = YES;
  Stop *nextStop = _stops[_completedStopCount];
  GMSNavigationWaypoint *waypoint = nextStop.waypoint;
  GMSNavigator *navigator = _navigationSession.navigator;
  __weak NavigationSessionViewController *weakSelf = self;
  [navigator setDestinations:@[
    waypoint,
  ]
                    callback:^(GMSRouteStatus routeStatus) {
                      [weakSelf handleRouteCallbackWithStatus:routeStatus];
                    }];
  [self updateControls];
}

/** Handles a route response with the given success or failure status. */
- (void)handleRouteCallbackWithStatus:(GMSRouteStatus)routeStatus {
  Stop *nextStop = _stops[_completedStopCount];
  CarPlaySharedState *sharedState = CarPlaySharedState.sharedState;
  _routeRequestInFlight = NO;
  if (routeStatus == GMSRouteStatusOK) {
    _routeAvailable = YES;
    _navigationSession.navigator.guidanceActive = YES;
    if (_simulateLocationWhenDepartingSwitch.on) {
      [_navigationSession.locationSimulator simulateLocationsAlongExistingRoute];
    }
    sharedState.selectedDestination = nextStop;
  } else {
    // Show an error dialog to describe the failure.
    GMSNavigationPresentAlertController(self, GMSNavigationDemoMessageForRouteStatus(routeStatus),
                                        @"Route failed", @"OK");
    nextStop.map = nil;
    [_stops removeObject:nextStop];
    sharedState.selectedDestination = nil;
    [self updateCarPlaySharedStateDestinations];
  }
  [self updateControls];
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

#pragma mark - UI Callbacks

/** Clears all state and returns the demo to initial conditions. */
- (void)clearAll {
  if (_mapView.navigationEnabled) {
    [self endTurnByTurnNavigation];
  }
  if (_clearAllStopsSimulationSwitch.on) {
    [_navigationSession.locationSimulator stopSimulation];
  }
  [_mapView clear];
  [_stops removeAllObjects];
  [_navigationSession.navigator clearDestinations];
  _completedStopCount = 0;
  _routeAvailable = NO;
  [self updateCarPlaySharedStateDestinations];
  CarPlaySharedState.sharedState.selectedDestination = nil;
  [self updateControls];
}

- (void)simulationTimeScaleMultiplierSelected:(UISegmentedControl *)segmentedControl {
  float simulationSpeedMultiplier =
      [[segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex] floatValue];
  _navigationSession.locationSimulator.speedMultiplier = simulationSpeedMultiplier;
}

- (void)darkModeTypeControlChanged:(UISegmentedControl *)segmentedControl {
  UIUserInterfaceStyle darkModeTypes[] = {UIUserInterfaceStyleUnspecified,
                                          UIUserInterfaceStyleLight, UIUserInterfaceStyleDark};
  _mapView.overrideUserInterfaceStyle = darkModeTypes[segmentedControl.selectedSegmentIndex];
}

- (void)changeGuidanceActive:(NavDemoSwitch *)control {
  _navigationSession.navigator.guidanceActive = control.on;
  [self updateControls];
}

- (void)simulationPausedDidChange:(NavDemoSwitch *)control {
  _navigationSession.locationSimulator.paused = control.on;
}

- (void)voiceGuidanceChanged:(UISwitch *)control {
  _navigationSession.navigator.voiceGuidance =
      control.on ? GMSNavigationVoiceGuidanceAlertsAndGuidance : GMSNavigationVoiceGuidanceSilent;
}

- (void)backgroundNotificationsChanged:(NavDemoSwitch *)control {
  _navigationSession.navigator.sendsBackgroundNotifications = control.on;
}

- (void)turnByTurnNavigationChanged:(NavDemoSwitch *)control {
  CarPlaySharedState.sharedState.turnByTurnGuidanceActive = control.on;
  // Apple HIG says that turn-by-turn navigation should not be active
  // on both CarPlay and the phone at the same time.
  if (!CarPlayConnectionManager.sharedManager.applicationSceneActive) {
    if (control.on) {
      [self startTurnByTurnNavigation];
    } else {
      [self endTurnByTurnNavigation];
    }
  }
  [self updateControls];
}

/**
 * Starts turn-by-turn navigation on the map view.
 */
- (void)startTurnByTurnNavigation {
  _cameraPositionBeforeTurnByTurn = _mapView.camera;
  _mapView.myLocationEnabled = NO;
  [_mapView enableNavigationWithSession:_navigationSession];
}

/**
 * Ends turn-by-turn navigation and returns to previous camera.
 *
 * Can be called either explicitly from the UI or implicitly when arriving.
 */
- (void)endTurnByTurnNavigation {
  _mapView.cameraMode = GMSNavigationCameraModeOverview;
  _mapView.navigationEnabled = NO;
  _mapView.myLocationEnabled = YES;
  if (_cameraPositionBeforeTurnByTurn) {
    [_mapView animateToCameraPosition:_cameraPositionBeforeTurnByTurn];
    _cameraPositionBeforeTurnByTurn = nil;
  }
}

#pragma mark - GMSNavigationListener

/** Handle displaying an updated route. */
- (void)navigatorDidChangeRoute:(GMSNavigator *)navigator {
  _routePolyline.map = nil;
  _routePolyline = nil;
  CarPlaySharedState *sharedState = CarPlaySharedState.sharedState;
  sharedState.paths = nil;
  GMSPath *path = navigator.currentRouteLeg.path;
  if (path) {
    _routePolyline = [GMSPolyline polylineWithPath:path];
    _routePolyline.map = _mapView;
    sharedState.paths = @[
      path,
    ];
  }
}

/** Reset state when arriving at waypoint. */
- (void)navigator:(GMSNavigator *)navigator didArriveAtWaypoint:(GMSNavigationWaypoint *)waypoint {
  Stop *stop = _stops[_completedStopCount];
  _completedStopCount++;
  _routeAvailable = NO;
  navigator.guidanceActive = NO;
  [navigator clearDestinations];
  stop.completed = YES;
  [self endTurnByTurnNavigation];
  CarPlaySharedState.sharedState.turnByTurnGuidanceActive = NO;
  [self updateCarPlaySharedStateDestinations];
  [self updateControls];
}

#pragma mark - GMSRoadSnappedLocationProviderListener

- (void)locationProvider:(GMSRoadSnappedLocationProvider *)locationProvider
       didUpdateLocation:(CLLocation *)location {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    GMSCameraPosition *position = [[GMSCameraPosition alloc] initWithTarget:location.coordinate
                                                                       zoom:15.];
    [_mapView animateToCameraPosition:position];
  });
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  if (_navigationSession.navigator.guidanceActive) {
    // Can't edit route while navigating.
    return;
  }
  NSString *waypointID = [[NSString alloc] initWithFormat:@"Stop %lu", _stops.count + 1];
  GMSNavigationWaypoint *newWaypoint = [[GMSNavigationWaypoint alloc] initWithLocation:coordinate
                                                                                 title:waypointID];
  if (!newWaypoint) {
    return;
  }
  Stop *stop = [Stop stopWithWaypoint:newWaypoint sequenceNumber:(int32_t)_stops.count];
  stop.map = _mapView;
  [_stops addObject:stop];
  [self updateCarPlaySharedStateDestinations];
  [self updateControls];
}

#pragma mark - CarPlayConnectionManagerDelegate

- (void)didRequestBackWithConnectionManager:(CarPlayConnectionManager *)connectionManager {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)connectionManager:(CarPlayConnectionManager *)connectionManager
    didRequestGoToDestination:(id<CarPlaySharedDestination>)destination {
  if (_completedStopCount < _stops.count && destination == _stops[_completedStopCount]) {
    [self continueToNextStop];
  }
}

- (void)connectionManager:(CarPlayConnectionManager *)connectionManager
    didChangeApplicationActive:(BOOL)active {
  if (_turnByTurnNavigationSwitch.on) {
    if (active) {
      [self endTurnByTurnNavigation];
    } else {
      [self startTurnByTurnNavigation];
    }
  }
}

#pragma mark - Helper methods

- (void)updateCarPlaySharedStateDestinations {
  CarPlaySharedState *carPlayState = CarPlaySharedState.sharedState;
  carPlayState.destinations = _stops;
}

/**
 * Returns a container view containing a segmented control with the given titles and a label view
 * with the given label text.
 */
- (UIStackView *)segmentedControlWithTitles:(NSArray<NSString *> *)titles
                                  labelText:(NSString *)labelText
                                   selector:(SEL)selector
                       selectedSegmentIndex:(NSInteger)selectedSegmentIndex {
  UIStackView *container = [[UIStackView alloc] init];
  container.axis = UILayoutConstraintAxisVertical;
  container.spacing = 3.;
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.text = labelText;
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont systemFontOfSize:10];
  label.numberOfLines = 2;
  [container addArrangedSubview:label];
  [container addArrangedSubview:[self segmentedControlWithTitles:titles
                                                        selector:selector
                                            selectedSegmentIndex:selectedSegmentIndex]];
  return container;
}

/** Returns a segmented control with the given titles. */
- (UISegmentedControl *)segmentedControlWithTitles:(NSArray<NSString *> *)titles
                                          selector:(SEL)selector
                              selectedSegmentIndex:(NSInteger)selectedSegmentIndex {
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
  [segmentedControl addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
  for (NSUInteger i = 0; i < titles.count; i++) {
    [segmentedControl insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
  }
  segmentedControl.selectedSegmentIndex = selectedSegmentIndex;
  return segmentedControl;
}

@end
