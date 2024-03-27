/*
 * Copyright 2022 Google LLC. All rights reserved.
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

#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingEventsViewController.h"

#import "GoogleMapsXCFrameworkDemos/Common/UIViewController+GMSModals.h"
#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style that
// enables all data-driven styling feature layers.
static NSString *const kMapIDWithMultipleLayers = @"";

static const double kSeattleLatitudeDegrees = 47.61;
static const double kSeattleLongitudeDegrees = -122.34;
static const double kZoom = 10;

static NSString *const kCellIdentifierForLayerToggle = @"kCellIdentifierForLayerToggle";
static NSString *const kCellIdentifierForSelectedFeatureName =
    @"kCellIdentifierForSelectedFeatureName";

typedef GMSFeatureStyle * (^GMSPlaceFeatureStyleBlock)(GMSPlaceFeature *);

@interface FeatureLayerState : NSObject

- (instancetype)initWithType:(GMSFeatureType)featureType
                       label:(NSString *)label
                       color:(UIColor *)color;

- (NSInteger)selectedFeatureCount;
- (NSString *)selectedFeatureNameAtIndex:(NSInteger)index;

- (void)unselectFeatureAtIndex:(NSInteger)index;
- (void)toggleSelectionOfFeatures:(NSArray<GMSPlaceFeature *> *)features
                textUpdateHandler:(void (^)())handler;

- (GMSPlaceFeatureStyleBlock)makeStyleBlock;

@property(nonatomic, readonly) GMSFeatureType type;
@property(nonatomic, readonly, nonnull) NSString *label;
@property(nonatomic, readonly, nonnull) UIColor *color;
@property(nonatomic, readwrite, nullable) GMSFeatureLayer *layer;

@end

@implementation FeatureLayerState {
  NSMutableDictionary<NSString *, NSString *> *_featureNamesByPlaceID;
  NSMutableArray<NSString *> *_selectedFeaturePlaceIDs;
}

- (instancetype)initWithType:(GMSFeatureType)featureType
                       label:(NSString *)label
                       color:(UIColor *)color {
  self = [super init];
  if (self) {
    _type = featureType;
    _label = label;
    _color = color;
    _featureNamesByPlaceID = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSInteger)selectedFeatureCount {
  return _selectedFeaturePlaceIDs.count;
}

- (NSString *)selectedFeatureNameAtIndex:(NSInteger)index {
  return _featureNamesByPlaceID[_selectedFeaturePlaceIDs[index]];
}

- (void)unselectFeatureAtIndex:(NSInteger)index {
  NSString *placeID = _selectedFeaturePlaceIDs[index];
  [_featureNamesByPlaceID removeObjectForKey:placeID];
  [_selectedFeaturePlaceIDs removeObjectAtIndex:index];
}

- (void)toggleSelectionOfFeatures:(NSArray<GMSPlaceFeature *> *)features
                textUpdateHandler:(void (^)())handler {
  for (id<GMSFeature> feature in features) {
    // For these feature types, feature instances would certainly be GMSPlaceFeature.
    GMSPlaceFeature *place = (GMSPlaceFeature *)feature;
    NSString *placeID = place.placeID;
    if (_featureNamesByPlaceID[placeID]) {
      [_featureNamesByPlaceID removeObjectForKey:placeID];
    } else {
      _featureNamesByPlaceID[placeID] = [NSString stringWithFormat:@"[Place %@]", placeID];
    }
  }
  _selectedFeaturePlaceIDs =
      [[_featureNamesByPlaceID keysSortedByValueUsingSelector:@selector(compare:)] mutableCopy];
}

- (GMSPlaceFeatureStyleBlock)makeStyleBlock {
  GMSFeatureStyle *nonSelectedStyle =
      [GMSFeatureStyle styleWithFillColor:[self.color colorWithAlphaComponent:0.25]
                              strokeColor:self.color
                              strokeWidth:1.5];
  GMSFeatureStyle *selectedStyle =
      [GMSFeatureStyle styleWithFillColor:[self.color colorWithAlphaComponent:0.5]
                              strokeColor:self.color
                              strokeWidth:3];
  return ^(GMSPlaceFeature *feature) {
    NSString *placeID = (((GMSPlaceFeature *)feature).placeID);
    return _featureNamesByPlaceID[placeID] ? selectedStyle : nonSelectedStyle;
  };
}

@end

@implementation DataDrivenStylingEventsViewController {
  NSArray<FeatureLayerState *> *_featureLayerStates;
  UITableView *_tableView;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _featureLayerStates = @[
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypeCountry
                                        label:@"Country"
                                        color:[UIColor purpleColor]],
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypeAdministrativeAreaLevel1
                                        label:@"Administrative Area Level 1"
                                        color:[UIColor orangeColor]],
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypeAdministrativeAreaLevel2
                                        label:@"Administrative Area Level 2"
                                        color:[UIColor blueColor]],
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypeLocality
                                        label:@"Locality"
                                        color:[UIColor redColor]],
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypePostalCode
                                        label:@"Postal Code"
                                        color:[UIColor brownColor]],
      [[FeatureLayerState alloc] initWithType:GMSFeatureTypeSchoolDistrict
                                        label:@"School District"
                                        color:[UIColor cyanColor]],
    ];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (kMapIDWithMultipleLayers.length) {
    [self setUpMapWithMapID:kMapIDWithMultipleLayers];
    return;
  }

  [self gms_promptForMapIDWithDescription:@"with all data-driven styling layers enabled"
                                  handler:^(NSString *mapID) {
                                    [self setUpMapWithMapID:mapID];
                                  }];
}

- (void)setUpMapWithMapID:(NSString *)mapIDString {
  if (!mapIDString.length) {
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
    text.text = @"A Map ID is required";
    text.textAlignment = NSTextAlignmentCenter;
    self.view = text;
    return;
  }

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:kSeattleLatitudeDegrees
                                                          longitude:kSeattleLongitudeDegrees
                                                               zoom:kZoom];
  GMSMapID *mapID = [GMSMapID mapIDWithIdentifier:mapIDString];
  GMSMapView *_mapView = [GMSMapView mapWithFrame:CGRectZero mapID:mapID camera:camera];
  _mapView.delegate = self;
  self.view = _mapView;

  _tableView = [[UITableView alloc] init];
  _tableView.dataSource = self;
  _tableView.delegate = self;
  _tableView.translatesAutoresizingMaskIntoConstraints = NO;
  _tableView.backgroundView = nil;
  _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
  _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  _tableView.contentInset = UIEdgeInsetsMake(0, -10, 0, -10);
  [self.view addSubview:_tableView];
  [NSLayoutConstraint activateConstraints:@[
    [_tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor
                                             constant:-120],
    [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
  ]];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Toggle buttons (1), then selected feature list of each feature layer.
  return 1 + [_featureLayerStates count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    // The first section is for the toggle buttons for each layer.
    return [_featureLayerStates count];
  }
  // Count of selected features in the corresponding feature layer.
  return _featureLayerStates[section - 1].selectedFeatureCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL isToggleControl = indexPath.section == 0;
  NSString *cellIdentifier =
      isToggleControl ? kCellIdentifierForLayerToggle : kCellIdentifierForSelectedFeatureName;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
  }
  UILabel *textLabel = cell.textLabel;
  if (isToggleControl) {
    FeatureLayerState *featureLayerState = _featureLayerStates[indexPath.row];
    textLabel.text = [NSString stringWithFormat:@"%@ %@", (featureLayerState.layer ? @"☑" : @"☐"),
                                                featureLayerState.label];
    textLabel.font = [textLabel.font fontWithSize:14];
    textLabel.textColor =
        [featureLayerState.color colorWithAlphaComponent:(featureLayerState.layer ? 1 : 0.75)];
  } else {
    FeatureLayerState *featureLayerState = _featureLayerStates[indexPath.section - 1];
    textLabel.text = [featureLayerState selectedFeatureNameAtIndex:indexPath.row];
    textLabel.font = [textLabel.font fontWithSize:12];
    textLabel.textColor = featureLayerState.color;
  }
  return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section == 0) ? 36 : 24;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    // Toggle a layer on/off.
    FeatureLayerState *state = _featureLayerStates[indexPath.row];
    if (state.layer) {
      state.layer.style = nil;
      state.layer = nil;
    } else {
      state.layer = [(GMSMapView *)(self.view) featureLayerOfFeatureType:state.type];
      state.layer.style = [state makeStyleBlock];
      if (!state.layer.isAvailable) {
        [self gms_showToastWithMessage:[NSString
                                           stringWithFormat:@"Feature layer %@ is not available; "
                                                            @"see debug log for details",
                                                            state.label]];
      }
    }
    [_tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
  } else {
    FeatureLayerState *state = _featureLayerStates[indexPath.section - 1];
    [state unselectFeatureAtIndex:indexPath.row];
    state.layer.style = [state makeStyleBlock];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
              withRowAnimation:UITableViewRowAnimationNone];
  }
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
    didTapFeatures:(NSArray<id<GMSFeature>> *)features
    inFeatureLayer:(GMSFeatureLayer *)featureLayer
        atLocation:(CLLocationCoordinate2D)location {
  NSUInteger index = [_featureLayerStates
      indexOfObjectPassingTest:^BOOL(FeatureLayerState *state, NSUInteger idx, BOOL *stop) {
        return state.layer == featureLayer;
      }];
  if (index == NSNotFound) {
    return;
  }

  FeatureLayerState *state = _featureLayerStates[index];
  void (^reloadRows)() = ^{
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:(1 + index)]
              withRowAnimation:UITableViewRowAnimationNone];
  };
  [state toggleSelectionOfFeatures:features textUpdateHandler:reloadRows];
  state.layer.style = [state makeStyleBlock];

  reloadRows();
}

@end
