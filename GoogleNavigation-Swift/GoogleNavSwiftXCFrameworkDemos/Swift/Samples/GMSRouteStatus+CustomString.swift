/// Copyright 2020 Google LLC. All rights reserved.
///
///
/// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
/// file except in compliance with the License. You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software distributed under
/// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
/// ANY KIND, either express or implied. See the License for the specific language governing
/// permissions and limitations under the License.

import GoogleNavigation

extension GMSRouteStatus: CustomStringConvertible {
  /// A message to describe the `GMSRouteStatus`.
  public var description: String {
    switch self {
    case .OK:
      return "Route status OK"
    case .noRouteFound:
      return "Error: No route found"
    case .networkError:
      return "Error: Network error"
    case .quotaExceeded:
      return "Error: Insufficient quota"
    case .apiKeyNotAuthorized:
      return "Error: API key not authorized"
    case .canceled:
      return "Route request canceled, possibly due to a newer request"
    case .locationUnavailable:
      return "Error: Location unavailable"
    case .duplicateWaypointsError:
      return "Error: Duplicate waypoints were present in the request"
    case .noWaypointsError:
      return "Error: No waypoints were provided in the request"
    case .internalError:
      return "Error: Internal error"
    case .waypointError:
      return "Error: Waypoint error"
    case .travelModeUnsupported:
      return "Error: Unsupported travel mode"
    @unknown default:
      return "Unknown route status: \(self)"
    }
  }
}
