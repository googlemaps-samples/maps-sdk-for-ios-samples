/*
 * Copyright 2016 Google LLC. All rights reserved.
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

#import "GooglePlacesXCFrameworkDemos/DemoData.h"

#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteBaseViewController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteModalViewController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompletePushViewController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteWithCustomColors.h"
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteWithSearchViewController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteWithTextFieldController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/FindPlaceLikelihoodListViewController.h"
#import "GooglePlacesXCFrameworkDemos/Support/BaseDemoViewController.h"

#import "GooglePlacesXCFrameworkDemos/Samples/SearchNearbyViewController.h"
#import "GooglePlacesXCFrameworkDemos/Samples/TextSearchViewController.h"
@implementation Demo {
  Class _viewControllerClass;
}

- (instancetype)initWithViewControllerClass:(Class)viewControllerClass {
  if ((self = [self init])) {
    _title = [viewControllerClass demoTitle];
    _viewControllerClass = viewControllerClass;
  }
  return self;
}

- (UIViewController *)createViewControllerWithAutocompleteFilter:
                          (GMSAutocompleteFilter *)autocompleteFilter
                                                     placeFields:(GMSPlaceField)placeFields {
  // Construct the demo view controller.
  UIViewController *demoViewController = [[_viewControllerClass alloc] init];

  // Pass the place fields to the view controller for these classes.
  if ([demoViewController isKindOfClass:[AutocompleteBaseViewController class]]) {
    AutocompleteBaseViewController *controller =
        (AutocompleteBaseViewController *)demoViewController;
    controller.autocompleteFilter = autocompleteFilter;
    controller.placeFields = placeFields;
  }
  return demoViewController;
}

- (UIViewController *)
    createViewControllerWithAutocompleteFilter:(GMSAutocompleteFilter *)autocompleteFilter
                               placeProperties:(NSArray<GMSPlaceProperty> *)placeProperties {
  // Construct the demo view controller.
  UIViewController *demoViewController = [[_viewControllerClass alloc] init];

  // Pass the place properties to the view controller for these classes.
  if ([demoViewController isKindOfClass:[AutocompleteBaseViewController class]]) {
    AutocompleteBaseViewController *controller =
        (AutocompleteBaseViewController *)demoViewController;
    controller.autocompleteFilter = autocompleteFilter;
    controller.placeProperties = placeProperties;
  }

  return demoViewController;
}
@end

@implementation DemoSection

- (instancetype)initWithTitle:(NSString *)title demos:(NSArray<Demo *> *)demos {
  if ((self = [self init])) {
    _title = [title copy];
    _demos = [demos copy];
  }
  return self;
}

@end

@implementation DemoData

- (instancetype)init {
  if ((self = [super init])) {
    NSArray<Demo *> *autocompleteDemos = @[
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithCustomColors class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteModalViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompletePushViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithSearchViewController class]],
      [[Demo alloc] initWithViewControllerClass:[AutocompleteWithTextFieldController class]],
    ];

    NSArray<Demo *> *findPlaceLikelihoodDemos = @[ [[Demo alloc]
        initWithViewControllerClass:[FindPlaceLikelihoodListViewController class]] ];
    NSArray<Demo *> *textSearchDemos =
        @[ [[Demo alloc] initWithViewControllerClass:[TextSearchViewController class]] ];
    NSArray<Demo *> *nearbySearchDemos =
        @[ [[Demo alloc] initWithViewControllerClass:[SearchNearbyViewController class]] ];
    _sections = @[
      [[DemoSection alloc]
          initWithTitle:NSLocalizedString(@"Demo.Section.Title.Autocomplete",
                                          @"Title of the autocomplete demo section")
                  demos:autocompleteDemos],
      [[DemoSection alloc]
          initWithTitle:NSLocalizedString(@"Demo.Section.Title.FindPlaceLikelihood",
                                          @"Title of the findPlaceLikelihood demo section")
                  demos:findPlaceLikelihoodDemos],
      [[DemoSection alloc] initWithTitle:NSLocalizedString(@"Demo.Section.Title.TextSearch",
                                                           @"Title of the textSearch demo section")
                                   demos:textSearchDemos],
      [[DemoSection alloc]
          initWithTitle:NSLocalizedString(@"Demo.Section.Title.SearchNearby",
                                          @"Title of the searchNearby demo section")
                  demos:nearbySearchDemos],
    ];
  }
  return self;
}

- (Demo *)firstDemo {
  return _sections[0].demos[0];
}

@end
