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

#import "GoogleMapsXCFrameworkDemos/Samples/IndoorMuseumNavigationViewController.h"

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

@implementation IndoorMuseumNavigationViewController {
  GMSMapView *_mapView;
  NSArray<NSDictionary<NSString *, id> *> *_exhibits;  // Array of JSON exhibit data.
  NSDictionary<NSString *, id> *_exhibit;  // The currently selected exhibit. Will be nil initially.
  GMSMarker *_marker;
  NSDictionary<NSString *, GMSIndoorLevel *>
      *_levels;  // The levels dictionary is updated when a new building is selected, and
                 // contains mapping from localized level name to GMSIndoorLevel.
}

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38.8879
                                                          longitude:-77.0200
                                                               zoom:17];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  // Opt the MapView in automatic dark mode switching.
  _mapView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
  _mapView.settings.myLocationButton = NO;
  _mapView.settings.indoorPicker = NO;
  _mapView.delegate = self;
  _mapView.indoorDisplay.delegate = self;

  self.view = _mapView;

  // Load the exhibits configuration from JSON
  NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"museum-exhibits" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:jsonPath];
  if (data) {
    _exhibits = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
  }

  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
  [segmentedControl setTintColor:[UIColor colorWithRed:0.373f green:0.667f blue:0.882f alpha:1.0f]];

  segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
  [segmentedControl addTarget:self
                       action:@selector(exhibitSelected:)
             forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:segmentedControl];

  for (NSDictionary<NSString *, NSString *> *exhibit in _exhibits) {
    NSString *exhibitKey = exhibit[@"key"];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:exhibitKey]
                                     atIndex:[_exhibits indexOfObject:exhibit]
                                    animated:NO];
  }

  NSDictionary<NSString *, id> *views = NSDictionaryOfVariableBindings(segmentedControl);

  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[segmentedControl]-|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views]];
  [self.view
      addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[segmentedControl]-|"
                                                             options:kNilOptions
                                                             metrics:nil
                                                               views:views]];
}

- (void)moveMarker {
  CLLocationCoordinate2D loc =
      CLLocationCoordinate2DMake([_exhibit[@"lat"] doubleValue], [_exhibit[@"lng"] doubleValue]);
  if (_marker == nil) {
    _marker = [GMSMarker markerWithPosition:loc];
    _marker.map = _mapView;
  } else {
    _marker.position = loc;
  }
  _marker.title = _exhibit[@"name"];
  [_mapView animateToLocation:loc];
  [_mapView animateToZoom:19];
}

- (void)exhibitSelected:(UISegmentedControl *)segmentedControl {
  _exhibit = _exhibits[[segmentedControl selectedSegmentIndex]];
  [self moveMarker];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)camera {
  if (_exhibit != nil) {
    CLLocationCoordinate2D loc =
        CLLocationCoordinate2DMake([_exhibit[@"lat"] doubleValue], [_exhibit[@"lng"] doubleValue]);
    if ([_mapView.projection containsCoordinate:loc] && _levels != nil) {
      NSString *exhibitForLevel = _exhibit[@"level"];
      [mapView.indoorDisplay setActiveLevel:_levels[exhibitForLevel]];
    }
  }
}

#pragma mark - GMSIndoorDisplayDelegate

- (void)didChangeActiveBuilding:(GMSIndoorBuilding *)building {
  if (building != nil) {
    NSMutableDictionary<NSString *, GMSIndoorLevel *> *levels = [NSMutableDictionary dictionary];

    for (GMSIndoorLevel *level in building.levels) {
      NSString *levelShortName = level.shortName;
      if (levelShortName && levelShortName.length) {
        [levels setObject:level forKey:levelShortName];
      }
    }

    _levels = [NSDictionary dictionaryWithDictionary:levels];
  } else {
    _levels = nil;
  }
}

@end
