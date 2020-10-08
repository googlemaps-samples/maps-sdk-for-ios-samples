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


#import "TileLayers.h"
@import GoogleMaps;

// [START maps_ios_tile_layers_subclass]
@interface TestTileLayer : GMSSyncTileLayer
@end

@implementation TestTileLayer

- (UIImage *)tileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)zoom {
  // On every odd tile, render an image.
  if (x % 2 == 1) {
    return [UIImage imageNamed:@"australia"];
  } else {
    return kGMSTileLayerNoTile;
  }
}

@end
// [END maps_ios_tile_layers_subclass]

@implementation TileLayers

GMSMapView *mapView;

- (void)tileLayers {
  // [START maps_ios_tile_layers_add]
  NSInteger floor = 1;

  // Create the GMSTileLayer
  GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:^NSURL * _Nullable(NSUInteger x, NSUInteger y, NSUInteger zoom) {
    NSString *url = [NSString stringWithFormat:@"https://www.example.com/floorplans/L%ld_%lu_%lu_%lu.png",
                     (long)floor, (unsigned long)zoom, (unsigned long)x, (unsigned long)y];
    return [NSURL URLWithString:url];
  }];

  // Display on the map at a specific zIndex
  layer.zIndex = 100;
  layer.map = mapView;
  // [END maps_ios_tile_layers_add]
}

- (void)tileLayer {
  // [START maps_ios_tile_layers_subclass_init]
  GMSTileLayer *layer = [[TestTileLayer alloc] init];
  layer.map = mapView;
  // [END maps_ios_tile_layers_subclass_init]

  // [START maps_ios_tile_layers_clear]
  [layer clearTileCache];
  // [END maps_ios_tile_layers_clear]
}

@end
