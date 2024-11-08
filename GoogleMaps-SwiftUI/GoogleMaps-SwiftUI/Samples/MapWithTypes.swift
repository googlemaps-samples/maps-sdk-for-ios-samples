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

struct MapWithTypes: View {
    
    @State private var mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        // Initialize map centered on San Francisco
        options.camera = .camera(.sanFrancisco)
        
        // Or with custom zoom level for closer view
        // options.camera = .camera(.sanFrancisco, zoom: 15)
        return options
    }()
    
   var body: some View {
  
       // Available map types:
       // .normal - Standard road map with streets, political boundaries, and labels
       // .satellite - Satellite imagery without street labels or overlays
       // .terrain - Topographic data showing elevation, vegetation, and natural features
       // .hybrid - Satellite imagery combined with road overlays and place labels
       GoogleMapView(options: $mapOptions)
           .mapType(.terrain)
           .ignoresSafeArea()  // Makes the map fill the entire screen
   }
}
