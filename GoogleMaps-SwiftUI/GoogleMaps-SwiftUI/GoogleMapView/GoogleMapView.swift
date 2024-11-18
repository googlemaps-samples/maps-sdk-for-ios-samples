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

/// A SwiftUI wrapper for GMSMapView that displays a map with optional markers and configurable map type
struct GoogleMapView: UIViewRepresentable {
    @Binding var options: GMSMapViewOptions
    private let markers: [GMSMarker]
    private let mapType: GMSMapViewType
    private let mapDelegate: GoogleMapViewDelegate
    
    /// Initializes a new GoogleMapView instance
    /// - Parameters:
    ///   - options: Binding to GMSMapViewOptions for configuring the map
    ///   - markers: Array of GMSMarker objects to display on the map (optional)
    ///   - mapType: The type of map to display (defaults to .normal)
    init(options: Binding<GMSMapViewOptions>,
         markers: [GMSMarker] = [],
         mapType: GMSMapViewType = .normal) {
        
        self._options = options
        self.markers = markers
        self.mapType = mapType
        self.mapDelegate = GoogleMapViewDelegate()
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(options: options)
        mapView.mapType = mapType
        mapView.delegate = mapDelegate
        
        markers.forEach { marker in
            marker.map = mapView
        }
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.mapType = mapType // Update map type if it changes
    }
}

// Extension to add marker and map type support specifically to GoogleMapView
extension GoogleMapView {
    /// Adds one or more markers to be displayed on the map
    /// - Parameter markers: An array of GMSMarker objects. Pass a single marker in an array for individual placement
    /// - Returns: A GoogleMapView configured with the specified markers
    func mapMarkers(_ markers: [GMSMarker]) -> GoogleMapView {
        GoogleMapView(options: self._options, markers: markers, mapType: self.mapType)
    }
    
    /// Sets the type of map to display
    /// - Parameter type: The GMSMapViewType to use (e.g. .normal, .satellite, .hybrid, .terrain)
    /// - Returns: A GoogleMapView configured with the specified map type
    func mapType(_ type: GMSMapViewType) -> GoogleMapView {
        GoogleMapView(options: self._options, markers: self.markers, mapType: type)
    }
    
   /// Adds a handler for map tap events
   /// - Parameter handler: A closure that will be called when the map is tapped, providing the coordinate
   /// - Returns: A GoogleMapView configured with the tap handler
   func onMapTapped(_ handler: @escaping (CLLocationCoordinate2D) -> Void) -> some View {
       let view = self
       view.mapDelegate.tapHandler = handler
       return view
   }
}

extension View {
    /// Configures the view to ignore safe areas except for the top
    /// - Returns: A view that fills the screen except for the top safe area
    func ignoresSafeAreaExceptTop() -> some View {
        ignoresSafeArea(.container, edges: [.bottom, .horizontal])
    }
}
