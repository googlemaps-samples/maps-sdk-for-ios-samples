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

#import "GooglePlacesXCFrameworkDemos/Samples/TextSearchViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif
#import "GooglePlacesXCFrameworkDemos/Support/BaseDemoViewController.h"

static NSString *const kCellIdentifier = @"TextSearchCellIdentifier";

@interface TextSearchViewController () <UITextFieldDelegate,
                                        UITableViewDelegate,
                                        UITableViewDataSource>

@end

@implementation TextSearchViewController {
  UITextField *_textQueryField;
  UITableView *_tableView;
  NSArray<GMSPlace *> *_placeResults;
}

+ (NSString *)demoTitle {
  return @"Text Search";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor systemBackgroundColor];
  [self setUpTextField];
  [self setUpTableView];

  _placeResults = [NSArray array];
}

- (void)setUpTextField {
  _textQueryField = [[UITextField alloc] init];
  _textQueryField.delegate = self;
  _textQueryField.borderStyle = UITextBorderStyleRoundedRect;
  _textQueryField.textColor = [UIColor labelColor];
  _textQueryField.placeholder = @"Enter Text Search Query";
  _textQueryField.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _textQueryField.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:_textQueryField];

  [NSLayoutConstraint activateConstraints:@[
    [_textQueryField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
    [_textQueryField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [_textQueryField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [_textQueryField.heightAnchor constraintEqualToConstant:50]
  ]];
}

- (void)setUpTableView {
  _tableView = [[UITableView alloc] init];
  _tableView.translatesAutoresizingMaskIntoConstraints = false;
  _tableView.delegate = self;
  _tableView.dataSource = self;

  [self.view addSubview:_tableView];

  [NSLayoutConstraint activateConstraints:@[
    [_tableView.topAnchor constraintEqualToAnchor:_textQueryField.bottomAnchor],
    [_tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
    [_tableView.trailingAnchor
        constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
    [_tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
  ]];

  [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSString *text = textField.text;
  if (text.length == 0) {
    return false;
  }

  _placeResults = [NSArray array];
  [_tableView reloadData];
  _tableView.hidden = NO;

  GMSPlaceSearchByTextRequest *request =
      [[GMSPlaceSearchByTextRequest alloc] initWithTextQuery:text
                                             placeProperties:self.placeProperties];

  // Coordinates of Googleplex, 1 kilometer radius
  request.locationBias =
      GMSPlaceCircularLocationOption(CLLocationCoordinate2DMake(37.4220604, -122.087809), 1000.0);
  GMSPlaceSearchByTextResultCallback callback =
      ^(NSArray<GMSPlace *> *placeResults, NSError *error) {
        if (error != nil) {
          NSLog(@"Error: %@", error.localizedDescription);
          [super autocompleteDidFail:error];
          return;
        }

        _placeResults = placeResults;
        [_tableView reloadData];
      };

  [[GMSPlacesClient sharedClient] searchByTextWithRequest:request callback:callback];
  return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _placeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                          forIndexPath:indexPath];
  GMSPlace *place = _placeResults[indexPath.row];
  cell.textLabel.text = place.name;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GMSPlace *place = _placeResults[indexPath.row];
  tableView.hidden = YES;
  [super autocompleteDidSelectPlace:place];
}

@end
