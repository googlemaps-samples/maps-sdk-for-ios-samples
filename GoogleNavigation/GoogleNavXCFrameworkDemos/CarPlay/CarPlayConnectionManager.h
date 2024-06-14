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

@protocol CarPlayConnectionManagerDelegate;
@protocol CarPlaySharedDestination;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class is responsible for the flow of information and requests from the zero or more
 * currently connected CarPlay scenes to the currently running demo sample code. The information
 * sent includes:
 * - The connection status of the CarPlay scene(s).
 * - Any requested state updates (which were initiated by the user interacting with CarPlay).
 *
 * Samples that support CarPlay connectivity should set themselves as the delegate of this object
 * and respond to delegate methods appropriately.  They should also keep the shared state defined
 * by the @c CarPlaySharedState object updated.
 */
@interface CarPlayConnectionManager : NSObject

/** The shared instance of this connection manager. */
@property(nonatomic, readonly, nonnull, class) CarPlayConnectionManager *sharedManager;

/**
 * Delegate which will be notified of changes to this state.
 *
 * This is typically the current active sample in the nav_demo application.
 */
@property(nonatomic, weak) NSObject<CarPlayConnectionManagerDelegate> *delegate;

/**
 * Whether or not the CarPlay application scene is connected. This should be set
 * by the CarPlay scene when the application scene is connected or disconnected.
 */
@property(nonatomic) BOOL applicationSceneActive;

#pragma mark - Requests from the CarPlay UI to the current sample

/** Called when the user hits the back button on the CarPlay interface. */
- (void)back;

/** Called by a CarPlay scene to request the sample show the TOS dialog on the mobile device. */
- (void)showTOS;

/** Called by a CarPlay scene to request going to a destination. */
- (void)goToDestination:(id<CarPlaySharedDestination>)destination;

@end

/** The protocol defining callback messages from CarPlayConnectionManager. */
@protocol CarPlayConnectionManagerDelegate

/**
 * Called when a CarPlay scene requests to go back (i.e., end the current sample).
 *
 * All samples which support CarPlay must implement this method.
 */
- (void)didRequestBackWithConnectionManager:(CarPlayConnectionManager *)connectionManager;

@optional

/** Called when the application scene active value changes. */
- (void)connectionManager:(CarPlayConnectionManager *)connectionManager
    didChangeApplicationActive:(BOOL)active;

/** Called when the user taps on the Go button for a trip derived from the given destination. */
- (void)connectionManager:(CarPlayConnectionManager *)connectionManager
    didRequestGoToDestination:(id<CarPlaySharedDestination>)destination;

@end

NS_ASSUME_NONNULL_END
