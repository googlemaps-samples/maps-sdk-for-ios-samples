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

struct HandleMapEvents: View {
    
    @State var response: String = ""
    
    private var mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        // Initialize map centered on San Francisco
        options.camera = .camera(.sanFrancisco)
                
        // Or with custom zoom level for closer view
        // options.camera = .camera(.sanFrancisco, zoom: 15)
        return options
    }()
    
    // multiple marker example
    let multipleMarkers = [
        GMSMarker(position: .chinatownGate),
        GMSMarker(position: .coitTower),
        GMSMarker(position: .ferryBuilding),
        GMSMarker(position: .fishermansWharf)
    ]
    
   var body: some View {
    
       VStack(spacing: 16) {
           GoogleMapView(options: mapOptions)
               .mapMarkers(multipleMarkers)
               .onMarkerTapped { marker in
                   response = "Marker tapped at: \(marker.position)"
                   return true
               }
               .onMapTapped { coordinate in
                   response = "Map tapped at: \(coordinate.latitude), \(coordinate.longitude)"
               }
               .ignoresSafeAreaExceptTop()
               .frame(maxWidth: .infinity, minHeight: 325)
           
           HStack {
               VStack(alignment: .leading, spacing: 8) {
                   Text("Tap a Map location or Marker")
                       .font(.headline)
                   
                   Text(response)
                       .font(.body)
                       .foregroundColor(.secondary)
               }
               Spacer()
           }
           .padding(.horizontal)
       }

   }
}
