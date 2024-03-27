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

#import "GoogleMapsXCFrameworkDemos/Common/GMSNotCapturingTouchesTableView.h"

@implementation GMSNotCapturingTouchesTableView

#pragma mark - Overrides

// This override causes the view to not intercept gestures, unless the gesture occurs on one of this
// view's subviews. The UITableView should not prevent the map from panning/zooming/tilting.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *view = [super hitTest:point withEvent:event];
  if (view == self) {
    // If no descendent of this view contains the specified point, return nil. nil is returned if
    // the point does not fit inside the view.
    return nil;
  } else {
    // If there is a descendent of this view that contains the specified point, return that view.
    return view;
  }
}

@end
