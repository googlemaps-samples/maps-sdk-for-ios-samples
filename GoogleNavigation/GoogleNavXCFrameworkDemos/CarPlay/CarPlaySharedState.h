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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif

@class GMSNavigationSession;
@class GMSNavigationWaypoint;
@class GMSPath;
@class GMSRoadSnappedLocationProvider;
@protocol CarPlaySharedDestination;
@protocol CarPlaySharedStateListener;

NS_ASSUME_NONNULL_BEGIN

/** Typedef for blocks which can create the iconView for a destination. */
typedef UIView *_Nonnull (^CarPlaySharedDestinationIconViewCreationBlock)(
    id<CarPlaySharedDestination> _Nonnull);

/**
 * Objects that conform to this protocol represent a potential destination shared between the
 * nav_demo samples which support CarPlay and the controllers for the various CarPlay scenes.
 * The CarPlay scenes may use these destinations for several purposes:
 * - If the @c isMarker property is YES, the destination will be displayed as a marker on the map,
 *   for scenes where a map is shown.
 * - If the @c isTrip property is YES, a CarPlay trip will be constructed from the current
 *   location to the destination and offered as a potential trip in scenes that support trips.
 */
@protocol CarPlaySharedDestination

/** The waypoint for the destination. */
@property(nonatomic, readonly, nonnull) GMSNavigationWaypoint *waypoint;

/** Whether this destination should be displayed as a marker on the CarPlay map. */
@property(nonatomic, readonly) BOOL isMarker;

/** Whether going to this destination should be offered as a potential trip. */
@property(nonatomic, readonly) BOOL isTrip;

#pragma mark - Marker-related properties

/**
 * A block which returns the iconView to be used to represent the destination on the map.
 *
 * If set, this is used in preference to @c icon.
 */
@property(nonatomic, readonly, nullable)
    CarPlaySharedDestinationIconViewCreationBlock iconViewCreator;

/** The image which should be used to show the destination on the map. */
@property(nonatomic, readonly, nullable) UIImage *icon;

/** The groundAnchor which should be used to show the destination on the map. */
@property(nonatomic, readonly) CGPoint groundAnchor;

@end

/**
 * This class shares application state with the currently connected CarPlay scene(s).
 * It is responsible for the flow of data from the core logic implemented on the mobile
 * device to the zero or more CarPlay scene controllers.
 *
 * The connected CarPlay scene(s) listen to updates in this shared state in order to display
 * the appropriate CarPlay interface.
 *
 * nav_demo samples which support CarPlay should update this shared state to reflect user
 * actions in the application. Such samples should also become the delegate of the
 * @c CarPlayConnectionManager in order to track to connected status of CarPlay
 * and any incoming requests from the CarPlay UI.
 */
@interface CarPlaySharedState : NSObject

/** Access to shared instance of this state. */
@property(nonatomic, readonly, nonnull, class) CarPlaySharedState *sharedState;

/** Adds the given listener to the set of listeners. Listeners are held weakly. */
- (void)addListener:(NSObject<CarPlaySharedStateListener> *)listener;

/** Removes the given listener from the set of listeners. */
- (void)removeListener:(NSObject<CarPlaySharedStateListener> *)listener;

#pragma mark - Properties which should be set by the currently running sample

/**
 * Whether the currently running sample supports CarPlay.
 *
 * If this is set to NO, all CarPlay scenes should present a minimal, non-map UI.
 * The top-level view controller for the nav_demo application initializes this value
 * to NO whenever no sample is running. Setting this to NO resets all other properties.
 */
@property(nonatomic) BOOL enabled;

/** The current navigation session, if it exists. */
@property(nonatomic, nullable) GMSNavigationSession *navigationSession;

/** The roadSnappedLocationSource that should be used for my location on map views. */
@property(nonatomic, nullable) GMSRoadSnappedLocationProvider *roadSnappedMyLocationSource;

/**
 * A list of potential navigation destinations. If this is non-empty, CarPlay scenes
 * which are able to do so should show a list of destinations and allow the user to
 * select one.
 */
@property(nonatomic, copy, nullable) NSArray<NSObject<CarPlaySharedDestination> *> *destinations;

/** The selected destination. If set, this must be one of the destinations in @c destinations. */
@property(nonatomic, nullable) NSObject<CarPlaySharedDestination> *selectedDestination;

/** Paths that should be displayed on the map, if any. */
@property(nonatomic, copy, nullable) NSArray<GMSPath *> *paths;

/** Whether turn-by-turn guidance is active. */
@property(nonatomic, getter=isTurnByTurnGuidanceActive) BOOL turnByTurnGuidanceActive;

/** Whether destination markers are active. The default for this value is NO. */
@property(nonatomic) BOOL showDestinationMarkers;

@end

/**
 * Callback methods from CarPlaySharedState.
 *
 * Listener methods are only dispatched if the value actually changes (i.e., setting a
 * property to its current value will not notify listeners).
 */
@protocol CarPlaySharedStateListener

@optional

/** Called when the @c enabled property changes value. */
- (void)enabledDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c navigationSession property changes value. */
- (void)navigationSessionDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c roadSnappedMyLocationSource property changes value. */
- (void)roadSnappedMyLocationSourceDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c destinations property changes value. */
- (void)destinationsDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c selectedDestination property changes value. */
- (void)selectedDestinationDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c paths property changes value. */
- (void)pathsDidChangeInState:(CarPlaySharedState *)state;

/** Called when the @c turnByTurnGuidanceActive property changes value. */
- (void)turnByTurnGuidanceActiveDidChangeInState:(CarPlaySharedState *)state;

@end

NS_ASSUME_NONNULL_END
