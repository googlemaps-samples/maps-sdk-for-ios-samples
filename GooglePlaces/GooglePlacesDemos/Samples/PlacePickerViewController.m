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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "GooglePlacesDemos/Samples/PlacePickerViewController.h"

#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GooglePlaces/GooglePlaces.h>

/** Height of buttons in this controller's UI */
static const CGFloat kButtonHeight = 44.0f;

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

  CGFloat nextControlY = 70.0f;
  UIButton *popoverButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [popoverButton setTitle:titlePopover forState:UIControlStateNormal];
  popoverButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  popoverButton.autoresizingMask =
      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [popoverButton addTarget:self
                    action:@selector(showPlacePickerInPopover:)
          forControlEvents:UIControlEventTouchUpInside];
  nextControlY += kButtonHeight;

  UIButton *navigationButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [navigationButton setTitle:titleNavigation forState:UIControlStateNormal];
  navigationButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  navigationButton.autoresizingMask =
      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [navigationButton addTarget:self
                       action:@selector(showPlacePickerOnNavigationStack)
             forControlEvents:UIControlEventTouchUpInside];
  nextControlY += kButtonHeight;

  UIButton *modalButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [modalButton setTitle:titleModal forState:UIControlStateNormal];
  modalButton.frame = CGRectMake(0, nextControlY, self.view.bounds.size.width, kButtonHeight);
  modalButton.autoresizingMask =
      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  [modalButton addTarget:self
                  action:@selector(showPlacePickerModally)
        forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:popoverButton];
  [self.view addSubview:navigationButton];
  [self.view addSubview:modalButton];
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
