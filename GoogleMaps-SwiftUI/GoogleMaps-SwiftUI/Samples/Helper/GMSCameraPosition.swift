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

import Foundation
import GoogleMaps

extension GMSCameraPosition {
    /// Creates a camera position focused on a predefined location with configurable view parameters
    /// - Parameters:
    ///   - location: A predefined MapLocation indicating where to center the map
    ///   - zoom: The zoom level for the camera position (default: 12)
    ///           - Values range from 1 (world view) to 20 (building level)
    ///           - Default value of 12 typically shows a city-level view
    ///   - bearing: The direction the camera is pointing in degrees (default: 0)
    ///           - Values range from 0 to 360, where 0° points north
    ///   - viewingAngle: The angle of the camera from the nadir (directly facing Earth) (default: 0)
    ///           - Values range from 0 (directly overhead) to 90 degrees (horizontal)
    /// - Returns: A configured GMSCameraPosition object ready for use with GMSMapViewOptions
    static func camera(_ location: MapLocation,
                      zoom: Float = 12,
                      bearing: Double = 0,
                      viewingAngle: Double = 0) -> GMSCameraPosition {
        
        switch location {
        case .sanFrancisco:
            return GMSCameraPosition(
                latitude: 37.7749,    // Downtown San Francisco
                longitude: -122.4194,
                zoom: zoom,           // Default provides good city overview
                bearing: bearing,     // Camera orientation
                viewingAngle: viewingAngle  // Camera tilt
            )
        case .newYork:
            return GMSCameraPosition(
                latitude: 40.7128,    // Lower Manhattan
                longitude: -74.0060,
                zoom: zoom,
                bearing: bearing,
                viewingAngle: viewingAngle
            )
        case .seattle:
            return GMSCameraPosition(
                latitude: 47.6062,    // Downtown Seattle
                longitude: -122.3321,
                zoom: zoom,
                bearing: bearing,
                viewingAngle: viewingAngle
            )
        case .googleplex:
            return GMSCameraPosition(
                latitude: 37.4220,     // Googleplex HQ
                longitude: -122.0841,
                zoom: zoom,
                bearing: bearing,
                viewingAngle: viewingAngle
            )
        }
    }
    
    /// Convenience method for creating a street-level 3D perspective
    /// - Parameters:
    ///   - location: A predefined MapLocation indicating where to center the map
    ///   - bearing: The direction to face in degrees (default: 0 = north)
    /// - Returns: A GMSCameraPosition configured for immersive street-level viewing
    static func streetLevel(_ location: MapLocation, bearing: Double = 0) -> GMSCameraPosition {
        camera(location,
              zoom: 18,           // Close street-level zoom
              bearing: bearing,
              viewingAngle: 45)   // 45-degree viewing angle for 3D perspective
    }
}

/// Predefined map locations for common use cases.
/// Each case represents a significant location with preset coordinates.
enum MapLocation {
    /// San Francisco, California - Tech hub of the West Coast
    /// Centered approximately on the Financial District
    case sanFrancisco
    
    /// New York City, New York - Centered on Lower Manhattan
    /// Includes major landmarks like the Financial District and nearby boroughs
    case newYork
    
    /// Seattle, Washington - Major Pacific Northwest tech center
    /// Centered on downtown, including Pike Place Market and Seattle Center area
    case seattle
    
    /// Mountain View, California - Google's Global Headquarters
    /// Centered on the Googleplex campus, including Charleston Park and the Android Lawn Statues
    case googleplex
    
    // Add more locations as needed. Example format:
    /// /// City Name, State/Country - Brief description
    /// /// Notable landmarks or areas included in this view
    /// case cityName
}

/* Usage Example:

struct ContentView: View {
    @State private var mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        // Initialize map centered on San Francisco
        options.camera = .camera(.sanFrancisco)
        
        // Or with custom zoom level for closer view
        // options.camera = .camera(.sanFrancisco, zoom: 15)
        return options
    }()
    
    var body: some View {
        GoogleMapView(options: $mapOptions)
    }
}
*/
