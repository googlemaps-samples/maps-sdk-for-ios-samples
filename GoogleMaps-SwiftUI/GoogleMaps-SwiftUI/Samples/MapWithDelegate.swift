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

struct MapWithDelegate: View {
    
    @State private var mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        // Initialize map centered on San Francisco
        options.camera = .camera(.seattle)
                
        // Or with custom zoom level for closer view
        // options.camera = .camera(.sanFrancisco, zoom: 15)
        return options
    }()
    
   var body: some View {
       
       // Handle tap events with latitude/longitude coordinates
       GoogleMapView(options: $mapOptions)
           .onMapTapped { coordinate in
              print("Map tapped at: \(coordinate.latitude), \(coordinate.longitude)")
           }
           .ignoresSafeArea()  // Makes the map fill the entire screen
   }
}
