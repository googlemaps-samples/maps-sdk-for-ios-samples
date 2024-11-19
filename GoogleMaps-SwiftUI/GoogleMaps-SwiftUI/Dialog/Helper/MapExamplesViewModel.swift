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

class MapExamplesViewModel: ObservableObject {
    
    @Published var examples: [MapExample] = [
        MapExample(
            title: "Basic map",
            description: "A simple map. Shows how to configure GMSMapViewOptions as a map binding.",
            destination: AnyView(BasicMap())
        ),
        MapExample(
            title: "Map with Street Level",
            description: "Map camera position set to street-level 3D perspective.",
            destination: AnyView(MapWithStreetLevel())
        ),
        MapExample(
            title: "Map with marker",
            description: "Implements a map marker as a viewModifier. Extends the GMSMarker model.",
            destination: AnyView(MapWithMarker())
        ),
        MapExample(
            title: "Map with markers",
            description: "Applies a collection of markers to a map. Extends the GMSMarker model.",
            destination: AnyView(MapWithMarkers())
        ),
        MapExample(
            title: "Map with Types",
            description: "How to set the satellite, terrain, or hybrid map type property.",
            destination: AnyView(MapWithTypes())
        ),
        MapExample(
            title: "Map with Containers",
            description: "Shows integration with SwiftUI layouts, allowing for standard modifiers like frame and padding.",
            destination: AnyView(MapWithContainer())
        ),
        MapExample(
            title: "Map with Delegate",
            description: "A GoogleMapView configured with a handler for map tap events.",
            destination: AnyView(MapWithDelegate())
        )
    ]
    
    //set intial dialog map options - override default zoom level
    let mapOptions: GMSMapViewOptions = {
            var options = GMSMapViewOptions()
        options.camera = .camera(.googleplex, zoom: 13)  //location predefined in a helper class
            return options
        }()

}
