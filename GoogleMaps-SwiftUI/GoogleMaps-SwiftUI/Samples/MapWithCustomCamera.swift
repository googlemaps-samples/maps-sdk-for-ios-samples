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

struct MapWithCustomCamera: View {
    
        private var mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        // Initialize map centered on San Francisco
        options.camera = .streetLevel(.sanFrancisco, bearing: 45)
                
        // Or with custom zoom level for closer view
        // options.camera = .camera(.sanFrancisco, zoom: 15)
        
        // For 3D perspective view
        // options.camera = .camera(.sanFrancisco, zoom: 18, bearing: 45, viewingAngle: 45)
        
        // Quick street-level 3D view
        // options.camera = .streetLevel(.sanFrancisco, bearing: 45)
        return options
    }()
    
   var body: some View {
       
       //Map camera position set to street-level 3D perspective.
       GoogleMapView(options: mapOptions)
           .ignoresSafeAreaExceptTop()   //optional property for samples display
   }
}

