/*
 * Copyright 2023 Google LLC. All rights reserved.
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

#import "GoogleMapsXCFrameworkDemos/Samples/DataDrivenStylingSearchViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GoogleMapsXCFrameworkDemos/Common/GMSNotCapturingTouchesTableView.h"
#import "GoogleMapsXCFrameworkDemos/Common/UIViewController+GMSModals.h"
#import "GoogleMapsXCFrameworkDemos/SDKDemoAPIKey.h"
#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

NS_ASSUME_NONNULL_BEGIN

// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style that
// enables the "Administrative Area Level 2" feature layer.
static NSString *const kMapIDWithAdmin2 = @"";

static NSArray<NSString *> *GetInitialSearches(void) {
  return @[ @"Nye County", @"San Bernardino County", @"Juab County", @"Crook County" ];
}

// This demo uses Text Search feature from Places API. The API must be enabled from Cloud Console.
// See https://developers.google.com/maps/documentation/places/web-service/search-textual for
// details.
static NSURLRequest *BuildSearchRequestForPlaceName(NSString *placeName) {
  // NSURL initializer only returns nil when the URL string is malformed, but it is a known valid
  // string literal here.
  NSURL *URL =
      (NSURL *_Nonnull)[NSURL URLWithString:@"https://places.googleapis.com/v1/places:searchText"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
  request.HTTPMethod = @"POST";
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:kAPIKey forHTTPHeaderField:@"X-Goog-Api-Key"];
  [request setValue:@"places.id" forHTTPHeaderField:@"X-Goog-FieldMask"];
  [request setValue:[[NSBundle mainBundle] bundleIdentifier]
      forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
  NSDictionary<NSString *, NSString *> *requestBody = @{
    @"textQuery" : placeName,
    @"includedType" : @"administrative_area_level_2",
    @"languageCode" : @"en"
  };
  request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestBody
                                                     options:(NSJSONWritingOptions)0
                                                       error:nil];
  return request;
}

static NSString *_Nullable ExtractPlaceIDFromSearchResponse(id JSONResponse) {
  if (![JSONResponse isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  id placesArray = ((NSDictionary *)JSONResponse)[@"places"];
  if (![placesArray isKindOfClass:[NSArray class]]) {
    return nil;
  }
  id place = placesArray[0];
  if (![place isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  NSString *ID = place[@"id"];
  if (![ID isKindOfClass:[NSString class]]) {
    return nil;
  }
  return ID;
}

@interface GMSPlaceLookupController
    : NSObject <UITextFieldDelegate, UIColorPickerViewControllerDelegate>

@property(nonatomic, readonly) NSUInteger serial;
@property(nonatomic, nullable) NSString *name;
@property(nonatomic, nullable) UIColor *color;
@property(nonatomic, readonly, nullable) NSString *placeID;

@property(nonatomic, readonly) UIView *view;

- (void)focusTextEdit;

@end

@interface DataDrivenStylingSearchViewController ()

@property(nonatomic, readonly) NSURLSession *URLSession;

- (void)removeFeature:(GMSPlaceLookupController *)feature;

- (void)reloadStyle;

@end

@implementation GMSPlaceLookupController {
  __weak DataDrivenStylingSearchViewController *_controller;

  UITextField *_textField;
  UIButton *_colorSelectionButton;
}

- (instancetype)initWithController:(DataDrivenStylingSearchViewController *)controller
                            serial:(NSUInteger)serial {
  self = [super init];
  if (self) {
    _controller = controller;
    _serial = serial;

    _textField = [[UITextField alloc] init];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    _textField.font = [_textField.font fontWithSize:12];
    _textField.delegate = self;

    _colorSelectionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _colorSelectionButton.titleLabel.font = [_colorSelectionButton.titleLabel.font fontWithSize:12];
    [_colorSelectionButton setTitle:@"❓" forState:UIControlStateNormal];
    [_colorSelectionButton addTarget:self
                              action:@selector(selectionButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];

    _textField.leftView = _colorSelectionButton;
    _textField.leftViewMode = UITextFieldViewModeAlways;

    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectZero];
    clearButton.titleLabel.font = [clearButton.titleLabel.font fontWithSize:12];
    [clearButton setTitle:@"🗑️" forState:UIControlStateNormal];
    [clearButton addTarget:self
                    action:@selector(remove)
          forControlEvents:UIControlEventTouchUpInside];
    _textField.rightView = clearButton;
    _textField.rightViewMode = UITextFieldViewModeUnlessEditing;

    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
  }
  return self;
}

- (UIView *)view {
  return _textField;
}

- (void)setPlaceID:(NSString *)placeID {
  _placeID = [placeID copy];
  [_colorSelectionButton setTitle:@"⬤" forState:UIControlStateNormal];
  [_controller reloadStyle];
}

- (void)setName:(nullable NSString *)name {
  _name = [name copy];
  _textField.text = name;

  if (!name || name.length == 0) {
    return;
  }

  __weak __typeof__(self) weakSelf = self;
  NSString *nonNilName = name;
  NSURLSessionDataTask *dataTask = [_controller.URLSession
      dataTaskWithRequest:BuildSearchRequestForPlaceName(nonNilName)
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          __weak __typeof__(self) strongSelf = weakSelf;
          if (!strongSelf) {
            return;
          }
          if (error != nil) {
            [strongSelf textSearchFailedWithError:error];
            return;
          }
          NSError *JSONError = nil;
          id deserialized = [NSJSONSerialization JSONObjectWithData:data
                                                            options:(NSJSONReadingOptions)0
                                                              error:&JSONError];
          if (JSONError != nil) {
            [strongSelf textSearchFailedWithError:JSONError];
            return;
          }
          NSString *ID = ExtractPlaceIDFromSearchResponse(deserialized);
          if (ID) {
            strongSelf.placeID = ID;
          } else {
            NSError *unrecognizedResponseError =
                [NSError errorWithDomain:NSStringFromClass([strongSelf class])
                                    code:-1
                                userInfo:@{@"response" : deserialized}];
            [strongSelf textSearchFailedWithError:unrecognizedResponseError];
          }
        }];
  [dataTask resume];
}

- (void)setColor:(nullable UIColor *)color {
  _color = color;
  [_colorSelectionButton setTitleColor:color forState:UIControlStateNormal];
  [_controller reloadStyle];
}

- (void)focusTextEdit {
  [_textField becomeFirstResponder];
}

- (void)remove {
  [_controller removeFeature:self];
}

- (void)textSearchFailedWithError:(NSError *)error {
  [_colorSelectionButton setTitle:@"❗" forState:UIControlStateNormal];
  NSLog(@"Feature \"%@\" not found: %@", self.name, error);
}

- (void)selectionButtonTapped:(UIButton *)sender {
  UIColorPickerViewController *selector = [[UIColorPickerViewController alloc] init];
  selector.selectedColor = _color ?: UIColor.whiteColor;
  selector.supportsAlpha = NO;
  selector.delegate = self;
  [_controller presentModalViewController:selector animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  NSString *text = [textField.text
      stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
  if (!text.length) {
    [_colorSelectionButton setTitle:@"❓" forState:UIControlStateNormal];
    return;
  }
  if ([self.name isEqualToString:text]) {
    return;
  }
  [_colorSelectionButton setTitle:@"⏳" forState:UIControlStateNormal];
  self.name = text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // Finishes editing when pressing Enter.
  [textField resignFirstResponder];
  return NO;
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController {
  self.color = viewController.selectedColor;
}

@end

@implementation DataDrivenStylingSearchViewController {
  GMSMapView *_mapView;
  UITableViewDiffableDataSource *_dataSource;
  UITableView *_tableView;

  NSUInteger _placeSerial;

  NSMutableDictionary<NSNumber *, GMSPlaceLookupController *> *_places;
  NSDictionary<NSString *, UIColor *> *_computedColorMapping;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _places = [NSMutableDictionary dictionary];
    _URLSession = [NSURLSession
        sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                        delegate:nil
                   delegateQueue:[NSOperationQueue mainQueue]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (kMapIDWithAdmin2.length) {
    [self setUpMapWithMapID:kMapIDWithAdmin2];
    return;
  }

  __weak __typeof__(self) weakSelf = self;
  [self gms_promptForMapIDWithDescription:@"with Administrative Area Level 2 layer enabled"
                                  handler:^(NSString *mapID) {
                                    [weakSelf setUpMapWithMapID:mapID];
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

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40 longitude:-117.5 zoom:5.5];
  _mapView = [GMSMapView mapWithFrame:CGRectZero
                                mapID:[GMSMapID mapIDWithIdentifier:mapIDString]
                               camera:camera];
  [self.view addSubview:_mapView];
  _mapView.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [_mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [_mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [_mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [_mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
  ]];

  NSString *cellIdentifier = NSStringFromClass([self class]);
  _tableView = [[GMSNotCapturingTouchesTableView alloc] initWithFrame:CGRectZero
                                                                style:UITableViewStylePlain];
  [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  _tableView.rowHeight = 28;
  _tableView.backgroundView = nil;
  _tableView.backgroundColor = UIColor.clearColor;

  NSMutableDictionary<NSNumber *, GMSPlaceLookupController *> *places = _places;
  _dataSource = [[UITableViewDiffableDataSource alloc]
      initWithTableView:_tableView
           cellProvider:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath,
                                           NSNumber *itemIdentifier) {
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                     forIndexPath:indexPath];
             [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
             UIView *view = places[itemIdentifier].view;
             [cell.contentView addSubview:view];
             cell.backgroundColor = [UIColor clearColor];
             [NSLayoutConstraint activateConstraints:@[
               [cell.contentView.topAnchor constraintEqualToAnchor:view.topAnchor],
               [cell.contentView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
               [cell.contentView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
               [cell.contentView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor]
             ]];

             return cell;
           }];
  _tableView.dataSource = _dataSource;
  _tableView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_tableView];

  __weak __typeof__(self) weakSelf = self;
  UIAction *addAction = [UIAction actionWithTitle:@"+"
                                            image:nil
                                       identifier:nil
                                          handler:^(UIAction *action) {
                                            [weakSelf addButtonTapped];
                                          }];
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithPrimaryAction:addAction];

  [NSLayoutConstraint activateConstraints:@[
    [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [_tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.5]
  ]];

  NSArray<NSString *> *initialSearches = GetInitialSearches();
  NSMutableArray<NSNumber *> *identifiers =
      [NSMutableArray arrayWithCapacity:initialSearches.count];
  for (NSString *search in initialSearches) {
    [identifiers addObject:@([self addFeatureWithText:search])];
  }
  NSDiffableDataSourceSnapshot *diff = [[NSDiffableDataSourceSnapshot alloc] init];
  [diff appendSectionsWithIdentifiers:@[ @0 ]];
  [diff appendItemsWithIdentifiers:identifiers];
  [_dataSource applySnapshot:diff animatingDifferences:NO];
}

- (void)addButtonTapped {
  NSNumber *itemIdentifier = @([self addFeatureWithText:nil]);
  GMSPlaceLookupController *lookup = _places[itemIdentifier];

  NSDiffableDataSourceSnapshot *diff = [_dataSource snapshot];
  [diff appendItemsWithIdentifiers:@[ itemIdentifier ]];
  [_dataSource applySnapshot:diff animatingDifferences:NO];

  dispatch_async(dispatch_get_main_queue(), ^{
    [lookup focusTextEdit];
  });
}

- (CGFloat)nextColorHue {
  NSMutableArray<NSNumber *> *hueValues = [NSMutableArray arrayWithCapacity:_places.count];
  for (GMSPlaceLookupController *config in _places.objectEnumerator) {
    CGFloat hueValue = 0.f;
    if ([config.color getHue:&hueValue saturation:nil brightness:nil alpha:nil]) {
      if (hueValue > 1 || hueValue < 0) {
        continue;
      }
      [hueValues addObject:@(hueValue)];
    }
  }
  float candidateHue = hueValues.firstObject.floatValue - 0.5f;
  if (hueValues.count > 1) {
    [hueValues sortUsingSelector:@selector(compare:)];
    CGFloat endOfLargestGap = hueValues.firstObject.floatValue;
    CGFloat largestGap = 1 + endOfLargestGap - hueValues.lastObject.floatValue;
    for (NSUInteger i = 1; i < hueValues.count; i++) {
      CGFloat gap = hueValues[i].floatValue - hueValues[i - 1].floatValue;
      if (gap > largestGap) {
        endOfLargestGap = hueValues[i].floatValue;
        largestGap = gap;
      }
    }
    candidateHue = endOfLargestGap - largestGap / 2;
  }
  if (candidateHue < 0) {
    candidateHue += 1.f;
  }
  return candidateHue;
}

- (NSUInteger)addFeatureWithText:(nullable NSString *)text {
  NSUInteger itemIdentifier = ++_placeSerial;

  GMSPlaceLookupController *featureConfig =
      [[GMSPlaceLookupController alloc] initWithController:self serial:itemIdentifier];

  featureConfig.color = [UIColor colorWithHue:[self nextColorHue]
                                   saturation:1
                                   brightness:0.75
                                        alpha:1];
  featureConfig.name = text;
  _places[@(itemIdentifier)] = featureConfig;

  return itemIdentifier;
}

- (void)removeFeature:(GMSPlaceLookupController *)feature {
  if (_places.count == 1) {
    return;
  }

  NSDiffableDataSourceSnapshot *diff = [_dataSource snapshot];
  [diff deleteItemsWithIdentifiers:@[ @(feature.serial) ]];
  [_dataSource applySnapshot:diff animatingDifferences:NO];

  [_places removeObjectForKey:@(feature.serial)];
  [self reloadStyle];
}

- (void)reloadStyle {
  NSMutableDictionary<NSString *, UIColor *> *colorMapping = [NSMutableDictionary dictionary];
  for (GMSPlaceLookupController *config in _places.objectEnumerator) {
    NSString *placeID = config.placeID;
    if (placeID != nil) {
      colorMapping[placeID] = config.color;
    }
  }
  if ([_computedColorMapping isEqualToDictionary:colorMapping]) {
    // Skip restyling if the mapping hasn't actually changed, since restyling can be expensive.
    return;
  }
  _computedColorMapping = colorMapping;

  [_mapView featureLayerOfFeatureType:GMSFeatureTypeAdministrativeAreaLevel2].style =
      ^GMSFeatureStyle *(GMSPlaceFeature *feature) {
    UIColor *color = colorMapping[feature.placeID];
    if (!color) {
      return nil;
    }
    return [GMSFeatureStyle styleWithFillColor:[color colorWithAlphaComponent:0.5]
                                   strokeColor:color
                                   strokeWidth:1.5];
  };
}

@end

NS_ASSUME_NONNULL_END
