/*
 * Copyright 2021 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/Samples/BaseViewController.h"

#import <Foundation/Foundation.h>

@implementation BaseViewController {
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.systemBackgroundColor;
  _mainStackView = [[UIStackView alloc] init];
  _mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
  _mainStackView.axis = UILayoutConstraintAxisVertical;
  [self.view addSubview:_mainStackView];
  [_mainStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
  [_mainStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
  [_mainStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
  [_mainStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

  // Sets container view for the controls. Doesn't add controls to the container here, each sample
  // has its own view to add to.
  _controls = [[UIStackView alloc] init];
  _controls.translatesAutoresizingMaskIntoConstraints = NO;
  _controls.spacing = 10;
  _controls.axis = UILayoutConstraintAxisVertical;
  _controls.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15);
  _controls.layoutMarginsRelativeArrangement = YES;
}

@end
