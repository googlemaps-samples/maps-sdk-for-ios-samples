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

#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingBasicViewController.h"

#import <UIKit/UIKit.h>

#import "GoogleMapsXCFrameworkDemos/Common/UIViewController+GMSModals.h"
#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style that
// enables the "Administrative Area Level 2" feature layer.
static NSString *const kMapIDWithAdministrativeAreaLevel2 = @"";
// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style that
// enables the "Postal Code" feature layer.
static NSString *const kMapIDWithPostalCode = @"";
// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style that
// enables the "Country" feature layer.
static NSString *const kMapIDWithCountry = @"";

@interface DataDrivenStylingFeatureLayerConfig : NSObject

- (instancetype)initWithTitle:(NSString *)title
                         type:(GMSFeatureType)type
                        mapID:(NSString *)mapID
           highlightPlaceName:(NSString *)highlightPlaceName
             highlightPlaceID:(NSString *)highlightPlaceID;

@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) GMSFeatureType type;
@property(nonatomic, readwrite) NSString *mapID;
@property(nonatomic, readonly) NSString *highlightPlaceName;
@property(nonatomic, readonly) NSString *highlightPlaceID;

@end

@implementation DataDrivenStylingFeatureLayerConfig

- (instancetype)initWithTitle:(NSString *)title
                         type:(GMSFeatureType)type
                        mapID:(NSString *)mapID
           highlightPlaceName:(NSString *)highlightPlaceName
             highlightPlaceID:(NSString *)highlightPlaceID {
  self = [super init];
  if (self) {
    _title = title;
    _type = type;
    _mapID = mapID;
    _highlightPlaceName = highlightPlaceName;
    _highlightPlaceID = highlightPlaceID;
  }
  return self;
}

@end

@implementation DataDrivenStylingBasicViewController {
  NSArray<DataDrivenStylingFeatureLayerConfig *> *_configs;
  GMSMapView *_mapView;
  UISegmentedControl *_segmentedControl;
  UISwitch *_toggle;
  NSMutableArray<NSArray<UISlider *> *> *_sliderControls;
  GMSFeatureLayer *_layer;
}

- (instancetype)init {
  if ((self = [super init])) {
    _configs = @[
      [[DataDrivenStylingFeatureLayerConfig alloc]
               initWithTitle:@"Administrative Area Level 2"
                        type:GMSFeatureTypeAdministrativeAreaLevel2
                       mapID:kMapIDWithAdministrativeAreaLevel2
          /** Place name and ID for Nye County, Nevada. The area will be highlighted. */
          highlightPlaceName:@"Nye County, NV"
            highlightPlaceID:@"ChIJJcLL_DeWvoARQyqHFcY2se4"],
      [[DataDrivenStylingFeatureLayerConfig alloc]
               initWithTitle:@"Postal Code"
                        type:GMSFeatureTypePostalCode
                       mapID:kMapIDWithPostalCode
          /** Place name and ID for Zipcode 89049. The area will be highlighted. */
          highlightPlaceName:@"89049"
            highlightPlaceID:@"ChIJCY_aZdEwuoARZDbZn-snj68"],
      [[DataDrivenStylingFeatureLayerConfig alloc]
               initWithTitle:@"Country"
                        type:GMSFeatureTypeCountry
                       mapID:kMapIDWithCountry
          /** Place name and ID for the country Senegal. The area will be highlighted. */
          highlightPlaceName:@"Senegal"
            highlightPlaceID:@"ChIJcbvFs_VywQ4RQFlhmVClRlo"],
    ];
  }
  return self;
}

- (DataDrivenStylingFeatureLayerConfig *)activeConfig {
  if (_segmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
    return nil;
  }
  return _configs[_segmentedControl.selectedSegmentIndex];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _segmentedControl = [[UISegmentedControl alloc] initWithItems:[_configs valueForKey:@"title"]];
  [_segmentedControl addTarget:self
                        action:@selector(changeMapType:)
              forControlEvents:UIControlEventValueChanged];

  _toggle = [[UISwitch alloc] initWithFrame:CGRectZero];
  [_toggle addTarget:self
                action:@selector(activateFeatureLayer:)
      forControlEvents:UIControlEventValueChanged];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_toggle];
  self.navigationItem.titleView = _segmentedControl;

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.text = @"Select a feature type";
  label.textAlignment = NSTextAlignmentCenter;
  self.view = label;
}

- (void)changeMapType:(id)sender {
  if (_segmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
    return;
  }

  // Camera position that roughly covers the contiguous United States.
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38.590240
                                                          longitude:-95.712891
                                                               zoom:4];
  DataDrivenStylingFeatureLayerConfig *config = self.activeConfig;
  if (!config.mapID.length) {
    [self gms_promptForMapIDWithDescription:[NSString stringWithFormat:@"with %@ layer enabled",
                                                                       config.title]
                                    handler:^(NSString *mapID) {
                                      if (mapID.length) {
                                        config.mapID = mapID;
                                      } else {
                                        _segmentedControl.selectedSegmentIndex =
                                            UISegmentedControlNoSegment;
                                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                                        label.text = @"A Map ID is required";
                                        label.textAlignment = NSTextAlignmentCenter;
                                        self.view = label;
                                      }
                                      [self changeMapType:nil];
                                    }];
    return;
  }

  _mapView = [GMSMapView mapWithFrame:CGRectZero
                                mapID:[GMSMapID mapIDWithIdentifier:config.mapID]
                               camera:camera];
  self.view = _mapView;
  [self setUpStyleControls];
  [_toggle setOn:NO animated:NO];
  _layer = [_mapView featureLayerOfFeatureType:self.activeConfig.type];
}

- (UISlider *)addSliderInParent:(UIStackView *)parent
                          label:(NSString *)label
                   initialValue:(float)value {
  UILabel *uiLabel = [[UILabel alloc] init];
  uiLabel.text = label;
  uiLabel.font = [uiLabel.font fontWithSize:9];
  [parent addArrangedSubview:uiLabel];

  UISlider *slider = [[UISlider alloc] init];
  slider.value = value;
  [parent addArrangedSubview:slider];
  [slider addTarget:self
                action:@selector(activateFeatureLayer:)
      forControlEvents:UIControlEventValueChanged];
  return slider;
}

- (UIStackView *)setUpStyleControlForTitle:(NSString *)title index:(NSUInteger)index {
  UIStackView *stackView = [[UIStackView alloc] init];
  stackView.axis = UILayoutConstraintAxisVertical;
  stackView.translatesAutoresizingMaskIntoConstraints = NO;
  stackView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];

  // The first style control is for the single area being highlighted while the second one is the
  // base style for all other areas.
  BOOL isBaseStyle = index > 0;
  _sliderControls[index] = @[
    [self addSliderInParent:stackView label:@"Fill color" initialValue:isBaseStyle ? 0.5 : 0.75],
    [self addSliderInParent:stackView label:@"Stroke color" initialValue:isBaseStyle ? 0 : 0.25],
    [self addSliderInParent:stackView label:@"Stroke width" initialValue:isBaseStyle ? 0.1 : 0.2]
  ];

  UILabel *label = [[UILabel alloc] init];
  label.text = title;
  label.font = [label.font fontWithSize:10];
  label.textAlignment = NSTextAlignmentCenter;
  [stackView addArrangedSubview:label];

  return stackView;
}

- (void)setUpStyleControls {
  _sliderControls = [NSMutableArray arrayWithCapacity:2];
  UIStackView *leftStackView = [self setUpStyleControlForTitle:self.activeConfig.highlightPlaceName
                                                         index:0];
  UIStackView *rightStackView = [self setUpStyleControlForTitle:@"Others" index:1];

  [self.view addSubview:leftStackView];
  [self.view addSubview:rightStackView];

  [NSLayoutConstraint activateConstraints:@[
    [leftStackView.widthAnchor constraintEqualToAnchor:rightStackView.widthAnchor],
    [leftStackView.trailingAnchor constraintEqualToAnchor:rightStackView.leadingAnchor],
    [leftStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [rightStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [leftStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    [rightStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
  ]];
}

+ (GMSFeatureStyle *)styleFromControls:(NSArray<UISlider *> *)controls {
  UIColor *fillColor = [UIColor colorWithHue:controls[0].value
                                  saturation:1
                                  brightness:0.5
                                       alpha:0.5];
  UIColor *strokeColor = [UIColor colorWithHue:controls[1].value
                                    saturation:1
                                    brightness:0.5
                                         alpha:1];
  CGFloat strokeWidth = controls[2].value * 15;
  return [GMSFeatureStyle styleWithFillColor:fillColor
                                 strokeColor:strokeColor
                                 strokeWidth:strokeWidth];
}

- (void)activateFeatureLayer:(id *)sender {
  DataDrivenStylingFeatureLayerConfig *config = self.activeConfig;
  NSString *placeID = config.highlightPlaceID;
  if (_toggle.on) {
    if (!_layer.isAvailable) {
      [self gms_showToastWithMessage:[NSString
                                         stringWithFormat:@"Feature layer %@ is not available on "
                                                          @"map ID %@; see debug log for details",
                                                          config.title, config.mapID]];
    }
    GMSFeatureStyle *specialStyle = [[self class] styleFromControls:_sliderControls[0]];
    GMSFeatureStyle *style = [[self class] styleFromControls:_sliderControls[1]];
    _layer.style = ^(GMSPlaceFeature *feature) {
      return [placeID isEqualToString:((GMSPlaceFeature *)feature).placeID] ? specialStyle : style;
    };
  } else {
    _layer.style = nil;
  }
}

@end
