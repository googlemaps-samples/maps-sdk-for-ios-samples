/*
 * Copyright 2016 Google LLC. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "GoogleMapsXCFrameworkDemos/Samples/Samples.h"

#import "GoogleMapsXCFrameworkDemos/Samples/AnimatedCurrentLocationViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/AnimatedUIViewMarkerViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/BasicMapViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/CameraViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/CustomIndoorViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/CustomMarkersViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/DarkModeViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingBasicViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingEventsViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingSearchViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/DoubleMapViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/FitBoundsViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/FixedPanoramaViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/FrameRateViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/GeocoderViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/GestureControlViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/GradientPolylinesViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/GroundOverlayViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/IndoorMuseumNavigationViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/IndoorViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MapLayerViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MapTypesViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MapZoomViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MarkerEventsViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MarkerInfoWindowViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MarkerLayerViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MarkersViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/MyLocationViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/PaddingBehaviorViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/PanoramaViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/PolygonsViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/PolylinesViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/SnapshotReadyViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/StampedPolylinesViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/StructuredGeocoderViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/StyledMapViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/TileLayerViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/TrafficMapViewController.h"
#import "GoogleMapsXCFrameworkDemos/Samples/VisibleRegionViewController.h"

@implementation Samples

+ (NSArray<NSString *> *)loadSections {
  return @[ @"Map", @"Panorama", @"Overlays", @"Camera", @"Data-driven styling", @"Services" ];
}

+ (NSArray<NSArray<DemoDefinition *> *> *)loadDemos {
  NSArray<DemoDefinition *> *mapDemos = @[
    [self newDemo:[BasicMapViewController class] withTitle:@"Basic Map" andDescription:nil],
    [self newDemo:[MapTypesViewController class] withTitle:@"Map Types" andDescription:nil],
    [self newDemo:[StampedPolylinesViewController class]
             withTitle:@"Stamped Polylines"
        andDescription:nil],
    [self newDemo:[TrafficMapViewController class] withTitle:@"Traffic Layer" andDescription:nil],
    [self newDemo:[MyLocationViewController class] withTitle:@"My Location" andDescription:nil],
    [self newDemo:[IndoorViewController class] withTitle:@"Indoor" andDescription:nil],
    [self newDemo:[CustomIndoorViewController class]
             withTitle:@"Indoor with Custom Level Select"
        andDescription:nil],
    [self newDemo:[IndoorMuseumNavigationViewController class]
             withTitle:@"Indoor Museum Navigator"
        andDescription:nil],
    [self newDemo:[GestureControlViewController class]
             withTitle:@"Gesture Control"
        andDescription:nil],
    [self newDemo:[SnapshotReadyViewController class]
             withTitle:@"Snapshot Ready"
        andDescription:nil],
    [self newDemo:[DoubleMapViewController class] withTitle:@"Two Maps" andDescription:nil],
    [self newDemo:[VisibleRegionViewController class]
             withTitle:@"Visible Regions"
        andDescription:nil],
    [self newDemo:[MapZoomViewController class] withTitle:@"Min/Max Zoom" andDescription:nil],
    [self newDemo:[FrameRateViewController class] withTitle:@"Frame Rate" andDescription:nil],
    [self newDemo:[PaddingBehaviorViewController class]
             withTitle:@"Padding Behavior"
        andDescription:nil],
    [self newDemo:[StyledMapViewController class] withTitle:@"Styled Map" andDescription:nil],
    [self newDemo:[DarkModeViewController class]
             withTitle:@"Dark Mode Settings"
        andDescription:nil],
  ];

  NSArray<DemoDefinition *> *panoramaDemos = @[
    [self newDemo:[PanoramaViewController class] withTitle:@"Street View" andDescription:nil],
    [self newDemo:[FixedPanoramaViewController class]
             withTitle:@"Fixed Street View"
        andDescription:nil]
  ];

  NSArray<DemoDefinition *> *overlayDemos = @[
    [self newDemo:[MarkersViewController class] withTitle:@"Markers" andDescription:nil],
    [self newDemo:[CustomMarkersViewController class]
             withTitle:@"Custom Markers"
        andDescription:nil],
    [self newDemo:[AnimatedUIViewMarkerViewController class]
             withTitle:@"UIView Markers"
        andDescription:nil],
    [self newDemo:[MarkerEventsViewController class] withTitle:@"Marker Events" andDescription:nil],
    [self newDemo:[MarkerLayerViewController class] withTitle:@"Marker Layer" andDescription:nil],
    [self newDemo:[MarkerInfoWindowViewController class]
             withTitle:@"Custom Info Windows"
        andDescription:nil],
    [self newDemo:[PolygonsViewController class] withTitle:@"Polygons" andDescription:nil],
    [self newDemo:[PolylinesViewController class] withTitle:@"Polylines" andDescription:nil],
    [self newDemo:[GroundOverlayViewController class]
             withTitle:@"Ground Overlays"
        andDescription:nil],
    [self newDemo:[TileLayerViewController class] withTitle:@"Tile Layers" andDescription:nil],
    [self newDemo:[AnimatedCurrentLocationViewController class]
             withTitle:@"Animated Current Location"
        andDescription:nil],
    [self newDemo:[GradientPolylinesViewController class]
             withTitle:@"Gradient Polylines"
        andDescription:nil]
  ];

  NSArray<DemoDefinition *> *cameraDemos = @[
    [self newDemo:[FitBoundsViewController class] withTitle:@"Fit Bounds" andDescription:nil],
    [self newDemo:[CameraViewController class] withTitle:@"Camera Animation" andDescription:nil],
    [self newDemo:[MapLayerViewController class] withTitle:@"Map Layer" andDescription:nil]
  ];

  NSArray<DemoDefinition *> *dataDrivenStylingDemos = @[
    [self newDemo:[DataDrivenStylingBasicViewController class]
             withTitle:@"Basic"
        andDescription:nil],
    [self newDemo:[DataDrivenStylingEventsViewController class]
             withTitle:@"Events"
        andDescription:nil],
    [self newDemo:[DataDrivenStylingSearchViewController class]
             withTitle:@"Places from text search"
        andDescription:nil]
  ];

  NSArray<DemoDefinition *> *servicesDemos = @[
    [self newDemo:[GeocoderViewController class] withTitle:@"Geocoder" andDescription:nil],
    [self newDemo:[StructuredGeocoderViewController class]
             withTitle:@"Structured Geocoder"
        andDescription:nil],
  ];

  return @[
    mapDemos, panoramaDemos, overlayDemos, cameraDemos, dataDrivenStylingDemos, servicesDemos
  ];
}

+ (DemoDefinition *)newDemo:(Class)viewControllerClass
                  withTitle:(NSString *)title
             andDescription:(NSString *)description {
  return [[DemoDefinition alloc]
      initWithObjectsAndKeys:viewControllerClass, @"controller", title, @"title",
                             NSStringFromClass(viewControllerClass), @"className", description,
                             @"description", nil];
}

@end
