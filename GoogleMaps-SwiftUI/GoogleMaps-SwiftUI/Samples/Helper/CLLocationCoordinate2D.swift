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
import CoreLocation

/// Extension to CLLocationCoordinate2D providing convenient preset coordinates
/// for common locations. Simplifies marker placement and location references.
extension CLLocationCoordinate2D {
   /// San Francisco, California - Tech hub of the West Coast
   /// Centered approximately on the Financial District
   static let sanFrancisco = CLLocationCoordinate2D(
       latitude: 37.7749,
       longitude: -122.4194
   )
    
/// Fisherman's Wharf - Historic waterfront district
   /// Famous for seafood restaurants and tourist attractions
   static let fishermansWharf = CLLocationCoordinate2D(
       latitude: 37.8080,
       longitude: -122.4177
   )
   
   /// Ferry Building - Historic transportation and food marketplace
   /// Iconic landmark on the Embarcadero waterfront
   static let ferryBuilding = CLLocationCoordinate2D(
       latitude: 37.7955,
       longitude: -122.3937
   )
   
   /// Chinatown Gate - Entry to largest Chinatown outside of Asia
   /// Located at Grant Avenue and Bush Street
   static let chinatownGate = CLLocationCoordinate2D(
       latitude: 37.7908,
       longitude: -122.4058
   )
   
   /// Coit Tower - Art Deco tower on Telegraph Hill
   /// Offers panoramic views of the city and bay
   static let coitTower = CLLocationCoordinate2D(
       latitude: 37.8024,
       longitude: -122.4058
   )
   
   /// New York City, New York - Centered on Lower Manhattan
   /// Financial District and nearby landmarks
   static let newYork = CLLocationCoordinate2D(
       latitude: 40.7128,
       longitude: -74.0060
   )
   
   // Add more locations as needed. Example format:
   /// /// City Name, State/Country - Brief description
   /// /// Notable landmarks or area description
   /// static let cityName = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
}
