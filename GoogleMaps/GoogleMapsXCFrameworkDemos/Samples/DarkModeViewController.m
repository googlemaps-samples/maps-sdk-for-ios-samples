/*
 * Copyright 2024 Google LLC. All rights reserved.
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

#import "GoogleMapsXCFrameworkDemos/Samples/DarkModeViewController.h"

#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

static const CLLocationCoordinate2D kSeattleCoordinate = {.latitude = 47.6098,
                                                          .longitude = -122.335};
// Names for map types.
static NSString *const kNormalType = @"Normal";
static NSString *const kSatelliteType = @"Satellite";
static NSString *const kHybridType = @"Hybrid";
static NSString *const kTerrainType = @"Terrain";
// Name for checkmark image.
static NSString *const kCheckmarkImageName = @"checkmark";

@implementation DarkModeViewController {
  UISegmentedControl *_switcher;
  UIBarButtonItem *_updateDarkMode;
  GMSMapView *_mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Seattle coordinates
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:kSeattleCoordinate zoom:14];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  _mapView.delegate = self;
  self.view = _mapView;

  // The possible different map types to show.
  NSArray<NSString *> *mapTypes = @[ kNormalType, kSatelliteType, kHybridType, kTerrainType ];

  // Create a UISegmentedControl that is the navigationItem's titleView.
  _switcher = [[UISegmentedControl alloc] initWithItems:mapTypes];
  _switcher.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                               UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleBottomMargin;
  _switcher.selectedSegmentIndex = 0;
  self.navigationItem.titleView = _switcher;

  // Listen to touch events on the UISegmentedControl.
  [_switcher addTarget:self
                action:@selector(didChangeSwitcher)
      forControlEvents:UIControlEventValueChanged];

  _updateDarkMode = [[UIBarButtonItem alloc] initWithTitle:@"Mode" menu:[self selectModeMenu]];
  _updateDarkMode.enabled = NO;
  self.navigationItem.rightBarButtonItem = _updateDarkMode;
}

- (UIMenu *)selectModeMenu {
  NSString *overrideToUnspecifiedTitle = @"Override userInterfaceStyle to unspecified";
  UIAction *overrideToUnspecified = [UIAction actionWithTitle:overrideToUnspecifiedTitle
                                                        image:nil
                                                   identifier:nil
                                                      handler:^(UIAction *action) {
                                                        _mapView.overrideUserInterfaceStyle =
                                                            UIUserInterfaceStyleUnspecified;
                                                      }];

  overrideToUnspecified.accessibilityLabel = overrideToUnspecifiedTitle;
  NSString *overrideToDarkTitle = @"Override userInterfaceStyle to Dark";
  UIAction *overrideToDark = [UIAction actionWithTitle:overrideToDarkTitle
                                                 image:nil
                                            identifier:nil
                                               handler:^(UIAction *action) {
                                                 _mapView.overrideUserInterfaceStyle =
                                                     UIUserInterfaceStyleDark;
                                               }];

  overrideToDark.accessibilityLabel = overrideToDarkTitle;

  NSString *overrideToLightTitle = @"Override userInterfaceStyle to Light";
  UIAction *overrideToLight = [UIAction actionWithTitle:overrideToLightTitle
                                                  image:nil
                                             identifier:nil
                                                handler:^(UIAction *action) {
                                                  _mapView.overrideUserInterfaceStyle =
                                                      UIUserInterfaceStyleLight;
                                                }];
  overrideToLight.accessibilityLabel = overrideToLightTitle;
  return [UIMenu menuWithTitle:@"Dark mode settings"
                         image:[UIImage systemImageNamed:kCheckmarkImageName]
                    identifier:nil
                       options:UIMenuOptionsSingleSelection
                      children:@[ overrideToUnspecified, overrideToDark, overrideToLight ]];
}

- (void)didChangeSwitcher {
  // Update the map view based on the selected map type.
  NSString *title = [_switcher titleForSegmentAtIndex:_switcher.selectedSegmentIndex] ?: @"";
  if ([kNormalType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeNormal;
  } else if ([kSatelliteType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeSatellite;
  } else if ([kHybridType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeHybrid;
  } else if ([kTerrainType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeTerrain;
  }
}

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
  _updateDarkMode.enabled = YES;
}

@end
