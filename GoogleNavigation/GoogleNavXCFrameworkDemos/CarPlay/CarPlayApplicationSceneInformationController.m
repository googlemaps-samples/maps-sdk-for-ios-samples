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

#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayApplicationSceneInformationController.h"

#import <CarPlay/CarPlay.h>

#if __has_feature(modules)
@import GoogleNavigation;
#else
#import <GoogleNavigation/GoogleNavigation.h>
#endif
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayConnectionManager.h"

@interface CarPlayApplicationSceneInformationController ()

- (instancetype)initWithWindow:(CPWindow *)window NS_DESIGNATED_INITIALIZER;

@end

@implementation CarPlayApplicationSceneInformationController {
  CPInformationTemplate *_informationTemplate;
}

- (instancetype)initWithWindow:(CPWindow *)window {
  self = [super init];
  if (self) {
    NSString *NavSDKVersion = GMSNavigationServices.navSDKVersion;
    CPInformationItem *versionItem = [[CPInformationItem alloc] initWithTitle:@"Version"
                                                                       detail:NavSDKVersion];
    CPInformationItem *noMapExplanationItem =
        [[CPInformationItem alloc] initWithTitle:@"Status"
                                          detail:@"Either no sample is currently running, or the "
                                                 @"current sample does not support CarPlay."];
    __weak __typeof__(self) weakSelf = self;
    CPTextButton *showTOSButton =
        [[CPTextButton alloc] initWithTitle:@"Show TOS"
                                  textStyle:CPTextButtonStyleNormal
                                    handler:^(__kindof CPTextButton *_Nonnull button) {
                                      [weakSelf didTapShowTOSButton];
                                    }];
    _informationTemplate =
        [[CPInformationTemplate alloc] initWithTitle:@"NavSDK Demo Application"
                                              layout:CPInformationTemplateLayoutLeading
                                               items:@[ versionItem, noMapExplanationItem ]
                                             actions:@[
                                               showTOSButton,
                                             ]];
  }
  return self;
}

#pragma mark - CarPlaySceneController

+ (NSObject<CarPlaySceneController> *)sceneControllerWithWindow:(CPWindow *)window {
  return [[CarPlayApplicationSceneInformationController alloc] initWithWindow:window];
}

- (CPTemplate *)carPlayTemplate {
  return _informationTemplate;
}

#pragma mark - Private methods

- (void)didTapShowTOSButton {
  [CarPlayConnectionManager.sharedManager showTOS];
}

@end
