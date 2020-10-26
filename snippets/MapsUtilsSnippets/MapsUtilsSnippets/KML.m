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

#import "KML.h"
// [START maps_ios_kml]
@import GoogleMapsUtils;

@implementation KML {
  GMSMapView *_mapView;
}

- (void)renderKml {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"KML_Sample" ofType:@"kml"];
  NSURL *url = [NSURL fileURLWithPath:path];
  GMUKMLParser *parser = [[GMUKMLParser alloc] initWithURL:url];
  [parser parse];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:parser.placemarks
                                                                    styles:parser.styles];
  [renderer render];
}

@end
// [END maps_ios_kml]
