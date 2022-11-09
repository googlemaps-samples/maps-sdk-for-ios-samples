/*
 * Copyright 2020 Google LLC. All rights reserved.
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

#import "GoogleMapsDemos/Samples/StampedPolylinesViewController.h"

#import <GoogleMaps/GoogleMaps.h>

NS_ASSUME_NONNULL_BEGIN

static const double kSeattleLatitudeDegrees = 47.6089945;
static const double kSeattleLongitudeDegrees = -122.3410462;
static const double kZoom = 14;
static const double kStrokeWidth = 20;

@implementation StampedPolylinesViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSCameraPosition *defaultCamera = [GMSCameraPosition cameraWithLatitude:kSeattleLatitudeDegrees
                                                                 longitude:kSeattleLongitudeDegrees
                                                                      zoom:kZoom];

  GMSMapView *map = [GMSMapView mapWithFrame:self.view.bounds camera:defaultCamera];
  map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:map];

  // Make a texture stamped polyline.
  GMSMutablePath *path = [GMSMutablePath path];
  [path addLatitude:kSeattleLatitudeDegrees + 0.003 longitude:kSeattleLongitudeDegrees - 0.003];
  [path addLatitude:kSeattleLatitudeDegrees - 0.005 longitude:kSeattleLongitudeDegrees - 0.005];
  [path addLatitude:kSeattleLatitudeDegrees - 0.007 longitude:kSeattleLongitudeDegrees + 0.001];

  UIImage *_Nonnull stamp = (UIImage *_Nonnull)[UIImage imageNamed:@"voyager"];
  GMSStrokeStyle *solidStroke = [GMSStrokeStyle solidColor:[UIColor redColor]];
  solidStroke.stampStyle = [GMSTextureStyle textureStyleWithImage:stamp];

  GMSPolyline *texturePolyline = [GMSPolyline polylineWithPath:path];
  texturePolyline.map = map;
  texturePolyline.strokeWidth = kStrokeWidth;
  texturePolyline.spans = @[ [GMSStyleSpan spanWithStyle:solidStroke] ];

  // Make a gradient texture polyline.
  GMSMutablePath *texturePath = [GMSMutablePath path];
  [texturePath addLatitude:kSeattleLatitudeDegrees - 0.012 longitude:kSeattleLongitudeDegrees];
  [texturePath addLatitude:kSeattleLatitudeDegrees - 0.012
                 longitude:kSeattleLongitudeDegrees - 0.008];

  UIImage *_Nonnull textureStamp = (UIImage *_Nonnull)[UIImage imageNamed:@"aeroplane"];

  GMSStrokeStyle *gradientStroke = [GMSStrokeStyle gradientFromColor:[UIColor magentaColor]
                                                             toColor:[UIColor greenColor]];
  gradientStroke.stampStyle = [GMSTextureStyle textureStyleWithImage:textureStamp];

  GMSPolyline *gradientTexturePolyline = [GMSPolyline polylineWithPath:texturePath];
  gradientTexturePolyline.strokeWidth = kStrokeWidth * 1.5;
  gradientTexturePolyline.spans = @[ [GMSStyleSpan spanWithStyle:gradientStroke] ];
  gradientTexturePolyline.zIndex = 1;
  gradientTexturePolyline.map = map;
}

@end

NS_ASSUME_NONNULL_END
