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

#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySharedState.h"

#import <Foundation/Foundation.h>

@implementation CarPlaySharedState {
  // Mutable set of listeners, held weakly.
  NSHashTable<NSObject<CarPlaySharedStateListener> *> *_listeners;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _listeners = [NSHashTable<NSObject<CarPlaySharedStateListener> *> weakObjectsHashTable];
  }
  return self;
}

#pragma mark - Public methods

+ (CarPlaySharedState *)sharedState {
  static CarPlaySharedState *sharedState;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedState = [[CarPlaySharedState alloc] init];
  });
  return sharedState;
}

- (void)addListener:(NSObject<CarPlaySharedStateListener> *)listener {
  [_listeners addObject:listener];
}

- (void)removeListener:(NSObject<CarPlaySharedStateListener> *)listener {
  [_listeners removeObject:listener];
}

#pragma mark - Public property implementations

- (void)setEnabled:(BOOL)enabled {
  if (enabled != _enabled) {
    _enabled = enabled;
    if (!_enabled) {
      _navigationSession = nil;
      _roadSnappedMyLocationSource = nil;
      _destinations = nil;
      _paths = nil;
      _showDestinationMarkers = NO;
    }
    for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
      if ([listener respondsToSelector:@selector(enabledDidChangeInState:)]) {
        [listener enabledDidChangeInState:self];
      }
    }
  }
}

- (void)setNavigationSession:(GMSNavigationSession *)navigationSession {
  if (navigationSession != _navigationSession) {
    _navigationSession = navigationSession;
    for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
      if ([listener respondsToSelector:@selector(navigationSessionDidChangeInState:)]) {
        [listener navigationSessionDidChangeInState:self];
      }
    }
  }
}

- (void)setRoadSnappedMyLocationSource:
    (GMSRoadSnappedLocationProvider *)roadSnappedLocationProvider {
  if (roadSnappedLocationProvider != _roadSnappedMyLocationSource) {
    _roadSnappedMyLocationSource = roadSnappedLocationProvider;
    for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
      if ([listener respondsToSelector:@selector(roadSnappedMyLocationSourceDidChangeInState:)]) {
        [listener roadSnappedMyLocationSourceDidChangeInState:self];
      }
    }
  }
}

- (void)setDestinations:(NSArray<NSObject<CarPlaySharedDestination> *> *)destinations {
  NSObject<CarPlaySharedDestination> *selectedDestination = _selectedDestination;
  if (selectedDestination) {
    if (![destinations containsObject:selectedDestination]) {
      self.selectedDestination = nil;
    }
  }
  _destinations = destinations;
  for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
    if ([listener respondsToSelector:@selector(destinationsDidChangeInState:)]) {
      [listener destinationsDidChangeInState:self];
    }
  }
}

- (void)setSelectedDestination:(NSObject<CarPlaySharedDestination> *)selectedDestination {
  if (selectedDestination == _selectedDestination) {
    return;
  }

  // Verify invariants (selectedDestination must be in destinations).
  if (selectedDestination) {
    if (![_destinations containsObject:selectedDestination]) {
      return;
    }
  }

  _selectedDestination = selectedDestination;
  for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
    if ([listener respondsToSelector:@selector(selectedDestinationDidChangeInState:)]) {
      [listener selectedDestinationDidChangeInState:self];
    }
  }
}

- (void)setPaths:(NSArray<GMSPath *> *)paths {
  _paths = paths;
  for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
    if ([listener respondsToSelector:@selector(pathsDidChangeInState:)]) {
      [listener pathsDidChangeInState:self];
    }
  }
}

- (void)setTurnByTurnGuidanceActive:(BOOL)turnByTurnGuidanceActive {
  _turnByTurnGuidanceActive = turnByTurnGuidanceActive;
  for (NSObject<CarPlaySharedStateListener> *listener in _listeners.allObjects) {
    if ([listener respondsToSelector:@selector(turnByTurnGuidanceActiveDidChangeInState:)]) {
      [listener turnByTurnGuidanceActiveDidChangeInState:self];
    }
  }
}

@end
