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

#import "CloudBasedMapStylingViewController.h"
#import <GoogleMaps/GoogleMaps.h>


static NSString *const kMapIDRetro = @"13564581852493597319";
static NSString *const kMapIDDemo = @"11153850776783499500";

/** Demonstrate basic usage of the Cloud Styling feature. */
@implementation CloudBasedMapStylingViewController {
  GMSMapView *_mapView;
  NSMutableArray<NSString *> *_mapIDStrings;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _mapIDStrings = [[NSMutableArray alloc] init];
  [_mapIDStrings addObject:kMapIDRetro];
  [_mapIDStrings addObject:kMapIDDemo];

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = _mapView;

  UIBarButtonItem *styleButton = [[UIBarButtonItem alloc] initWithTitle:@"Style Map"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(changeMapID:)];
  self.navigationItem.rightBarButtonItem = styleButton;
}


/** Re-create the map view with the specified mapID. */
- (void)updateMapWithExistingMapIDString:(nonnull NSString *)mapIDString {
  GMSMapID *mapID = [GMSMapID mapIDWithIdentifier:mapIDString];
  _mapView = [GMSMapView mapWithFrame:CGRectZero mapID:mapID camera:_mapView.camera];
  self.view = _mapView;
}

/** Add the new map ID to the list of selectable IDs and update the map to use it. */
- (void)updateMapWithNewMapIDString:(NSString *)mapIDString {
  if (mapIDString.length > 0) {
    [_mapIDStrings addObject:mapIDString];
    [self updateMapWithExistingMapIDString:mapIDString];
  }
}

/** Ask the user for a new map ID to add to the list. */
- (void)showAddMapIDAlert {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:@"Add a new map ID"
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Map ID";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
  }];
  __weak __typeof__(self) weakSelf = self;
  [alertController
      addAction:[UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                         __typeof__(self) strongSelf = weakSelf;
                                         if (strongSelf) {
                                           NSString *mapIDString =
                                               alertController.textFields[0].text;
                                           [strongSelf updateMapWithNewMapIDString:mapIDString];
                                         }
                                       }]];
  [self presentViewController:alertController animated:YES completion:nil];
}

/** Return an action that sets the appearance of the map to the mapID. */
- (UIAlertAction *_Nonnull)alertActionForMapIDString:(nonnull NSString *)mapID {
  __weak __typeof__(self) weakSelf = self;
  return [UIAlertAction actionWithTitle:mapID
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *_Nonnull action) {
                                  __typeof__(self) strongSelf = weakSelf;
                                  if (strongSelf) {
                                    [strongSelf updateMapWithExistingMapIDString:mapID];
                                  }
                                }];
}

/** Return an action which prompts an alert to type in a new map ID. */
- (UIAlertAction *_Nonnull)alertActionToAddMapID {
  __weak __typeof__(self) weakSelf = self;
  return [UIAlertAction actionWithTitle:@"Add a new Map ID"
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *_Nonnull action) {
                                  __typeof__(self) strongSelf = weakSelf;
                                  if (strongSelf) {
                                    [strongSelf showAddMapIDAlert];
                                  }
                                }];
}


/** Bring up a selection list of existing Map IDs, and the option to add a new one. */
- (void)changeMapID:(UIBarButtonItem *)sender {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@"Select Map ID"
                                          message:@"Change the look of the map with a map ID"
                                   preferredStyle:UIAlertControllerStyleActionSheet];
  [alert addAction:[self alertActionToAddMapID]];

  // Lists the existing Map IDs for selection.
  for (NSString *mapIDString in _mapIDStrings) {
    [alert addAction:[self alertActionForMapIDString:mapIDString]];
  }

  [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
  alert.popoverPresentationController.barButtonItem = sender;
  [self presentViewController:alert animated:YES completion:nil];
}

@end
