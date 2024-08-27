// Copyright 2024 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIAction.h>
#import <UIKit/UIKit.h>
#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif
#import "GooglePlacesXCFrameworkDemos/Samples/SearchNearbyViewController.h"

static NSString *const kCellIdentifier = @"NearbySearchCellIdentifier";
static NSString *const kGoogleMTV = @"Google Mountain View";
static NSString *const kGoogleSunnyvale = @"Google Sunnyvale";
static NSString *const kGoogleSanFrancisco = @"Google San Francisco";

static NSString *const kGoogleMTVLatitude = @"37.422095";
static NSString *const kGoogleMTVLongitude = @"-122.085430";
static NSString *const kGoogleSunnyvaleLatitude = @"37.407022";
static NSString *const kGoogleSunnyvaleLongitude = @"-122.021402";
static NSString *const kGoogleSanFranciscoLatitude = @"37.790736";
static NSString *const kGoogleSanFranciscoLongitude = @"-122.390152";

static BOOL IsValidNumber(NSString *string) {
  if (!string) {
    return NO;
  }
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  NSNumber *number = [formatter numberFromString:string];
  return (number != nil);
}

/**
 * Converts the input string to lowercase, splits it by commas, removes any whitespace, and returns
 * an array of lowercase NSString objects.
 */
static NSArray<NSString *> *SplitStringToArray(NSString *string) {
  if (!string) {
    return @[];
  }
  string = [string lowercaseString];
  NSArray<NSString *> *components = [string componentsSeparatedByString:@","];
  NSMutableArray<NSString *> *trimmedComponents = [NSMutableArray array];
  for (NSString *component in components) {
    // Clear whitespace
    NSString *trimmedComponent =
        [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![trimmedComponent isEqualToString:@""]) {
      [trimmedComponents addObject:trimmedComponent];
    }
  }
  return trimmedComponents;
}

@implementation ParameterInputTextField

- (instancetype)initWithTitle:(NSString *)title {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.text = title;

    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.backgroundColor = [UIColor secondarySystemBackgroundColor];
    _textField.delegate = self;

    UIStackView *stackView =
        [[UIStackView alloc] initWithArrangedSubviews:@[ _titleLabel, _textField ]];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
      [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
      [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
      [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
      [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
  }
  return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end

@interface SearchNearbyViewController () <UITextFieldDelegate,
                                          UITableViewDelegate,
                                          UITableViewDataSource>

@end

@implementation SearchNearbyViewController {
  UIScrollView *_scrollView;
  UIStackView *_scrollViewStackView;
  UITextField *_latitudeField;
  UITextField *_longitudeField;
  UITextField *_radiusField;
  ParameterInputTextField *_placeProperties;
  ParameterInputTextField *_includedTypes;
  ParameterInputTextField *_excludedTypes;
  ParameterInputTextField *_includedPrimaryTypes;
  ParameterInputTextField *_excludedPrimaryTypes;
  ParameterInputTextField *_maxResultCount;
  ParameterInputTextField *_regionCode;
  UISegmentedControl *_rankPreference;
  NSLayoutConstraint *_tableViewHeightConstraint;
  UITableView *_tableView;
  NSArray<GMSPlace *> *_placeResults;
  UIButton *_searchNearbyButton;
}

+ (NSString *)demoTitle {
  return @"Search Nearby";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor systemBackgroundColor];
  UIBarButtonItem *placesButton = [[UIBarButtonItem alloc] initWithTitle:@"Places"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
  placesButton.menu = [self setupPlacesMenu];
  self.navigationItem.rightBarButtonItem = placesButton;

  [self setUpScrollView];
  [self setUpLocationTextFields];
  [self setUpParametersTextFields];
  [self addSearchNearbyButton];
  [self setUpTableView];

  _placeResults = [NSArray array];
}

- (void)setUpScrollView {
  UIView *view = self.view;
  _scrollView = [[UIScrollView alloc] init];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:_scrollView];

  _scrollViewStackView = [[UIStackView alloc] init];
  _scrollViewStackView.axis = UILayoutConstraintAxisVertical;
  _scrollViewStackView.spacing = 16;
  _scrollViewStackView.distribution = UIStackViewDistributionFillProportionally;
  _scrollViewStackView.translatesAutoresizingMaskIntoConstraints = NO;
  [_scrollView addSubview:_scrollViewStackView];

  [NSLayoutConstraint activateConstraints:@[
    [_scrollView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
    [_scrollView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
    [_scrollView.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor],
    [_scrollView.bottomAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.bottomAnchor],
    [_scrollView.widthAnchor constraintEqualToAnchor:view.widthAnchor],

    [_scrollViewStackView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor],
    [_scrollViewStackView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor],
    [_scrollViewStackView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor],
  ]];
}

- (void)setUpLocationTextFields {
  UIStackView *stackView = [[UIStackView alloc] init];
  stackView.axis = UILayoutConstraintAxisHorizontal;
  stackView.distribution = UIStackViewDistributionFillEqually;
  stackView.translatesAutoresizingMaskIntoConstraints = NO;

  _latitudeField = [[UITextField alloc] init];
  _latitudeField.borderStyle = UITextBorderStyleRoundedRect;
  _latitudeField.textColor = [UIColor labelColor];
  _latitudeField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  _latitudeField.placeholder = @"Latitude";
  _latitudeField.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _latitudeField.delegate = self;

  _longitudeField = [[UITextField alloc] init];
  _longitudeField.borderStyle = UITextBorderStyleRoundedRect;
  _longitudeField.textColor = [UIColor labelColor];
  _longitudeField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  _longitudeField.placeholder = @"Longitude";
  _longitudeField.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _longitudeField.delegate = self;

  _radiusField = [[UITextField alloc] init];
  _radiusField.borderStyle = UITextBorderStyleRoundedRect;
  _radiusField.textColor = [UIColor labelColor];
  _radiusField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  _radiusField.placeholder = @"Radius";
  _radiusField.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _radiusField.delegate = self;

  [stackView addArrangedSubview:_latitudeField];
  [stackView addArrangedSubview:_longitudeField];
  [stackView addArrangedSubview:_radiusField];

  [_scrollViewStackView addArrangedSubview:stackView];

  UIView *view = self.view;
  [NSLayoutConstraint activateConstraints:@[
    [stackView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
    [stackView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
  ]];
}

- (void)setUpParametersTextFields {
  UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
  stackView.axis = UILayoutConstraintAxisVertical;
  stackView.spacing = 16;
  stackView.distribution = UIStackViewDistributionFillEqually;

  _includedTypes = [[ParameterInputTextField alloc] initWithTitle:@"Included Types"];
  _excludedTypes = [[ParameterInputTextField alloc] initWithTitle:@"Excluded Types"];
  _includedPrimaryTypes = [[ParameterInputTextField alloc] initWithTitle:@"Included Primary Types"];
  _excludedPrimaryTypes = [[ParameterInputTextField alloc] initWithTitle:@"Excluded Primary Types"];
  _maxResultCount = [[ParameterInputTextField alloc] initWithTitle:@"Max Result Count"];
  _regionCode = [[ParameterInputTextField alloc] initWithTitle:@"Region Code"];

  _rankPreference = [[UISegmentedControl alloc] initWithItems:@[ @"Popularity", @"Distance" ]];
  [_rankPreference setSelectedSegmentIndex:0];

  [stackView addArrangedSubview:_includedTypes];
  [stackView addArrangedSubview:_excludedTypes];
  [stackView addArrangedSubview:_includedPrimaryTypes];
  [stackView addArrangedSubview:_excludedPrimaryTypes];
  [stackView addArrangedSubview:_maxResultCount];
  [stackView addArrangedSubview:_rankPreference];
  [stackView addArrangedSubview:_regionCode];

  [_scrollViewStackView addArrangedSubview:stackView];
}

- (void)addSearchNearbyButton {
  _searchNearbyButton = [[UIButton alloc] init];
  [_searchNearbyButton setTitle:@"Search Nearby" forState:UIControlStateNormal];
  [_searchNearbyButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
  [_searchNearbyButton addTarget:self
                          action:@selector(sendSearchNearbyRequest)
                forControlEvents:UIControlEventTouchUpInside];

  [_scrollViewStackView addArrangedSubview:_searchNearbyButton];
}

- (void)sendSearchNearbyRequest {
  if ([self checkTextFieldIsValid:_latitudeField] && [self checkTextFieldIsValid:_longitudeField] &&
      [self checkTextFieldIsValid:_radiusField]) {
    id<GMSPlaceLocationRestriction> circularLocation =
        GMSPlaceCircularLocationOption(CLLocationCoordinate2DMake(_latitudeField.text.doubleValue,
                                                                  _longitudeField.text.doubleValue),
                                       _radiusField.text.doubleValue);
    GMSPlaceSearchNearbyRequest *request = [[GMSPlaceSearchNearbyRequest alloc]
        initWithLocationRestriction:circularLocation
                    placeProperties:@[ GMSPlacePropertyName, GMSPlacePropertyCoordinate ]];
    request.includedTypes = SplitStringToArray(_includedTypes.textField.text);
    request.excludedTypes = SplitStringToArray(_excludedTypes.textField.text);
    request.includedPrimaryTypes = SplitStringToArray(_includedPrimaryTypes.textField.text);
    request.excludedPrimaryTypes = SplitStringToArray(_excludedPrimaryTypes.textField.text);
    request.maxResultCount = _maxResultCount.textField.text.integerValue;
    request.rankPreference = [self getRankPreference];
    request.regionCode = _regionCode.textField.text;

    __weak __typeof__(self) weakSelf = self;
    [[GMSPlacesClient sharedClient]
        searchNearbyWithRequest:request
                       callback:^(NSArray<GMSPlace *> *_Nullable places, NSError *_Nullable error) {
                         if (error) {
                           [weakSelf showErrorWithMessage:error.localizedDescription];
                         } else {
                           _placeResults = places;
                           [_tableView reloadData];
                           _tableViewHeightConstraint.constant = _tableView.contentSize.height + 32;
                         }
                       }];
  }
}

- (GMSPlaceSearchNearbyRankPreference)getRankPreference {
  switch (_rankPreference.selectedSegmentIndex) {
    case 0:
    default:
      return GMSPlaceSearchNearbyRankPreferencePopularity;
    case 1:
      return GMSPlaceSearchNearbyRankPreferenceDistance;
  }
}

- (BOOL)checkTextFieldIsValid:(UITextField *)textField {
  if (!textField) {
    return NO;
  }

  if (IsValidNumber(textField.text)) {
    return YES;
  } else {
    [self showErrorWithMessage:@"One or more of the text fields are invalid"];
  }
  return NO;
}

- (void)setUpTableView {
  _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
  _tableView.translatesAutoresizingMaskIntoConstraints = false;
  _tableView.scrollEnabled = NO;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableViewHeightConstraint = [_tableView.heightAnchor constraintEqualToConstant:0];
  [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];

  [_scrollView addSubview:_tableView];

  [NSLayoutConstraint activateConstraints:@[
    [_tableView.topAnchor constraintEqualToAnchor:_scrollViewStackView.bottomAnchor],
    [_tableView.leadingAnchor constraintEqualToAnchor:_scrollViewStackView.leadingAnchor],
    [_tableView.trailingAnchor constraintEqualToAnchor:_scrollViewStackView.trailingAnchor],
    [_tableView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor],
    _tableViewHeightConstraint
  ]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _placeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                          forIndexPath:indexPath];
  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                reuseIdentifier:kCellIdentifier];
  GMSPlace *place = _placeResults[indexPath.row];
  cell.textLabel.text = place.name;
  cell.detailTextLabel.text =
      [NSString stringWithFormat:@"Coordinates: %f,%f", place.coordinate.latitude,
                                 place.coordinate.longitude];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

- (UIMenu *)setupPlacesMenu {
  UIActionHandler actionHandler = ^(UIAction *action) {
    NSString *actionTitle = action.title;
    if ([actionTitle isEqualToString:kGoogleMTV]) {
      _latitudeField.text = kGoogleMTVLatitude;
      _longitudeField.text = kGoogleMTVLongitude;
    } else if ([actionTitle isEqualToString:kGoogleSunnyvale]) {
      _latitudeField.text = kGoogleSunnyvaleLatitude;
      _longitudeField.text = kGoogleSunnyvaleLongitude;
    } else if ([actionTitle isEqualToString:kGoogleSanFrancisco]) {
      _latitudeField.text = kGoogleSanFranciscoLatitude;
      _longitudeField.text = kGoogleSanFranciscoLongitude;
    }
  };

  NSArray<UIAction *> *menuElements = @[
    [UIAction actionWithTitle:kGoogleMTV image:nil identifier:nil handler:actionHandler],
    [UIAction actionWithTitle:kGoogleSunnyvale image:nil identifier:nil handler:actionHandler],
    [UIAction actionWithTitle:kGoogleSanFrancisco image:nil identifier:nil handler:actionHandler]
  ];
  UIMenu *menu = [UIMenu menuWithTitle:@"Places" children:menuElements];
  return menu;
}

- (void)showErrorWithMessage:(NSString *)errorMessage {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@"Error"
                                          message:errorMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
