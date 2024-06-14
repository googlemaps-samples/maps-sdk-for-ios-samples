/*
 * Copyright 2017 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/NavDemoMasterViewController.h"

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif
#import "GoogleNavXCFrameworkDemos/DemoData.h"

// The cell reuse identifier.
static NSString *const kCellIdentifier = @"DemoCellIdentifier";

static NSString *const kCompanyName = @"Example Company";

@interface NavDemoMasterViewController () <CLLocationManagerDelegate>

@end

@implementation NavDemoMasterViewController {
  UIBarButtonItem *_samplesButton;
  __weak UIViewController *_controller;
  CLLocationManager *_locationManager;
  DemoData *_demoData;
}

- (instancetype)initWithDemoData:(DemoData *)demoData {
  if ((self = [self init])) {
    _demoData = demoData;
    NSString *title = NSLocalizedString(@"Nav SDK Demos",
                                        @"The name of the app to display in the navigation bar.");
    self.title =
        [NSString stringWithFormat:@"%@: %@", title, [GMSNavigationServices navSDKVersion]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;

  UIBarButtonItem *backButton =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];
  [self.navigationItem setBackBarButtonItem:backButton];

  self.tableView.autoresizingMask =
      UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)loadDemoWithTermsAndAuthorizationsRequest:(Demo *)demo {
  __weak NavDemoMasterViewController *weakSelf = self;
  [GMSNavigationServices
      showTermsAndConditionsDialogIfNeededWithCompanyName:kCompanyName
                                                 callback:^(BOOL termsAccepted) {
                                                   [weakSelf handleAuthorizationsAndLoadDemo:demo];
                                                 }];
}

- (void)handleAuthorizationsAndLoadDemo:(Demo *)demo {
  // First check the existing location authorization status, to ensure that an error is printed if
  // the location authorization has already been rejected. In this case, the dialog won't be
  // displayed and the authorization status will not change.
  CLAuthorizationStatus status = kCLAuthorizationStatusNotDetermined;
  status = _locationManager.authorizationStatus;
  [self logIfLocationStatusNotAuthorized:status];

  // The outcome of the location authorization dialog if it is shown is handled by the
  // locationManager:didChangeAuthorizationStatus: delegate method.
  [_locationManager requestAlwaysAuthorization];

  // Request authorization for alert notifications.
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  UNAuthorizationOptions options = UNAuthorizationOptionAlert;
  [center requestAuthorizationWithOptions:options
                        completionHandler:^(BOOL granted, NSError *_Nullable error) {
                          if (granted) {
                            NSLog(@"iOS Notification Permission: newly Granted");
                          } else {
                            NSLog(@"iOS Notification Permission: Failed or Denied");
                          }
                        }];

  // Load the demo even if the terms are not accepted, or location authorization is not granted so
  // we can test what happens.
  [self loadDemo:demo];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _demoData.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _demoData.sections[section].demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // Dequeue a table view cell to use.
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                          forIndexPath:indexPath];

  // Grab the demo object.
  Demo *demo = _demoData.sections[indexPath.section].demos[indexPath.row];

  // Configure the demo title on the cell.
  cell.textLabel.text = demo.title;

  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return _demoData.sections[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // The user has chosen a sample; load it and clear the selection!
  Demo *demo = _demoData.sections[indexPath.section].demos[indexPath.row];
  [self loadDemoWithTermsAndAuthorizationsRequest:demo];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  [self logIfLocationStatusNotAuthorized:status];
}

#pragma mark - Private methods

- (void)loadDemo:(Demo *)demo {
  UIViewController *controller = nil;
  if (demo.viewControllerCreationBlock) {
    controller = demo.viewControllerCreationBlock();
  } else {
    controller = [[demo.viewControllerClass alloc] init];
  }
  _controller = controller;

  if (controller != nil) {
    controller.title =
        [NSString stringWithFormat:@"%@: %@", demo.title, [GMSNavigationServices navSDKVersion]];

    [self.navigationController pushViewController:controller animated:YES];

    [self updateSamplesButton];
  }
}

// This method is invoked when the left 'back' button in the split view
// controller on iPad should be updated (either made visible or hidden).
// It assumes that the left bar button item may be safely modified to contain
// the samples button.
- (void)updateSamplesButton {
  _controller.navigationItem.leftBarButtonItem = _samplesButton;
}

/**
 * Prints an error message if the given authorization status is kCLAuthorizationStatusDenied or
 * kCLAuthorizationStatusRestricted because NavDemo won't work properly in this case.
 */
- (void)logIfLocationStatusNotAuthorized:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
    NSString *statusText;
    if (status == kCLAuthorizationStatusDenied) {
      statusText = @"kCLAuthorizationStatusDenied";
    } else {
      statusText = @"kCLAuthorizationStatusRestricted";
    }
    NSLog(@"NavDemo error: Location authorization failed to be granted or was revoked with status: "
          @"%@.",
          statusText);
  }
}

@end
