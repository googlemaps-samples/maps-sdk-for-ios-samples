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

#import "GoogleNavXCFrameworkDemos/Utils/NavDemoUtilities.h"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

UIButton *GMSNavigationCreateButton(id target, SEL selector, NSString *title) {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

  // Each button is dark gray.
  button.backgroundColor = UIColor.darkGrayColor;

  // Each button has corner radius 5.f.
  button.layer.cornerRadius = 5.f;
  return button;
}

UISegmentedControl *GMSNavigationCreateSegmentedControl(id target, SEL selector,
                                                        NSArray<NSString *> *titles) {
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
  [segmentedControl addTarget:target action:selector forControlEvents:UIControlEventValueChanged];
  for (NSUInteger i = 0; i < titles.count; i++) {
    [segmentedControl insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
  }
  segmentedControl.selectedSegmentIndex = 0;
  return segmentedControl;
}

void GMSNavigationPresentAlertController(UIViewController *presentingViewController,
                                         NSString *message, NSString *alertTitle,
                                         NSString *actionTitle) {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:alertTitle
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:actionTitle
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
  [alertController addAction:defaultAction];
  [presentingViewController presentViewController:alertController animated:YES completion:nil];
}

UIStackView *GMSNavigationCreateHorizontalStackView() {
  UIStackView *container = [[UIStackView alloc] init];
  container.spacing = 10;
  container.axis = UILayoutConstraintAxisHorizontal;
  container.distribution = UIStackViewDistributionFillEqually;
  return container;
}

UILabel *GMSNavigationCreateLabelWithText(NSString *text) {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
  label.numberOfLines = 0;
  label.text = text;
  label.font = [UIFont systemFontOfSize:14];
  label.textAlignment = NSTextAlignmentCenter;
  return label;
}

@implementation UITextField (Toolbar)

- (void)createDoneCancelToolBar {
  UIToolbar *toolbar = [[UIToolbar alloc] init];
  toolbar.barStyle = UIBarStyleDefault;
  [toolbar setItems:[NSMutableArray
                        arrayWithObjects:
                            [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancelButtonTapped)],
                            [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                     target:self
                                                     action:nil],
                            [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(doneButtonTapped)],
                            nil]];
  [toolbar sizeToFit];
  self.inputAccessoryView = toolbar;
}

- (void)doneButtonTapped {
  [self resignFirstResponder];
}

- (void)cancelButtonTapped {
  [self resignFirstResponder];
}

@end

NS_ASSUME_NONNULL_END
