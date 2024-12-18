// Copyright 2024 Google LLC. All rights reserved.
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

import Foundation
import GoogleMaps

/// Delegate class that handles map interaction events from GMSMapView
/// Provides callback support for map taps and marker taps through closure handlers
class GoogleMapViewDelegate: NSObject, GMSMapViewDelegate {
    
   var tapHandler: ((CLLocationCoordinate2D) -> Void)?
   var markerTapHandler: ((GMSMarker) -> Bool)?
   
   /// Called by GMSMapView when user taps the map at a specific coordinate
   /// - Parameters:
   ///   - mapView: The GMSMapView that detected the tap
   ///   - coordinate: The geographic coordinate where the tap occurred
   func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
       tapHandler?(coordinate) // Forward tap to handler if one is set
   }
   
   /// Called by GMSMapView when user taps a marker on the map
   /// - Parameters:
   ///   - mapView: The GMSMapView that detected the tap
   ///   - marker: The GMSMarker that was tapped
   /// - Returns: true if tap was handled by the app, false to allow default marker behavior
   func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
       return markerTapHandler?(marker) ?? false // Forward to handler or use default behavior
   }
}
