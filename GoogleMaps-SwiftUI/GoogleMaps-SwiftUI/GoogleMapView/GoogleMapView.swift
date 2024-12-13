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
    
   // Configuration properties - set at initialization
   private let options: GMSMapViewOptions
   
   /// Array of markers to display on the map
   private var markers: [GMSMarker]
   
   /// Type of map to display (normal, satellite, hybrid, terrain)
   private let mapType: GMSMapViewType
   
   // Runtime updatable properties
   private var camera: GMSCameraPosition?
   private var backgroundColor: UIColor?
   
   /// Shared delegate instance to handle map interactions across all instances
   /// Using static ensures callbacks work together when chaining modifiers
   private static let mapDelegate = GoogleMapViewDelegate()
   
   init(options: GMSMapViewOptions,
        markers: [GMSMarker] = [],
        mapType: GMSMapViewType = .normal) {
       self.options = options
       self.markers = markers
       self.mapType = mapType
   }
   
   /// Creates the underlying UIKit map view
   func makeUIView(context: Context) -> GMSMapView {
       // Initialize map with current options
       let mapView = GMSMapView(options: options)
       mapView.mapType = mapType
       
       // Set shared delegate to handle interactions
       mapView.delegate = Self.mapDelegate
             
       return mapView
   }
   
   /// Updates the map view when SwiftUI state changes
   func updateUIView(_ uiView: GMSMapView, context: Context) {
       // Update runtime properties if set
       if let camera = camera {
           uiView.camera = camera
       }
       
       if let backgroundColor = backgroundColor {
           uiView.backgroundColor = backgroundColor
       }
       
       // Refresh markers on the map
       markers.forEach { marker in
           marker.map = uiView
       }
       
       uiView.mapType = mapType // Update map type if changed
   }
}

// MARK: - viewModifiers and Markers

extension GoogleMapView {
    /// Updates the camera position of the map view during runtime
    /// - Parameter position: New camera position to apply
    /// - Returns: Updated GoogleMapView instance
    func camera(_ position: GMSCameraPosition?) -> GoogleMapView {
        var view = self
        if let position = position {
            view.camera = position
        }
        return view
    }
    
    /// Updates the background color of the map view during runtime
    /// - Parameter color: New background color to apply
    /// - Returns: Updated GoogleMapView instance
    func backgroundColor(_ color: UIColor) -> GoogleMapView {
        var view = self
        view.backgroundColor = color
        return view
    }
    
    /// Changes the map display type
    /// - Parameter type: GMSMapViewType to use (.normal, .satellite, etc)
    /// - Returns: New GoogleMapView instance with updated map type
    func mapType(_ type: GMSMapViewType) -> GoogleMapView {
        GoogleMapView(options: options, markers: markers, mapType: type)
    }
    
    /// Adds markers to the map
    /// - Parameter markers: Array of GMSMarker objects to display
    /// - Returns: New GoogleMapView instance with updated markers
    func mapMarkers(_ markers: [GMSMarker]) -> GoogleMapView {
        var view = self
        view.markers = markers
        return view
    }

}

// MARK: - View Callbacks

extension GoogleMapView {
   /// Adds handler for map tap events
   /// - Parameter handler: Closure called when map is tapped, providing tap coordinates
   /// - Returns: Same GoogleMapView instance with updated tap handler
   func onMapTapped(_ handler: @escaping (CLLocationCoordinate2D) -> Void) -> GoogleMapView {
       Self.mapDelegate.tapHandler = handler
       return self
   }
   
   /// Adds handler for marker tap events
   /// - Parameter handler: Closure called when marker is tapped
   /// - Returns: Same GoogleMapView instance with updated marker handler
   /// Return true from handler to indicate tap was handled
   func onMarkerTapped(_ handler: @escaping (GMSMarker) -> Bool) -> GoogleMapView {
       Self.mapDelegate.markerTapHandler = handler
       return self
   }
}

extension View {
   /// Configures the view to ignore safe areas except for the top
   /// Useful for map views that should fill the screen below status bar
   /// - Returns: Modified view that extends to screen edges except top
   func ignoresSafeAreaExceptTop() -> some View {
       ignoresSafeArea(.container, edges: [.bottom, .horizontal])
   }
}
