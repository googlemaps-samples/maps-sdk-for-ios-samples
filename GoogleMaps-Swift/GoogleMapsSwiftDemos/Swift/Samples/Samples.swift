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
      Sample(viewControllerClass: TrafficMapViewController.self, title: "Traffic Layer", description: "Displays local traffic superimposed on the map."),
      Sample(viewControllerClass: MyLocationViewController.self, title: "My Location", description: "Panning to a users current location"),
      Sample(viewControllerClass: IndoorViewController.self, title: "Indoor", description: "A map that displays the interior of a building"),
      Sample(
        viewControllerClass: CustomIndoorViewController.self,
        title: "Indoor with Custom Level Select",  description: ""),
      Sample(
        viewControllerClass: IndoorMuseumNavigationViewController.self,
        title: "Indoor Museum Navigator", description: ""),
      Sample(viewControllerClass: GestureControlViewController.self, title: "Gesture Control", description: ""),
      Sample(viewControllerClass: SnapshotReadyViewController.self, title: "Snapshot Ready", description: ""),
      Sample(viewControllerClass: DoubleMapViewController.self, title: "Two Maps", description: ""),
      Sample(viewControllerClass: VisibleRegionViewController.self, title: "Visible Regions", description: ""),
      Sample(viewControllerClass: MapZoomViewController.self, title: "Min/Max Zoom", description: ""),
      Sample(viewControllerClass: FrameRateViewController.self, title: "Frame Rate", description: ""),
      Sample(viewControllerClass: PaddingBehaviorViewController.self, title: "Padding Behavior", description: ""),
    ]
    let overlaySamples = [
      Sample(viewControllerClass: MarkersViewController.self, title: "Markers", description: ""),
      Sample(viewControllerClass: CustomMarkersViewController.self, title: "Custom Markers", description: ""),
      Sample(viewControllerClass: AnimatedUIViewMarkerViewController.self, title: "UIView Markers", description: ""),
      Sample(viewControllerClass: MarkerEventsViewController.self, title: "Marker Events", description: ""),
      Sample(viewControllerClass: MarkerLayerViewController.self, title: "Marker Layer", description: ""),
      Sample(
        viewControllerClass: MarkerInfoWindowViewController.self, title: "Custom Info Windows", description: ""),
      Sample(viewControllerClass: PolygonsViewController.self, title: "Polygons", description: ""),
      Sample(viewControllerClass: PolylinesViewController.self, title: "Polylines", description: ""),
      Sample(viewControllerClass: GroundOverlayViewController.self, title: "Ground Overlays", description: ""),
      Sample(viewControllerClass: TileLayerViewController.self, title: "Tile Layers", description: ""),
      Sample(
        viewControllerClass: AnimatedCurrentLocationViewController.self,
        title: "Animated Current Location", description: ""),
      Sample(
        viewControllerClass: GradientPolylinesViewController.self, title: "Gradient Polylines", description: ""),
    ]
    let panoramaSamples = [
      Sample(viewControllerClass: PanoramaServiceController.self, title: "Panorama Service", description: ""),
      Sample(viewControllerClass: PanoramaViewController.self, title: "Street View", description: ""),
      Sample(viewControllerClass: FixedPanoramaViewController.self, title: "Fixed Street View", description: ""),
    ]
    let cameraSamples = [
      Sample(viewControllerClass: FitBoundsViewController.self, title: "Fit Bounds", description: ""),
      Sample(viewControllerClass: CameraViewController.self, title: "Camera Animation", description: ""),
      Sample(viewControllerClass: MapLayerViewController.self, title: "Map Layer", description: ""),
    ]
    let serviceSamples = [
      Sample(viewControllerClass: GeocoderViewController.self, title: "Geocoder", description: ""),
      Sample(
        viewControllerClass: StructuredGeocoderViewController.self, title: "Structured Geocoder", description: ""),
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
