// Copyright 2022 Google LLC. All rights reserved.
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

import UIKit

struct Sample {
  let viewControllerClass: UIViewController.Type
  let title: String
  let description: String
}

struct Section {
  let name: String
  let samples: [Sample]
}

enum Samples {
  static func allSamples() -> [Section] {
    let mapSamples = [
      Sample(viewControllerClass: BasicMapViewController.self, title: "Basic Map", description: "Creates a map centered on Sydney, New South Wales, Australia"),
      Sample(viewControllerClass: MapTypesViewController.self, title: "Map Types", description: "A segmented control is used to toggle between different map types"),
      Sample(viewControllerClass: StyledMapViewController.self, title: "Styled Map", description: "Allows the user to choose between a variety of json-defined map styles"),
      Sample(viewControllerClass: TrafficMapViewController.self, title: "Traffic Layer", description: "Displays local traffic superimposed on the map"),
      Sample(viewControllerClass: MyLocationViewController.self, title: "My Location", description: "Panning to a users current location"),
      Sample(viewControllerClass: IndoorViewController.self, title: "Indoor", description: "A map that displays the interior of a building"),
      Sample(
        viewControllerClass: CustomIndoorViewController.self,
        title: "Indoor with Custom Level Select",  description: "Employs a toggle which indoor level is displayed"),
      Sample(
        viewControllerClass: IndoorMuseumNavigationViewController.self,
        title: "Indoor Museum Navigator", description: "Moving the map to a different location inside the museum"),
      Sample(viewControllerClass: GestureControlViewController.self, title: "Gesture Control", description: "Responding to zoom gestures when switch is toggled on"),
      Sample(viewControllerClass: SnapshotReadyViewController.self, title: "Snapshot Ready", description: "Capture screenshots with buttons and gestures"),
      Sample(viewControllerClass: DoubleMapViewController.self, title: "Two Maps", description: "Two stacked maps; top map controls both, bottom disabled"),
      Sample(viewControllerClass: VisibleRegionViewController.self, title: "Visible Regions", description: "Shows/hides red overlay; controls adjust accordingly"),
      Sample(viewControllerClass: MapZoomViewController.self, title: "Min/Max Zoom", description: "Map zooming restricted; Play button toggles between min/max zoom levels"),
      Sample(viewControllerClass: FrameRateViewController.self, title: "Frame Rate", description: "Play button toggles between three frame rate settings"),
      Sample(viewControllerClass: PaddingBehaviorViewController.self, title: "Padding Behavior", description: "Shows map display with padding behavior"),
    ]
    let overlaySamples = [
      Sample(viewControllerClass: MarkersViewController.self, title: "Markers", description: "Identifies a location on the map with a marker"),
      Sample(viewControllerClass: CustomMarkersViewController.self, title: "Custom Markers", description: "Several markers are displayed with custom images"),
      Sample(viewControllerClass: AnimatedUIViewMarkerViewController.self, title: "UIView Markers", description: "A marker is displayed using a custom image and animation"),
      Sample(viewControllerClass: MarkerEventsViewController.self, title: "Marker Events", description: "Map shows two markers; tapping zooms/rotates to selected one"),
      Sample(viewControllerClass: MarkerLayerViewController.self, title: "Marker Layer", description: "Plane marker slides between coordinates, rotating toward next destination"),
      Sample(
        viewControllerClass: MarkerInfoWindowViewController.self, title: "Custom Info Windows", description: "Marker shows at Australia's center; tapping displays info window."),
      Sample(viewControllerClass: PolygonsViewController.self, title: "Polygons", description: "Shapes outline land and maritime borders of NY and NC"),
      Sample(viewControllerClass: PolylinesViewController.self, title: "Polylines", description: "Animated red/green polylines change position/size over South Pacific map"),
      Sample(viewControllerClass: GroundOverlayViewController.self, title: "Ground Overlays", description: "Custom image placed on ground layer; markers appear in front"),
      Sample(viewControllerClass: TileLayerViewController.self, title: "Tile Layers", description: "Map tiles are colored to highlight the indoor layout of the selected floor"),
      Sample(
        viewControllerClass: AnimatedCurrentLocationViewController.self,
        title: "Animated Current Location", description: "A marker with a walking animation moves with the user's current location"),
      Sample(
        viewControllerClass: GradientPolylinesViewController.self, title: "Gradient Polylines", description: "Polyline traces hiking trail; warmer colors show higher elevations"),
    ]
    let panoramaSamples = [
      Sample(viewControllerClass: PanoramaServiceController.self, title: "Panorama Service", description: "Tests the panorama service and displays the response data"),
      Sample(viewControllerClass: PanoramaViewController.self, title: "Street View", description: "Displays a full screen panoramic street view"),
      Sample(viewControllerClass: FixedPanoramaViewController.self, title: "Fixed Street View", description: "This panoramic street view does not respond to gestures"),
    ]
    let cameraSamples = [
      Sample(viewControllerClass: FitBoundsViewController.self, title: "Fit Bounds", description: "Fit Bounds button pans/zooms camera to fit all markers"),
      Sample(viewControllerClass: CameraViewController.self, title: "Camera Animation", description: "Camera zooms out and rotates showing Melbourne's surrounding buildings"),
      Sample(viewControllerClass: MapLayerViewController.self, title: "Map Layer", description: "Triggers animations zooming to user's location"),
    ]
    let serviceSamples = [
      Sample(viewControllerClass: GeocoderViewController.self, title: "Geocoder", description: "Long-press sends coordinates for geocoding; displays marker with results"),
      Sample(
        viewControllerClass: StructuredGeocoderViewController.self, title: "Structured Geocoder", description: "Long-press sends coordinates for geocoding; displays address details in window"),
    ]
    return [
      Section(name: "Map Basics", samples: mapSamples),
      Section(name: "Panorama", samples: panoramaSamples),
      Section(name: "Overlays", samples: overlaySamples),
      Section(name: "Camera", samples: cameraSamples),
      Section(name: "Services", samples: serviceSamples),
    ]
  }
}
