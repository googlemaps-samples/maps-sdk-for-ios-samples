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

#import "GoogleMapsDemos/BetaSamples/CollidingMarkersViewController.h"

#import <GoogleMaps/GoogleMaps.h>

const CLLocationCoordinate2D kSeattleCoordinates = {.latitude = 47.6098, .longitude = -122.34};

/**
 * Demonstrates basic usage of the marker collision feature.
 * Try zooming in/out, and dragging around different colored markers.
 */
@implementation CollidingMarkersViewController {
  GMSMapView *_mapView;
}

/**
 * These are the "standard" markers - they will show up no matter what, and they don't have
 * intersection or collision checking with map labels or other markers.
 */
- (GMSMarker *)createNonCollidingMarkerWithLatitude:(CLLocationDegrees)latitude
                                          longitude:(CLLocationDegrees)longitude
                                             zIndex:(int)zIndex {
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.title = @"Non-Colliding";
  marker.snippet = [NSString stringWithFormat:@"zIndex: %d", zIndex];
  marker.zIndex = zIndex;
  marker.draggable = YES;
  marker.position = CLLocationCoordinate2DMake(latitude, longitude);
  marker.icon = [GMSMarker markerImageWithColor:UIColor.blueColor];
  // No need for setting collision behavior since it's the default behavior, but setting to
  // GMSCollisionBehaviorRequired also works.
  return marker;
}

/**
 * These markers will show up if they aren't intersecting anything higher priority (required or
 * higher zIndex optional markers), and they will hide intersecting normal map labels or lower
 * zIndex optional markers.
 *
 * Note: While an optional marker is in the middle of being dragged, it is considered higher
 * priority than other optional markers, regardless of zIndex. But once it has been dropped,
 * priority goes back to zIndices.
 */
- (GMSMarker *)createOptionalMarkerWithLatitude:(CLLocationDegrees)latitude
                                      longitude:(CLLocationDegrees)longitude
                                         zIndex:(int)zIndex {
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.title = @"Optional";
  marker.snippet = [NSString stringWithFormat:@"zIndex: %d", zIndex];
  marker.zIndex = zIndex;
  marker.draggable = YES;
  marker.position = CLLocationCoordinate2DMake(latitude, longitude);
  marker.icon = [GMSMarker markerImageWithColor:UIColor.greenColor];
  marker.collisionBehavior = GMSCollisionBehaviorOptionalAndHidesLowerPriority;
  return marker;
}

/**
 * These markers will always show up, and they will hide intersecting normal map labels or
 * optional markers.
 */
- (GMSMarker *)createRequiredMarkerWithLatitude:(CLLocationDegrees)latitude
                                      longitude:(CLLocationDegrees)longitude
                                         zIndex:(int)zIndex {
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.title = @"Required";
  marker.snippet = [NSString stringWithFormat:@"zIndex: %d", zIndex];
  marker.zIndex = zIndex;
  marker.draggable = YES;
  marker.position = CLLocationCoordinate2DMake(latitude, longitude);
  marker.collisionBehavior = GMSCollisionBehaviorRequiredAndHidesOptional;
  return marker;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:kSeattleCoordinates zoom:16];

  _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
  _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_mapView];

  CLLocationCoordinate2D requiredCollidingFirstPosition = {
      .latitude = kSeattleCoordinates.latitude - 0.002,
      .longitude = kSeattleCoordinates.longitude - 0.003};
  CLLocationCoordinate2D requiredNonCollidingFirstPosition = {
      .latitude = kSeattleCoordinates.latitude, .longitude = kSeattleCoordinates.longitude - 0.003};
  CLLocationCoordinate2D optionalFirstPosition = {.latitude = kSeattleCoordinates.latitude - 0.001,
                                                  .longitude = kSeattleCoordinates.longitude};

  CLLocationDegrees markerSpacing = 0.004;
  int markerCount = 0;

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      GMSMarker *nonColliding =
          [self createNonCollidingMarkerWithLatitude:requiredNonCollidingFirstPosition.latitude +
                                                     (i * markerSpacing)
                                           longitude:requiredNonCollidingFirstPosition.longitude +
                                                     (j * markerSpacing)
                                              zIndex:markerCount++];
      nonColliding.map = _mapView;
      GMSMarker *optional = [self
          createOptionalMarkerWithLatitude:optionalFirstPosition.latitude + (i * markerSpacing)
                                 longitude:optionalFirstPosition.longitude + (j * markerSpacing)
                                    zIndex:markerCount++];
      optional.map = _mapView;
      GMSMarker *required =
          [self createRequiredMarkerWithLatitude:requiredCollidingFirstPosition.latitude +
                                                 (i * markerSpacing)
                                       longitude:requiredCollidingFirstPosition.longitude +
                                                 (j * markerSpacing)
                                          zIndex:markerCount++];
      required.map = _mapView;
    }
  }
}
@end
