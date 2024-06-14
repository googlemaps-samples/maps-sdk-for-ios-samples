/*
 * Copyright 2018 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/Samples/DirectionsListViewController.h"

#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif

@implementation DirectionsListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  if (_directionsListController) {
    [self addSubviewFromDirectionsListController:_directionsListController];
  }
  [_directionsListController reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_directionsListController reloadData];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  __weak DirectionsListViewController *weakSelf = self;
  void (^animationBlock)(id<UIViewControllerTransitionCoordinatorContext> context) =
      ^void(id<UIViewControllerTransitionCoordinatorContext> context) {
        DirectionsListViewController *strongSelf = weakSelf;
        if (!strongSelf) {
          return;
        }
        [strongSelf->_directionsListController invalidateLayout];
      };
  [coordinator animateAlongsideTransition:animationBlock completion:nil];
}

- (void)setDirectionsListController:
    (GMSNavigationDirectionsListController *)directionsListController {
  [_directionsListController.directionsListView removeFromSuperview];
  if (self.isViewLoaded && directionsListController) {
    [self addSubviewFromDirectionsListController:directionsListController];
  }
  _directionsListController = directionsListController;
}

- (void)addSubviewFromDirectionsListController:
    (GMSNavigationDirectionsListController *)directionsListController {
  UIView *directionsListView = _directionsListController.directionsListView;
  directionsListView.frame = self.view.bounds;
  [self.view addSubview:directionsListView];
  directionsListView.translatesAutoresizingMaskIntoConstraints = NO;
  [directionsListView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
  [directionsListView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
  [directionsListView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
  [directionsListView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

@end
