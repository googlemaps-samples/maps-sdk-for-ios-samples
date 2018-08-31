/*
 * Copyright 2016 Google Inc. All rights reserved.
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

#import "GooglePlacesDemos/Support/MainSplitViewControllerBehaviorManager.h"

@implementation MainSplitViewControllerBehaviorManager {
  BOOL _hasBeenCollapsedBefore;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
    collapseSecondaryViewController:(UIViewController *)secondaryViewController
          ontoPrimaryViewController:(UIViewController *)primaryViewController {
  // This override is probably not needed in your own app. This tells the |UISplitViewController| to
  // display the list of demos on first launch if there is not enough space to have two panes,
  // instead of just the first demo in the list. After first launch if the device transitions from
  // regular to compact it will instead show the demo which is currently open.
  if (_hasBeenCollapsedBefore) {
    return NO;
  } else {
    _hasBeenCollapsedBefore = YES;
    return YES;
  }
}

@end
