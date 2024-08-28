/*
 * Copyright 2022 Google LLC. All rights reserved.
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

#import "GoogleNavXCFrameworkDemos/NavDemoSceneDelegate.h"

#import <CarPlay/CarPlay.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayApplicationSceneInformationController.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayApplicationSceneMapController.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlayConnectionManager.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySceneController.h"
#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySharedState.h"
#import "GoogleNavXCFrameworkDemos/DemoData.h"
#import "GoogleNavXCFrameworkDemos/NavDemoMasterViewController.h"

@interface NavDemoSceneDelegate () <CarPlaySharedStateListener, CPInterfaceControllerDelegate>
@end

@implementation NavDemoSceneDelegate {
  NavDemoMasterViewController *_master;
  DemoData *_demoData;

  CPInterfaceController *_carPlayInterfaceController;
  // The window for the CarPlay application scene, if it is connected.
  CPWindow *_carPlayApplicationSceneWindow;
  // The controller for the CarPlay application scene, if it is connected.
  NSObject<CarPlaySceneController> *_carPlayApplicationSceneController;
  // The map controller for the CarPlay application scene, if it is active.
  NSObject<CarPlaySceneController> *_carPlayApplicationSceneMapController;
}

- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
  if ([scene isKindOfClass:[UIWindowScene class]]) {

    // Log the required open source licenses!  Yes, just NSLog-ing them is not
    // enough but is good for a demo.
    NSLog(@"Open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);

    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    _demoData = [[DemoData alloc] init];
    _master = [[NavDemoMasterViewController alloc] initWithDemoData:_demoData];
    _master.sceneDelegate = self;

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:_master];

    self.window.rootViewController = self.navigationController;

    [self.navigationController.navigationBar setTranslucent:NO];
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    [self.navigationController.navigationBar setStandardAppearance:appearance];
    [self.navigationController.navigationBar setScrollEdgeAppearance:appearance];

    [self.window makeKeyAndVisible];
  }
}

- (void)setSample:(UIViewController *)sample {
  NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad,
           @"Expected device to be iPad inside setSample:");

  // Finds the UINavigationController in the right side of the sample, and
  // replace its displayed controller with the new sample.
  UINavigationController *nav = self.splitViewController.viewControllers[1];
  [nav setViewControllers:[NSArray arrayWithObject:sample] animated:NO];
}

- (UIViewController *)sample {
  NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad,
           @"Expected device to be iPad inside sample");

  // The current sample is the top-most VC in the right-hand pane of the
  // splitViewController.
  UINavigationController *nav = self.splitViewController.viewControllers[1];
  return nav.viewControllers.firstObject;
}

- (void)templateApplicationScene:(CPTemplateApplicationScene *)templateApplicationScene
    didConnectInterfaceController:(CPInterfaceController *)interfaceController
                         toWindow:(CPWindow *)window {
  _carPlayInterfaceController = interfaceController;
  _carPlayInterfaceController.delegate = self;
  _carPlayApplicationSceneWindow = window;
  _carPlayApplicationSceneController = [CarPlayApplicationSceneInformationController
      sceneControllerWithWindow:_carPlayApplicationSceneWindow];
  [_carPlayInterfaceController setRootTemplate:_carPlayApplicationSceneController.carPlayTemplate
                                      animated:NO];
  [self setApplicationSceneControllerFromState:CarPlaySharedState.sharedState];
  CarPlayConnectionManager.sharedManager.applicationSceneActive = YES;
  [CarPlaySharedState.sharedState addListener:self];
}

- (void)templateApplicationScene:(CPTemplateApplicationScene *)templateApplicationScene
    didDisconnectInterfaceController:(CPInterfaceController *)interfaceController
                          fromWindow:(CPWindow *)window {
  [CarPlaySharedState.sharedState removeListener:self];
  _carPlayApplicationSceneWindow.rootViewController = nil;
  _carPlayApplicationSceneWindow = nil;
  _carPlayApplicationSceneController = nil;
  CarPlayConnectionManager.sharedManager.applicationSceneActive = NO;
}

#pragma mark - CarPlaySharedStateListener

- (void)enabledDidChangeInState:(CarPlaySharedState *)state {
  [self setApplicationSceneControllerFromState:state];
}

#pragma mark - CPInterfaceControllerDelegate

- (void)templateWillDisappear:(CPTemplate *)aTemplate animated:(BOOL)animated {
  if (aTemplate == _carPlayApplicationSceneMapController.carPlayTemplate) {
    [CarPlayConnectionManager.sharedManager back];
    [self mapControllerDidPop];
  }
}

#pragma mark - Private methods

- (void)setApplicationSceneControllerFromState:(CarPlaySharedState *)state {
  if (state.enabled && !_carPlayApplicationSceneMapController) {
    // Set map controller
    _carPlayApplicationSceneMapController = [CarPlayApplicationSceneMapController
        sceneControllerWithWindow:_carPlayApplicationSceneWindow];
    [_carPlayInterfaceController pushTemplate:_carPlayApplicationSceneMapController.carPlayTemplate
                                     animated:YES];
  } else if (_carPlayApplicationSceneMapController && !state.enabled) {
    __weak __typeof__(self) weakSelf = self;
    [_carPlayInterfaceController popTemplateAnimated:YES
                                          completion:^void(BOOL success, NSError *_Nullable error) {
                                            [weakSelf mapControllerDidPop];
                                          }];
  }
}

- (void)mapControllerDidPop {
  _carPlayApplicationSceneMapController = nil;
}

@end
