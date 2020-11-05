// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "SceneDelegate.h"
#import "MainViewController.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
  UIWindowScene *windowScene = (UIWindowScene *)scene;
  self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
  MainViewController *main = [[MainViewController alloc] init];

  UINavigationController *mainNavigationController =
      [[UINavigationController alloc] initWithRootViewController:main];

  UIViewController *empty = [[UIViewController alloc] init];
  UINavigationController *detailNavigationController =
      [[UINavigationController alloc] initWithRootViewController:empty];

  self.splitViewController = [[UISplitViewController alloc] init];
  self.splitViewController.delegate = main;
  self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
  self.splitViewController.viewControllers =
      @[ mainNavigationController, detailNavigationController ];

  empty.navigationItem.leftItemsSupplementBackButton = YES;
  empty.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;

  self.window.rootViewController = self.splitViewController;

  [self.window makeKeyAndVisible];
}

@end
