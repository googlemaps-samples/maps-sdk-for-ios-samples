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

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/** Demo that exposes the @c GMSPlaceSearchNearbyRequest API. */
@interface SearchNearbyViewController : UIViewController
@end

/**
 * View containing a title and a UITextField to input parameters for the @c
 * GMSPlaceSearchNearbyRequest API.
 */
@interface ParameterInputTextField : UIView <UITextFieldDelegate>

/** The title label of the view. */
@property(nonatomic, strong) UILabel *titleLabel;

/** The UITextField to input parameter values. */
@property(nonatomic, strong) UITextField *textField;

/** Initializes the view with the title for indication of which parameter this view is for. */
- (instancetype)initWithTitle:(nonnull NSString *)title NS_DESIGNATED_INITIALIZER;

/** Use the above designated initializer instead. */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
NS_ASSUME_NONNULL_END
