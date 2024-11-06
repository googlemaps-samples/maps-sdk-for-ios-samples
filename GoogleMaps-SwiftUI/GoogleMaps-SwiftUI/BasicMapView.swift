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

import SwiftUI
import GoogleMaps

struct BasicMapView: View {
    
    @State private var mapOptions = {
       // 1. Create new options
       var options = GMSMapViewOptions()
       
       // 2. Set the camera position
       options.camera = GMSCameraPosition.camera(
           withLatitude: 37.7749,
           longitude: -122.4194,
           zoom: 12
       )
       
       // 3. Return the configured options
       return options
    }()
    
    // Single marker example
    let singleMarker = [
       GMSMarker(position: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    ]

   var body: some View {
      /*
        The $ prefix creates a two-way binding to mapOptions. This means:
         1. GoogleMapView can read the current mapOptions
         2. GoogleMapView can update mapOptions if the map state changes
         3. Changes to mapOptions in BasicMapView will update the map
         4. Changes to the map will update mapOptions in BasicMapView
      */
       GoogleMapView(options: $mapOptions)
           .mapMarkers(singleMarker)
           .edgesIgnoringSafeArea(.all)  // Makes the map fill the entire screen
   }
}
