// Copyright 2026 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import GoogleMaps

/// Protocol for managing Google Maps SDK usage attribution for sample applications.
protocol GoogleMapsAttributionManaging {
  /// Adds attribution tracking for the specified view controller.
  /// - Parameter viewController: The view controller to track attribution for.
  func addAttribution(for viewController: UIViewController)
}

/// Default implementation of GoogleMapsAttributionManaging that automatically
/// generates attribution IDs based on view controller class names.
final class GoogleMapsAttributionManager: GoogleMapsAttributionManaging {
  /// Adds attribution tracking by deriving a sample name from the view controller's class name.
  ///
  /// The attribution ID follows the format: `gmp_git_iosmapssamples_v{majorVersion}_{sampleName}`
  /// where `sampleName` is the class name with "ViewController" suffix removed and lowercased.
  ///
  /// Example: `BasicMapViewController` becomes `basicmap`
  ///
  /// - Parameter viewController: The view controller to generate attribution for.
  func addAttribution(for viewController: UIViewController) {
    let majorVersion = GMSServices.sdkVersion().components(separatedBy: ".").first ?? "10"
    let className = String(describing: type(of: viewController))
    let sampleName = className.replacingOccurrences(of: "ViewController", with: "").lowercased()
    let attributionID = "gmp_git_iosmapssamples_v\(majorVersion)_\(sampleName)"
    GMSServices.addInternalUsageAttributionID(attributionID)
  }
}
