/*
 * Copyright 2023 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayConnectionManager.h"

#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif

@implementation CarPlayConnectionManager

+ (CarPlayConnectionManager *)sharedManager {
  static CarPlayConnectionManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[CarPlayConnectionManager alloc] init];
  });
  return sharedManager;
}

- (void)setApplicationSceneActive:(BOOL)applicationSceneActive {
  if (applicationSceneActive != _applicationSceneActive) {
    _applicationSceneActive = applicationSceneActive;
    if ([_delegate respondsToSelector:@selector(connectionManager:didChangeApplicationActive:)]) {
      [_delegate connectionManager:self didChangeApplicationActive:applicationSceneActive];
    }
  }
}

- (void)back {
  [_delegate didRequestBackWithConnectionManager:self];
}

- (void)showTOS {
  [GMSNavigationServices resetTermsAndConditionsAccepted];
  [GMSNavigationServices showTermsAndConditionsDialogIfNeededWithCompanyName:@"Nav Demo Company"
                                                                    callback:^(BOOL termsAccepted){
                                                                    }];
}

- (void)goToDestination:(id<CarPlaySharedDestination>)destination {
  if ([_delegate respondsToSelector:@selector(connectionManager:didRequestGoToDestination:)]) {
    [_delegate connectionManager:self didRequestGoToDestination:destination];
  }
}

@end
