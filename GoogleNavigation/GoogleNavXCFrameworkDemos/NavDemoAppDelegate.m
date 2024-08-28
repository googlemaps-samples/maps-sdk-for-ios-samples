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

#import "GoogleNavXCFrameworkDemos/NavDemoAppDelegate.h"
#import "GoogleNavXCFrameworkDemos/NavDemoSceneDelegate.h"

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif
#import "GoogleNavXCFrameworkDemos/SDKDemoAPIKey.h"

@implementation NavDemoAppDelegate {
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"Build version: %s", __VERSION__);

  if (kAPIKey.length == 0) {
    // Blow up if APIKey has not yet been set.
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *format = @"Configure API key inside SDKDemoAPIKey.h for your bundle `%@`.";
    @throw [NSException exceptionWithName:@"NavSDKDemoAppDelegate"
                                   reason:[NSString stringWithFormat:format, bundleId]
                                 userInfo:nil];
  }

  [GMSServices provideAPIKey:kAPIKey];

  return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
    configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                                   options:(UISceneConnectionOptions *)options {
  UISceneConfiguration *configuration = [[UISceneConfiguration alloc] init];
  configuration.delegateClass = [NavDemoSceneDelegate class];
  return configuration;
}

@end
