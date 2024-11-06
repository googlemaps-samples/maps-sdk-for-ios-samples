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

/// A SwiftUI wrapper for GMSMapView that displays a map with optional markers
struct GoogleMapView: UIViewRepresentable {
    @Binding var options: GMSMapViewOptions
    private let markers: [GMSMarker]
    
    init(options: Binding<GMSMapViewOptions>, markers: [GMSMarker] = []) {
        self._options = options
        self.markers = markers
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(options: options)
        markers.forEach { marker in
            marker.map = mapView
        }
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // No manual updates needed since we're using options-based initialization
    }
}

// Extension to add marker support specifically to GoogleMapView
extension GoogleMapView {
    func mapMarkers(_ markers: [GMSMarker]) -> GoogleMapView {
        GoogleMapView(options: self._options, markers: markers)
    }
}
