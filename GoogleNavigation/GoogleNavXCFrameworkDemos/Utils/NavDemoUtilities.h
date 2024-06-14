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

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif
#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/** Returns a button with the given title and target selector. */
UIButton *GMSNavigationCreateButton(id target, SEL selector, NSString *title);

/** Returns a segmented control with the given title and target selector. */
UISegmentedControl *GMSNavigationCreateSegmentedControl(id target, SEL selector,
                                                        NSArray<NSString *> *titles);

/** Presents an alert view controller given a title, message, and action title. */
void GMSNavigationPresentAlertController(UIViewController *presentingViewController,
                                         NSString *message, NSString *alertTitle,
                                         NSString *actionTitle);

/** Returns a UIStackView with a horizontal axis for placing controls side-by-side. */
UIStackView *GMSNavigationCreateHorizontalStackView();

/** Returns a label with text. */
UILabel *GMSNavigationCreateLabelWithText(NSString *text);

/**
 * A category to the UITextField class that adds a toolbar feature that allows users to exit the
 * text field via the done or cancel buttons. For example, this toolbar is used in the Routing
 * Options sample when users enter a target distance; after the desired distance is added, the user
 * can then click on cancel or done to hide the numberpad.
 */
@interface UITextField (Toolbar)

- (void)createDoneCancelToolBar;

- (void)doneButtonTapped;

- (void)cancelButtonTapped;

@end

NS_ASSUME_NONNULL_END
