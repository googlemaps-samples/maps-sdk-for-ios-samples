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

#import <CarPlay/CarPlay.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
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
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayApplicationSceneMapController.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayConnectionManager.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySharedState.h"

/** Typedef for the callback when a CPMapButton is tapped. */
typedef void (^CPMapButtonHandler)(CPMapButton *);

static const CLLocationDistance kShowNextManeuverMaxDistanceMeters = 600;
static const NSTimeInterval kShowNextManeuverMaxTimeSeconds = 60;

/** Utility to build a CPTravelEstimates. */
static CPTravelEstimates *_Nonnull TravelEstimates(GMSNavigationNavInfo *_Nonnull navInfo,
                                                   CLLocationDistance distanceMeters,
                                                   NSTimeInterval timeIntervalSeconds) {
  NSMeasurement<NSUnitLength *> *distanceRemaining = [navInfo roundedDistance:distanceMeters];
  NSTimeInterval timeRemaining = [navInfo roundedTime:timeIntervalSeconds];
  return [[CPTravelEstimates alloc] initWithDistanceRemaining:distanceRemaining
                                                timeRemaining:timeRemaining];
}

static BOOL AreStepInfosEqualOrBothNil(GMSNavigationStepInfo *_Nullable stepInfo1,
                                       GMSNavigationStepInfo *_Nullable stepInfo2) {
  // This if statement will catch both identical items and the both-nil case.
  if (stepInfo1 == stepInfo2) {
    return YES;
  }
  if ((!stepInfo1) || (!stepInfo2)) {
    return NO;
  }
  return (stepInfo1.stepNumber == stepInfo2.stepNumber) &&
         (stepInfo1.exitNumber == stepInfo2.exitNumber) &&
         (stepInfo1.roundaboutTurnNumber == stepInfo2.roundaboutTurnNumber) &&
         (stepInfo1.fullInstructionText == stepInfo2.fullInstructionText) &&
         (stepInfo1.fullRoadName == stepInfo2.fullRoadName) &&
         (stepInfo1.drivingSide == stepInfo2.drivingSide) &&
         (stepInfo1.maneuver == stepInfo2.maneuver);
}

static BOOL NavInfosHaveSameSteps(GMSNavigationNavInfo *_Nullable navInfo1,
                                  GMSNavigationNavInfo *_Nullable navInfo2) {
  // This if statement will catch both identical items and the both-nil case.
  if (navInfo1 == navInfo2) {
    return YES;
  }
  if ((!navInfo1) || (!navInfo2)) {
    return NO;
  }
  NSArray<GMSNavigationStepInfo *> *remainingSteps1 = navInfo1.remainingSteps;
  NSArray<GMSNavigationStepInfo *> *remainingSteps2 = navInfo2.remainingSteps;
  if ((navInfo1.navState != navInfo2.navState) ||
      (!AreStepInfosEqualOrBothNil(navInfo1.currentStep, navInfo2.currentStep)) ||
      (remainingSteps1.count != remainingSteps2.count)) {
    return NO;
  }
  for (NSUInteger index = 0; index < remainingSteps1.count; index++) {
    if (!AreStepInfosEqualOrBothNil(remainingSteps1[index], remainingSteps2[index])) {
      return NO;
    }
  }
  return YES;
}

/** An object to be stored in the userInfo field of a CPManeuver. */
@interface ManeuverUserInfo : NSObject

@property(nonatomic, readonly, nonnull) GMSNavigationStepInfo *stepInfo;
@property(nonatomic, readonly, getter=isLaneGuidance) BOOL laneGuidance;

- (nonnull instancetype)initWithStepInfo:(GMSNavigationStepInfo *)stepInfo
                          isLaneGuidance:(BOOL)isLaneGuidance NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

@implementation ManeuverUserInfo

- (instancetype)initWithStepInfo:(GMSNavigationStepInfo *)stepInfo
                  isLaneGuidance:(BOOL)isLaneGuidance {
  self = [super init];
  if (self) {
    _stepInfo = stepInfo;
    _laneGuidance = isLaneGuidance;
  }
  return self;
}

@end

/** Add conformance to GMSNavigatorListener protocol. */
@interface CarPlayApplicationSceneMapController () <CarPlaySharedStateListener,
                                                    CLLocationManagerDelegate,
                                                    CPMapTemplateDelegate,
                                                    GMSNavigatorListener,
                                                    GMSRoadSnappedLocationProviderListener>

/** The navigation session we are currently displaying. */
@property(nonatomic, nullable) GMSNavigationSession *navigationSession;

/** The most recent location received (prefers road-snapped if available). */
@property(nonatomic, readonly, nullable) CLLocation *lastLocation;

/** Call this to update lastLocation. */
- (void)setLastLocation:(CLLocation *)lastLocation isRoadSnapped:(BOOL)isRoadSnapped;

/** Initializes a view controller for the given controller and window. */
- (instancetype)initWithWindow:(CPWindow *)window NS_DESIGNATED_INITIALIZER;

@end

@implementation CarPlayApplicationSceneMapController {
  CPInterfaceController *_interfaceController;
  CPMapTemplate *_mapTemplate;
  CPWindow *_window;
  GMSMapView *_mapView;
  CLLocation *_lastCoreLocation;
  CLLocation *_lastRoadSnappedLocation;
  CLLocationManager *_locationManager;
  BOOL _isPanningInterfaceEnabled;
  // The list of buttons to be shown when we are not in a mode of some kind.
  NSArray<CPMapButton *> *_mapButtons;
  // The list of markers derived from the previous update of destinations.
  NSArray<GMSMarker *> *_destinationMarkers;
  // The list of GMSPolylines made from the paths in the shared state.
  NSArray<GMSPolyline *> *_polylines;
  // The trip that navigation (not necessarily turn-by-turn) has been started on.
  CPTrip *_selectedTrip;
  // The CarPlay navigation session, if one has been started.
  CPNavigationSession *_carPlayNavigationSession;
  // The most recent navInfo seen.
  GMSNavigationNavInfo *_currentNavInfo;
  // The most recent stepInfo.
  GMSNavigationStepInfo *_currentStepInfo;
  // The set of options for formatting step instructions.
  GMSNavigationInstructionOptions *_instructionOptions;
  // The set of options for formatting maneuver images.
  GMSNavigationStepInfoImageOptions *_imageOptions;
}

// Rename the ivar to remind implementers to always use the setter.
@synthesize navigationSession = _internalNavigationSession;

- (instancetype)initWithWindow:(CPWindow *)window {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _window = window;
    _mapTemplate = [[CPMapTemplate alloc] init];
    _mapTemplate.mapDelegate = self;
    _mapTemplate.guidanceBackgroundColor = UIColor.darkGrayColor;
    _instructionOptions = [[GMSNavigationInstructionOptions alloc] init];
    _instructionOptions.disableLongDistanceFormat = YES;
    _instructionOptions.exitCueBackgroundColor = UIColor.darkGrayColor;
    _instructionOptions.imageOptions.maneuverImageSize = GMSNavigationManeuverImageSizeSquare48;
    _instructionOptions.imageOptions.screenMetrics = window.screen;
    _imageOptions = [[GMSNavigationStepInfoImageOptions alloc] init];
    _imageOptions.screenMetrics = window.screen;

    // Create the buttons that float over the map.
    NSMutableArray<CPMapButton *> *mapButtons = [NSMutableArray<CPMapButton *> array];

    __weak __typeof__(self) weakSelf = self;
    CPMapButton *panButton = [self mapButtonWithSystemImageNamed:@"dpad.fill"
                                                         handler:^(CPMapButton *_) {
                                                           [weakSelf didTapPanButton];
                                                         }];
    [mapButtons addObject:panButton];

    CPMapButton *zoomOutButton =
        [self mapButtonWithSystemImageNamed:@"minus.magnifyingglass"
                                    handler:^(CPMapButton *_Nonnull mapButon) {
                                      [weakSelf didTapZoomOutButton];
                                    }];
    [mapButtons addObject:zoomOutButton];

    CPMapButton *zoomInButton =
        [self mapButtonWithSystemImageNamed:@"plus.magnifyingglass"
                                    handler:^(CPMapButton *_Nonnull mapButon) {
                                      [weakSelf didTapZoomInButton];
                                    }];
    [mapButtons addObject:zoomInButton];

    CPMapButton *myLocationButton =
        [self mapButtonWithSystemImageNamed:@"location"
                                    handler:^(CPMapButton *_Nonnull mapButton) {
                                      [weakSelf didTapMyLocationButton];
                                    }];
    [mapButtons addObject:myLocationButton];
    _mapButtons = mapButtons;

    _mapTemplate.hidesButtonsWithNavigationBar = NO;
    _mapTemplate.automaticallyHidesNavigationBar = YES;
    [self refreshMapButtons];
    [self refreshMapBarButtons];
    window.rootViewController = self;

    CarPlaySharedState *sharedState = CarPlaySharedState.sharedState;
    [sharedState addListener:self];
    self.navigationSession = sharedState.navigationSession;
  }
  return self;
}

#pragma mark - CarPlaySceneController

+ (NSObject<CarPlaySceneController> *)sceneControllerWithWindow:(CPWindow *)window {
  return [[CarPlayApplicationSceneMapController alloc] initWithWindow:window];
}

- (CPTemplate *)carPlayTemplate {
  return _mapTemplate;
}

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.screen = _window.screen;
  options.frame = self.view.bounds;
  _mapView = [[GMSMapView alloc] initWithOptions:options];
  _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _mapView.settings.navigationHeaderEnabled = NO;
  _mapView.settings.navigationFooterEnabled = NO;
  _mapView.settings.showsDestinationMarkers = CarPlaySharedState.sharedState.showDestinationMarkers;
  // Disable buttons: in CarPlay, no part of the map is clickable.
  // The app should instead place these buttons in the appropriate slots of the CarPlay template.
  _mapView.settings.compassButton = NO;
  _mapView.settings.recenterButtonEnabled = NO;

  _mapView.shouldDisplaySpeedometer = NO;
  _mapView.myLocationEnabled = YES;

  [self.view addSubview:_mapView];

  // In a real application, the location feed from the navigation session should be sufficient.
  // However, this demo application sits at the main screen when no sample is running, so set up
  // a CLLocationManager to initialize location in that case.
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;
  [_locationManager startUpdatingLocation];

  // Now synchronize this controller with existing state.
  CarPlaySharedState *sharedState = CarPlaySharedState.sharedState;
  _mapView.roadSnappedMyLocationSource = sharedState.roadSnappedMyLocationSource;
  if (sharedState.destinations.count) {
    [self destinationsDidChangeInState:sharedState];
  }
  if (sharedState.paths.count) {
    [self pathsDidChangeInState:sharedState];
  }
  if (sharedState.selectedDestination) {
    [self selectedDestinationDidChangeInState:sharedState];
  }
  if (sharedState.turnByTurnGuidanceActive) {
    [self turnByTurnGuidanceActiveDidChangeInState:sharedState];
  }
}

#pragma mark - Public Property Implementations

- (void)setNavigationSession:(GMSNavigationSession *)navigationSession {
  if (_internalNavigationSession) {
    [_internalNavigationSession.navigator removeListener:self];
    [_internalNavigationSession.roadSnappedLocationProvider removeListener:self];
    _mapView.roadSnappedMyLocationSource = nil;
  }
  _internalNavigationSession = navigationSession;
  if (_internalNavigationSession) {
    [_internalNavigationSession.navigator addListener:self];
    GMSRoadSnappedLocationProvider *roadSnappedLocationProvider =
        _internalNavigationSession.roadSnappedLocationProvider;
    [roadSnappedLocationProvider addListener:self];
    _mapView.roadSnappedMyLocationSource = roadSnappedLocationProvider;
  }
  [self refreshMapBarButtons];
}

- (CLLocation *)lastLocation {
  return _lastRoadSnappedLocation ?: _lastCoreLocation;
}

- (void)setLastLocation:(CLLocation *)lastLocation isRoadSnapped:(BOOL)isRoadSnapped {
  BOOL lastLocationWasNil = (self.lastLocation == nil);
  if (isRoadSnapped) {
    _lastRoadSnappedLocation = lastLocation;
  } else {
    _lastCoreLocation = lastLocation;
  }
  if (lastLocationWasNil) {
    [self didTapMyLocationButton];
    if (_carPlayNavigationSession && _mapView.navigationEnabled) {
      _mapView.cameraMode = GMSNavigationCameraModeFollowing;
    }
  }
}

#pragma mark - Button Callbacks

- (void)didTapZoomOutButton {
  [_mapView animateWithCameraUpdate:[GMSCameraUpdate zoomOut]];
}

- (void)didTapZoomInButton {
  [_mapView animateWithCameraUpdate:[GMSCameraUpdate zoomIn]];
}

- (void)didTapMyLocationButton {
  CLLocation *location = self.lastLocation;
  if (location) {
    GMSCameraPosition *position =
        [[GMSCameraPosition alloc] initWithTarget:self.lastLocation.coordinate zoom:15.];
    [_mapView animateToCameraPosition:position];
  }
}

- (void)didTapPanButton {
  [_mapTemplate showPanningInterfaceAnimated:YES];
  _isPanningInterfaceEnabled = YES;
  [self refreshMapButtons];
  [self refreshMapBarButtons];
}

- (void)didTapStopPanningButton {
  [_mapTemplate dismissPanningInterfaceAnimated:YES];
  _isPanningInterfaceEnabled = NO;
  [self refreshMapButtons];
  [self refreshMapBarButtons];
}

#pragma mark - CPMapTemplateDelegate

- (void)mapTemplate:(CPMapTemplate *)mapTemplate panBeganWithDirection:(CPPanDirection)direction {
}

- (void)mapTemplate:(CPMapTemplate *)mapTemplate panWithDirection:(CPPanDirection)direction {
  CGPoint scrollAmount = [self scrollAmountForPanDirection:direction];
  GMSCameraUpdate *scroll = [GMSCameraUpdate scrollByX:scrollAmount.x Y:scrollAmount.y];
  [_mapView animateWithCameraUpdate:scroll];
}

- (void)mapTemplate:(CPMapTemplate *)mapTemplate panEndedWithDirection:(CPPanDirection)direction {
}

- (void)mapTemplate:(CPMapTemplate *)mapTemplate
         startedTrip:(CPTrip *)trip
    usingRouteChoice:(CPRouteChoice *)routeChoice {
  id<CarPlaySharedDestination> destination = (id<CarPlaySharedDestination>)trip.userInfo;
  if (destination) {
    [CarPlayConnectionManager.sharedManager goToDestination:destination];
  }
}

- (CPManeuverDisplayStyle)mapTemplate:(CPMapTemplate *)mapTemplate
              displayStyleForManeuver:(nonnull CPManeuver *)maneuver {
  ManeuverUserInfo *userInfo = maneuver.userInfo;
  return userInfo.laneGuidance ? CPManeuverDisplayStyleSymbolOnly : CPManeuverDisplayStyleDefault;
}

- (void)mapTemplateDidBeginPanGesture:(CPMapTemplate *)mapTemplate {
  [_mapView didBeginPanGesture];
}

- (void)mapTemplate:(CPMapTemplate *)mapTemplate
    didUpdatePanGestureWithTranslation:(CGPoint)translation
                              velocity:(CGPoint)velocity {
  [_mapView didUpdatePanGestureWithTranslation:translation velocity:velocity];
}

- (void)mapTemplate:(CPMapTemplate *)mapTemplate didEndPanGestureWithVelocity:(CGPoint)velocity {
  [_mapView didEndPanGestureWithVelocity:velocity];
}

#pragma mark - CarPlaySharedStateListener

- (void)navigationSessionDidChangeInState:(CarPlaySharedState *)state {
  self.navigationSession = state.navigationSession;
}

- (void)roadSnappedMyLocationSourceDidChangeInState:(CarPlaySharedState *)state {
  _mapView.roadSnappedMyLocationSource = state.roadSnappedMyLocationSource;
}

- (void)destinationsDidChangeInState:(CarPlaySharedState *)state {
  for (GMSMarker *oldMarker in _destinationMarkers) {
    oldMarker.map = nil;
  }
  _destinationMarkers = nil;

  NSMutableArray<GMSMarker *> *markers = [NSMutableArray<GMSMarker *> array];
  for (id<CarPlaySharedDestination> destination in state.destinations) {
    if (!destination.isMarker) {
      continue;
    }
    GMSMarker *marker = [GMSMarker markerWithPosition:destination.waypoint.coordinate];
    marker.iconView = destination.iconViewCreator(destination);
    marker.map = _mapView;
    [markers addObject:marker];
  }
  _destinationMarkers = markers;
  [self updateTrips];
}

- (void)selectedDestinationDidChangeInState:(CarPlaySharedState *)state {
  NSObject<CarPlaySharedDestination> *destination = state.selectedDestination;
  if (destination) {
    GMSCameraPosition *cameraPosition =
        [GMSCameraPosition cameraWithTarget:state.selectedDestination.waypoint.coordinate zoom:14];
    [_mapView animateToCameraPosition:cameraPosition];
  }

  [self updateTrips];
  [self updateTripTime];
}

- (void)pathsDidChangeInState:(CarPlaySharedState *)state {
  for (GMSPolyline *oldPolyline in _polylines) {
    oldPolyline.map = nil;
  }
  _polylines = nil;
  NSArray<GMSPath *> *paths = state.paths;
  if (paths) {
    NSMutableArray<GMSPolyline *> *polylines = [NSMutableArray<GMSPolyline *> array];
    for (GMSPath *path in paths) {
      GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
      polyline.map = _mapView;
      [polylines addObject:polyline];
    }
    _polylines = polylines;
  }
}

- (void)turnByTurnGuidanceActiveDidChangeInState:(CarPlaySharedState *)state {
  if (state.turnByTurnGuidanceActive) {
    [self startTurnByTurnNavigation];
  } else {
    [self endTurnByTurnNavigation];
  }
}

#pragma mark - GMSNavigatorListener

- (void)navigator:(GMSNavigator *)navigator didArriveAtWaypoint:(GMSNavigationWaypoint *)waypoint {
  [self endTurnByTurnNavigation];
}

- (void)navigatorDidChangeRoute:(GMSNavigator *)navigator {
}

- (void)navigator:(GMSNavigator *)navigator didUpdateNavInfo:(GMSNavigationNavInfo *)navInfo {
  GMSNavigationNavInfo *oldNavInfo = _currentNavInfo;
  _currentNavInfo = navInfo;
  [self updateUpcomingManeuversFromNavInfo:oldNavInfo toNavInfo:_currentNavInfo];
  [self updateTripTime];
  [self updateCurrentManeuverTime];
}

- (void)navigator:(GMSNavigator *)navigator didUpdateRemainingTime:(NSTimeInterval)time {
  // Note: in this demo, we don't actually have to do any updates here because
  // @c -navigator:didUpdateNavInfo: is called at about the same rate this method is
  // called. If the application does not implement @c -navigator:didUpdateNavInfo: this
  // method can be used.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  CLLocation *lastLocation = locations.lastObject;
  if (lastLocation) {
    [self setLastLocation:lastLocation isRoadSnapped:NO];
  }
}

#pragma mark - GMSRoadSnappedLocationProviderListener

- (void)locationProvider:(GMSRoadSnappedLocationProvider *)locationProvider
       didUpdateLocation:(CLLocation *)location {
  [self setLastLocation:location isRoadSnapped:YES];
}

#pragma mark - Private methods

/**
 * Starts turn-by-turn navigation on the phone screen.
 */
- (void)startTurnByTurnNavigation {
  [self updateTrips];
  [self updateUpcomingManeuversFromNavInfo:nil toNavInfo:_currentNavInfo];
  GMSNavigationSession *navigationSession = CarPlaySharedState.sharedState.navigationSession;
  if (navigationSession && !_mapView.navigationEnabled) {
    _mapView.myLocationEnabled = NO;
    [_mapView enableNavigationWithSession:navigationSession];
    _mapView.cameraMode = GMSNavigationCameraModeFollowing;
  }
}

/**
 * Ends turn-by-turn navigation and returns to previous camera.
 *
 * Can be called either explicitly from the UI or implicitly when arriving.
 */
- (void)endTurnByTurnNavigation {
  if (_mapView.navigationEnabled) {
    _mapView.cameraMode = GMSNavigationCameraModeOverview;
    _mapView.navigationEnabled = NO;
    _mapView.myLocationEnabled = YES;
  }
  [self finishCarPlayNavigationSession];
}

- (void)updateTrips {
  CarPlaySharedState *state = CarPlaySharedState.sharedState;
  NSObject<CarPlaySharedDestination> *selectedDestination = state.selectedDestination;
  NSMutableArray<CPTrip *> *trips = [NSMutableArray<CPTrip *> array];
  _selectedTrip = nil;

  CLLocation *myLocation = _mapView.myLocation;
  MKPlacemark *myLocationPlacemark = [[MKPlacemark alloc] initWithCoordinate:myLocation.coordinate];
  MKMapItem *myLocationItem = [[MKMapItem alloc] initWithPlacemark:myLocationPlacemark];
  myLocationItem.name = @"Your Location";

  for (id<CarPlaySharedDestination> destination in state.destinations) {
    if (!destination.isTrip) {
      continue;
    }
    MKPlacemark *destinationPlacemark =
        [[MKPlacemark alloc] initWithCoordinate:destination.waypoint.coordinate];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    destinationItem.name = destination.waypoint.title;

    CPRouteChoice *routeChoice =
        [[CPRouteChoice alloc] initWithSummaryVariants:@[ @"Default" ]
                         additionalInformationVariants:@[ @"Fastest route" ]
                              selectionSummaryVariants:@[ @"" ]];
    CPTrip *trip = [[CPTrip alloc] initWithOrigin:myLocationItem
                                      destination:destinationItem
                                     routeChoices:@[ routeChoice ]];
    trip.userInfo = destination;
    [trips addObject:trip];
    if (destination == selectedDestination) {
      _selectedTrip = trip;
    }
  }
  if (_selectedTrip && !_carPlayNavigationSession) {
    [_mapTemplate hideTripPreviews];
    _carPlayNavigationSession = [_mapTemplate startNavigationSessionForTrip:_selectedTrip];
  } else if (trips.count && !_selectedTrip) {
    [_mapTemplate showTripPreviews:trips selectedTrip:_selectedTrip textConfiguration:nil];
  } else {
    [_mapTemplate hideTripPreviews];
  }

  if (_selectedTrip) {
    GMSCoordinateBounds *viewBounds = [[GMSCoordinateBounds alloc]
        initWithCoordinate:_selectedTrip.origin.placemark.location.coordinate
                coordinate:_selectedTrip.destination.placemark.location.coordinate];
    GMSMutableCameraPosition *cameraPosition =
        [[_mapView cameraForBounds:viewBounds insets:UIEdgeInsetsZero] mutableCopy];
    // On CarPlay, we need a little extra room.
    cameraPosition.zoom = cameraPosition.zoom - 1;
    if (cameraPosition) {
      [_mapView animateToCameraPosition:cameraPosition];
    }
  }
}

- (nonnull CPManeuver *)maneuverForStep:(nonnull GMSNavigationStepInfo *)stepInfo {
  CPManeuver *maneuver = [[CPManeuver alloc] init];
  maneuver.userInfo = [[ManeuverUserInfo alloc] initWithStepInfo:stepInfo isLaneGuidance:NO];
  switch (stepInfo.maneuver) {
    case GMSNavigationManeuverDestination:
      maneuver.instructionVariants = @[ @"Your destination is ahead." ];
      break;
    case GMSNavigationManeuverDestinationLeft:
      maneuver.instructionVariants = @[ @"Your destination is ahead on your left." ];
      break;
    case GMSNavigationManeuverDestinationRight:
      maneuver.instructionVariants = @[ @"Your destination is ahead on your right." ];
      break;
    default: {
      maneuver.attributedInstructionVariants =
          [_currentNavInfo instructionsForStep:stepInfo options:_instructionOptions];
      break;
    }
  }
  maneuver.symbolImage = [stepInfo maneuverImageWithOptions:_instructionOptions.imageOptions];
  return maneuver;
}

- (nullable CPManeuver *)laneGuidanceManeuverForStep:(nonnull GMSNavigationStepInfo *)stepInfo {
  CPManeuver *maneuver = [[CPManeuver alloc] init];
  maneuver.userInfo = [[ManeuverUserInfo alloc] initWithStepInfo:stepInfo isLaneGuidance:YES];
  UIImage *lanesImage = [stepInfo lanesImageWithOptions:_imageOptions];
  if (!lanesImage) {
    return nil;
  }
  maneuver.symbolImage = lanesImage;
  return maneuver;
}

- (void)updateUpcomingManeuversFromNavInfo:(nullable GMSNavigationNavInfo *)oldNavInfo
                                 toNavInfo:(nullable GMSNavigationNavInfo *)newNavInfo {
  if (CarPlaySharedState.sharedState.turnByTurnGuidanceActive && newNavInfo) {
    GMSNavigationNavInfo *_Nonnull navInfo = (GMSNavigationNavInfo *_Nonnull)newNavInfo;
    if (oldNavInfo) {
      GMSNavigationNavInfo *_Nonnull prevNavInfo = (GMSNavigationNavInfo *_Nonnull)oldNavInfo;
      if (NavInfosHaveSameSteps(prevNavInfo, navInfo)) {
        return;
      }
    }

    NSMutableArray<CPManeuver *> *maneuvers = [NSMutableArray array];
    GMSNavigationStepInfo *_Nullable currentStepInfo = navInfo.currentStep;
    if (currentStepInfo) {
      GMSNavigationStepInfo *_Nonnull step = (GMSNavigationStepInfo *_Nonnull)currentStepInfo;
      CPManeuver *maneuver = [self maneuverForStep:step];
      [maneuvers addObject:maneuver];
      CPManeuver *_Nullable laneGuidanceManeuver = [self laneGuidanceManeuverForStep:step];
      if (laneGuidanceManeuver) {
        [maneuvers addObject:(CPManeuver *_Nonnull)laneGuidanceManeuver];
      } else {
        // If there's no lane guidance, see if there's a following step to preview.
        GMSNavigationStepInfo *nextStep = navInfo.remainingSteps.firstObject;
        if (nextStep && nextStep.distanceFromPrevStepMeters < kShowNextManeuverMaxDistanceMeters &&
            nextStep.timeFromPrevStepSeconds < kShowNextManeuverMaxTimeSeconds) {
          [maneuvers addObject:[self maneuverForStep:nextStep]];
        }
      }
    }

    for (CPManeuver *maneuver in maneuvers) {
      CPTravelEstimates *travelEstimates = TravelEstimates(
          navInfo, navInfo.distanceToCurrentStepMeters, navInfo.timeToCurrentStepSeconds);
      maneuver.initialTravelEstimates = travelEstimates;
    }

    _carPlayNavigationSession.upcomingManeuvers = maneuvers;
  } else {
    _carPlayNavigationSession.upcomingManeuvers = @[];
  }
}

- (void)updateCurrentManeuverTime {
  if (_selectedTrip && _carPlayNavigationSession && _currentNavInfo &&
      CarPlaySharedState.sharedState.turnByTurnGuidanceActive) {
    GMSNavigationStepInfo *step = _currentNavInfo.currentStep;
    CPManeuver *firstManeuver = _carPlayNavigationSession.upcomingManeuvers.firstObject;
    ManeuverUserInfo *userInfo = firstManeuver.userInfo;
    GMSNavigationStepInfo *currentStep = userInfo.stepInfo;
    if (step && firstManeuver && step == currentStep) {
      CPTravelEstimates *travelEstimates = nil;
      if (step.maneuver != GMSNavigationManeuverDepart) {
        travelEstimates =
            TravelEstimates(_currentNavInfo, _currentNavInfo.distanceToCurrentStepMeters, 0);
        [_carPlayNavigationSession updateTravelEstimates:travelEstimates forManeuver:firstManeuver];
      }
    }
  }
}

- (void)updateTripTime {
  if (_selectedTrip && _carPlayNavigationSession && _currentNavInfo) {
    CPTravelEstimates *travelEstimates =
        TravelEstimates(_currentNavInfo, _currentNavInfo.distanceToFinalDestinationMeters,
                        _currentNavInfo.timeToFinalDestinationSeconds);
    [_mapTemplate updateTravelEstimates:travelEstimates forTrip:_carPlayNavigationSession.trip];
  }
}

- (void)finishCarPlayNavigationSession {
  if (_carPlayNavigationSession) {
    [_carPlayNavigationSession finishTrip];
    _carPlayNavigationSession = nil;
  }
}

- (void)refreshMapButtons {
  if (_isPanningInterfaceEnabled) {
    _mapTemplate.mapButtons = @[];
  } else {
    _mapTemplate.mapButtons = _mapButtons;
  }
}

- (void)refreshMapBarButtons {
  __weak __typeof__(self) weakSelf = self;

  NSMutableArray<CPBarButton *> *trailingNavigationBarButtons =
      [NSMutableArray<CPBarButton *> array];
  if (_isPanningInterfaceEnabled) {
    CPBarButton *stopPanning =
        [[CPBarButton alloc] initWithTitle:@"Done"
                                   handler:^(CPBarButton *_Nonnull mapButton) {
                                     [weakSelf didTapStopPanningButton];
                                   }];
    [trailingNavigationBarButtons addObject:stopPanning];
  }
  _mapTemplate.trailingNavigationBarButtons = trailingNavigationBarButtons;
}

- (CGPoint)scrollAmountForPanDirection:(CPPanDirection)direction {
  static const CGFloat scrollDistance = 80.;
  CGPoint scrollAmount = {0., 0.};
  if (direction & CPPanDirectionLeft) {
    scrollAmount.x = -scrollDistance;
  }
  if (direction & CPPanDirectionRight) {
    scrollAmount.x = scrollDistance;
  }
  if (direction & CPPanDirectionUp) {
    scrollAmount.y = -scrollDistance;
  }
  if (direction & CPPanDirectionDown) {
    scrollAmount.y = scrollDistance;
  }
  if (scrollAmount.x != 0 && scrollAmount.y != 0) {
    // Adjust length if scrolling diagonally.
    scrollAmount =
        CGPointMake(scrollAmount.x * (CGFloat)M_SQRT1_2, scrollAmount.y * (CGFloat)M_SQRT1_2);
  }
  return scrollAmount;
}

- (CPMapButton *)mapButtonWithSystemImageNamed:(NSString *)systemImageName
                                       handler:(CPMapButtonHandler)handler {
  CPMapButton *mapButton = [[CPMapButton alloc] initWithHandler:handler];
  UIImage *buttonImage = [self mapButtonImageWithSystemImageNamed:systemImageName];
  mapButton.image = buttonImage;
  mapButton.hidden = NO;
  mapButton.enabled = YES;
  return mapButton;
}

/** Returns a circular map button image with the given icon inset in the middle. */
- (UIImage *)mapButtonImageWithSystemImageNamed:(NSString *)systemImageName {
  UIImage *iconImage = [UIImage systemImageNamed:systemImageName];
  UIImage *tintedImage = [iconImage imageWithTintColor:UIColor.systemBlueColor];

  CGRect bounds = CGRectMake(0., 0., 50., 50.);
  /** Inset circle so anti-aliased edges won't be clipped. */
  CGRect circleBounds = CGRectInset(bounds, 1, 1);

  UIGraphicsBeginImageContextWithOptions(bounds.size, NO, iconImage.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();

  [UIColor.systemBackgroundColor setFill];
  CGContextFillEllipseInRect(context, circleBounds);

  [UIColor.linkColor setFill];
  CGRect iconRect = CGRectInset(bounds, 14., 14.);
  [tintedImage drawInRect:iconRect blendMode:kCGBlendModeNormal alpha:1.0];

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end
