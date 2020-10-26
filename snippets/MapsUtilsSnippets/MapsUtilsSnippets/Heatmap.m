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


#import "Heatmap.h"
@import GoogleMapsUtils;

// [START maps_ios_heatmap_simple]
@implementation Heatmap {
  GMSMapView *_mapView;
  GMUHeatmapTileLayer *_heatmapLayer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _heatmapLayer = [[GMUHeatmapTileLayer alloc] init];
  _heatmapLayer.map = _mapView;
}

// [START_EXCLUDE]
- (void) customize {
  // [START maps_ios_heatmap_customize_gradient]
  NSArray<UIColor *> *gradientColors = @[UIColor.greenColor, UIColor.redColor];
  NSArray<NSNumber *> *gradientStartPoints = @[@0.2, @1.0];
  _heatmapLayer.gradient = [[GMUGradient alloc] initWithColors:gradientColors
                                                   startPoints:gradientStartPoints
                                                  colorMapSize:256];
  // [END maps_ios_heatmap_customize_gradient]

  // [START maps_ios_heatmap_customize_opacity]
  _heatmapLayer.opacity = 0.7;
  // [END maps_ios_heatmap_customize_opacity]

  // [START maps_ios_heatmap_remove]
  _heatmapLayer.map = nil;
  // [END maps_ios_heatmap_remove]
}
// [END_EXCLUDE]

- (void) addHeatmap {

  // Get the data: latitude/longitude positions of police stations.
  NSURL *path = [NSBundle.mainBundle URLForResource:@"police_stations" withExtension:@"json"];
  NSData *data = [NSData dataWithContentsOfURL:path];
  NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

  NSMutableArray<GMUWeightedLatLng *> *list = [[NSMutableArray alloc] init];
  [json enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSDictionary *item = (NSDictionary *)obj;
    CLLocationDegrees lat = [(NSNumber *) [item valueForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [(NSNumber *) [item valueForKey:@"lng"] doubleValue];
    GMUWeightedLatLng *coords = [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)
                                                                    intensity:1.0];
    [list addObject:coords];
  }];


  // Add the latlngs to the heatmap layer.
  _heatmapLayer.weightedData = list;
}
@end
// [END maps_ios_heatmap_simple]
