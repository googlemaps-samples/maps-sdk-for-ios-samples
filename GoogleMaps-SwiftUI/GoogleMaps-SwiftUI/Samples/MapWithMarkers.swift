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

struct MapWithMarkers: View {
    private let mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        options.camera = .camera(.sanFrancisco)
        return options
    }()
    
    // Make markers mutable with @State
    @State private var markers: [GMSMarker] = [
        GMSMarker(position: .chinatownGate),
        GMSMarker(position: .coitTower),
        GMSMarker(position: .ferryBuilding)
    ]
    
    var body: some View {
        VStack {
            GoogleMapView(options: mapOptions)
                .mapMarkers(markers)
                .ignoresSafeAreaExceptTop()
            
            Button("Add Fisherman's Wharf") {
                markers.append(GMSMarker(position: .fishermansWharf))
            }
            .padding()
        }
    }
}

