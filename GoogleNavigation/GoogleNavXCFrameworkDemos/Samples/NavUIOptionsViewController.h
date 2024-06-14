/*
 * Copyright 2017 Google LLC. All rights reserved.
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
#import "GoogleNavXCFrameworkDemos/Samples/BaseViewController.h"

/**
 * A demo that exercises camera following functionality. Also conforms to GMSNavigatorListener to
 * create custom behavior for specific navigation events.
 */
@interface NavUIOptionsViewController
    : BaseViewController <GMSMapViewDelegate, GMSNavigatorListener>

@end
