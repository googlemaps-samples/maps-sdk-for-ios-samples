/*
 * Copyright 2017 Google Inc. All rights reserved.
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

#import "GooglePlacesDemos/Samples/PlacePickerViewController.h"

#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GooglePlaces/GooglePlaces.h>

@interface PlacePickerViewController () <GMSPlacePickerViewControllerDelegate>
@end

@implementation PlacePickerViewController {
  GMSPlacePickerViewController *_placePickerViewController;
}

+ (NSString *)demoTitle {
  return NSLocalizedString(@"Demo.Title.PlacePicker.ViewController",
                           @"Title of the Place Picker demo for displaying the picker in a "
                           @"popover, navigation controller, or modally.");
}

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
  _placePickerViewController = [[GMSPlacePickerViewController alloc] initWithConfig:config];
  _placePickerViewController.delegate = self;

  self.view.backgroundColor = [UIColor whiteColor];

  NSString *titlePopover =
      NSLocalizedString(@"Demo.Content.PlacePicker.ViewController.Popover",
                        @"Button title for the 'Popover' view of the place picker.");
  NSString *titleNavigation =
      NSLocalizedString(@"Demo.Content.PlacePicker.ViewController.Navigation",
                        @"Button title for the 'Navigation' view of the place picker.");
  NSString *titleModal =
      NSLocalizedString(@"Demo.Content.PlacePicker.ViewController.Modal",
                        @"Button title for the 'Modal' view of the place picker.");

  UIButton *popoverButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [popoverButton setTitle:titlePopover forState:UIControlStateNormal];
  [popoverButton addTarget:self
                    action:@selector(showPlacePickerInPopover:)
          forControlEvents:UIControlEventTouchUpInside];
  popoverButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:popoverButton];
  [NSLayoutConstraint constraintWithItem:popoverButton
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.topLayoutGuide
                               attribute:NSLayoutAttributeBottom
                              multiplier:1
                                constant:8]
      .active = YES;
  [NSLayoutConstraint constraintWithItem:popoverButton
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                               attribute:NSLayoutAttributeCenterX
                              multiplier:1
                                constant:8]
      .active = YES;

  UIButton *navigationButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [navigationButton setTitle:titleNavigation forState:UIControlStateNormal];
  [navigationButton addTarget:self
                       action:@selector(showPlacePickerOnNavigationStack)
             forControlEvents:UIControlEventTouchUpInside];
  navigationButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:navigationButton];
  [NSLayoutConstraint constraintWithItem:navigationButton
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:popoverButton
                               attribute:NSLayoutAttributeBottom
                              multiplier:1
                                constant:8]
      .active = YES;
  [NSLayoutConstraint constraintWithItem:navigationButton
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                               attribute:NSLayoutAttributeCenterX
                              multiplier:1
                                constant:8]
      .active = YES;

  UIButton *modalButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [modalButton setTitle:titleModal forState:UIControlStateNormal];
  [modalButton addTarget:self
                  action:@selector(showPlacePickerModally)
        forControlEvents:UIControlEventTouchUpInside];
  modalButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:modalButton];
  [NSLayoutConstraint constraintWithItem:modalButton
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:navigationButton
                               attribute:NSLayoutAttributeBottom
                              multiplier:1
                                constant:8]
      .active = YES;
  [NSLayoutConstraint constraintWithItem:modalButton
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                               attribute:NSLayoutAttributeCenterX
                              multiplier:1
                                constant:8]
      .active = YES;
}

- (void)showPlacePickerInPopover:(UIButton *)button {
  _placePickerViewController.modalPresentationStyle = UIModalPresentationPopover;

  [self presentViewController:_placePickerViewController animated:YES completion:nil];

  UIPopoverPresentationController *presentationController =
      [_placePickerViewController popoverPresentationController];
  presentationController.sourceView = button;
  presentationController.sourceRect = button.bounds;
}

- (void)showPlacePickerOnNavigationStack {
  [self.navigationController pushViewController:_placePickerViewController animated:YES];
}

- (void)showPlacePickerModally {
  // If the popover view was selected just before this view, the modal view crashes because
  // the view controller is set to present in a popover style, but it's source view is nil.
  // Need to set the presentation style to something different to avoid this.
  _placePickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:_placePickerViewController animated:YES completion:nil];
}

#pragma mark - GMSPlacePickerViewControllerDelegate

- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
  // View controller needs to be popped of stack if it was on a navigation stack.
  if (viewController.navigationController == self.navigationController) {
    [self.navigationController popToViewController:self animated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
