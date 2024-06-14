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

#import "GoogleNavXCFrameworkDemos/Utils/NavDemoStringUtils.h"

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

NSString *GMSNavigationDemoMessageForRouteStatus(GMSRouteStatus routeStatus) {
  switch (routeStatus) {
    case GMSRouteStatusOK:
      return @"Route status OK";
    case GMSRouteStatusNoRouteFound:
      return @"Error: No route found";
    case GMSRouteStatusNetworkError:
      return @"Error: Network error";
    case GMSRouteStatusQuotaExceeded:
      return @"Error: Insufficient quota";
    case GMSRouteStatusAPIKeyNotAuthorized:
      return @"Error: API key not authorized";
    case GMSRouteStatusCanceled:
      return @"Route request canceled, possibly due to a newer request";
    case GMSRouteStatusLocationUnavailable:
      return @"Error: Location unavailable";
    case GMSRouteStatusDuplicateWaypointsError:
      return @"Error: Duplicate waypoints were present in the request";
    case GMSRouteStatusNoWaypointsError:
      return @"Error: No waypoints were provided in the request";
    case GMSRouteStatusInternalError:
      return @"Error: Internal error";
    case GMSRouteStatusWaypointError:
      return @"Error: Waypoint error";
    case GMSRouteStatusTravelModeUnsupported:
      return @"Error: Unsupported travel mode";
  }
}

NSString *GMSMapViewTypeToString(GMSMapViewType mapViewType) {
  switch (mapViewType) {
    case kGMSTypeHybrid:
      return @"Hybrid";
    case kGMSTypeNormal:
      return @"Normal";
    case kGMSTypeTerrain:
      return @"Terrain";
    case kGMSTypeSatellite:
      return @"Satellite";
    case kGMSTypeNone:
      return @"None";
  }
}
