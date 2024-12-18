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

struct BasicMapWithMapID: View {
    
    private let mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        options.camera = .camera(.googleplex)  // Initial camera position
                        
        /*
         1. See the following url to get a mapID.
         https://goo.gle/get-map-id
         
         2. Provide your mapID here
         let mapID = GMSMapID(identifier: "YOUR_MAP_ID")
         */
                
        let mapID: GMSMapID = .demoMapID  //used for demostration only
        options.mapID = mapID
        
        return options
    }()
    
    var body: some View {
        VStack {
            GoogleMapView(options: mapOptions)
                .ignoresSafeAreaExceptTop()
        }
    }
}

