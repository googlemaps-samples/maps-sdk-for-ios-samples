// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#import "MarkerClustering.h"
// [START maps_ios_marker_clustering_creation]
@import GoogleMaps;
@import GoogleMapsUtils;

@interface MarkerClustering () <GMSMapViewDelegate>

@end

@implementation MarkerClustering {
  GMSMapView *_mapView;
  GMUClusterManager *_clusterManager;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Set up the cluster manager with a supplied icon generator and renderer.
  id<GMUClusterAlgorithm> algorithm =
      [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  id<GMUClusterIconGenerator> iconGenerator =
      [[GMUDefaultClusterIconGenerator alloc] init];
  id<GMUClusterRenderer> renderer =
      [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                    clusterIconGenerator:iconGenerator];
  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView
                                   algorithm:algorithm
                                    renderer:renderer];

  // Register self to listen to GMSMapViewDelegate events.
  [_clusterManager setMapDelegate:self];
  // [START_EXCLUDE]
  // [START maps_ios_marker_clustering_marker_individual]
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(47.60, -122.33);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  [_clusterManager addItem:marker];
  // [END maps_ios_marker_clustering_marker_individual]

  // [START maps_ios_marker_clustering_marker_array]
  CLLocationCoordinate2D position1 = CLLocationCoordinate2DMake(47.60, -122.33);
  GMSMarker *marker1 = [GMSMarker markerWithPosition:position1];

  CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake(47.60, -122.46);
  GMSMarker *marker2 = [GMSMarker markerWithPosition:position2];

  CLLocationCoordinate2D position3 = CLLocationCoordinate2DMake(47.30, -122.46);
  GMSMarker *marker3 = [GMSMarker markerWithPosition:position3];

  CLLocationCoordinate2D position4 = CLLocationCoordinate2DMake(47.20, -122.23);
  GMSMarker *marker4 = [GMSMarker markerWithPosition:position4];

  NSArray<GMSMarker *> *markerArray = @[marker1, marker2, marker3, marker4];
  [_clusterManager addItems:markerArray];
  // [END maps_ios_marker_clustering_marker_array]

  // [START maps_ios_marker_clustering_invoke]
  [_clusterManager cluster];
  // [END maps_ios_marker_clustering_invoke]
  // [END_EXCLUDE]
}
// [START_EXCLUDE]
// [START maps_ios_marker_clustering_events]
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  // center the map on tapped marker
    [_mapView animateToLocation:marker.position];
    // check if a cluster icon was tapped
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
      // zoom in on tapped cluster
      [_mapView animateToZoom:_mapView.camera.zoom + 1];
      NSLog(@"Did tap cluster");
      return YES;
    }

    NSLog(@"Did tap marker in cluster");
    return NO;
}
// [END maps_ios_marker_clustering_events]
// [END_EXCLUDE]
@end
// [END maps_ios_marker_clustering_creation]
