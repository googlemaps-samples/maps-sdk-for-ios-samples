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

#import "GoogleNavXCFrameworkDemos/DemoData.h"

#import "GoogleNavXCFrameworkDemos/Samples/NavUIOptionsViewController.h"
#import "GoogleNavXCFrameworkDemos/Samples/NavigationSessionViewController.h"
#import "GoogleNavXCFrameworkDemos/Samples/RoutingOptionsViewController.h"
#import "GoogleNavXCFrameworkDemos/Samples/SideOfRoadViewController.h"
#import "GoogleNavXCFrameworkDemos/Samples/StopoverViewController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Demo

- (instancetype)initWithViewControllerClass:(Class)viewControllerClass title:(NSString *)title {
  self = [super init];
  if (self) {
    _title = [title copy];
    _viewControllerClass = viewControllerClass;
  }
  return self;
}

- (instancetype)initWithTitle:(NSString *)title
    viewControllerCreationBlock:(UIViewController *_Nonnull (^)(void))block {
  self = [super init];
  if (self) {
    _title = [title copy];
    _viewControllerCreationBlock = [block copy];
  }
  return self;
}

- (instancetype)init {
  return nil;
}

@end

@implementation DemoSection

- (instancetype)initWithTitle:(NSString *)title demos:(NSArray<Demo *> *)demos {
  self = [super init];
  if (self) {
    _title = [title copy];
    _demos = [demos copy];
  }
  return self;
}

- (instancetype)init {
  return nil;
}

@end

@implementation DemoData

- (instancetype)init {
  if ((self = [super init])) {
    NSArray<Demo *> *basicDemos = @[
      [[Demo alloc] initWithViewControllerClass:[SideOfRoadViewController class]
                                          title:@"SideOfRoad"],
      [[Demo alloc] initWithViewControllerClass:[StopoverViewController class] title:@"Stopover"],
      [[Demo alloc] initWithViewControllerClass:[NavUIOptionsViewController class]
                                          title:@"UI Options"],
      [[Demo alloc] initWithViewControllerClass:[RoutingOptionsViewController class]
                                          title:@"Routing Options"],
      [[Demo alloc] initWithViewControllerClass:[NavigationSessionViewController class]
                                          title:@"Navigation Session"],
    ];

    _sections = @[
      [[DemoSection alloc] initWithTitle:@"Basic demos" demos:basicDemos],
    ];
  }
  return self;
}

- (nullable Demo *)firstDemo {
  return _sections.firstObject.demos.firstObject;
}

@end

NS_ASSUME_NONNULL_END
