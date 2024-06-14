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

#import <Foundation/Foundation.h>

#import <CarPlay/CarPlay.h>

#import "GoogleNavXCFrameworkDemos/CarPlay/CarPlaySceneController.h"

/**
 * This is a CarPlay application scene controller which shows generic information.
 * It should be shown whenever the currently running sample does not support CarPlay.
 */
@interface CarPlayApplicationSceneInformationController : NSObject <CarPlaySceneController>

/** Initialization is via the @c CarPlaySceneController protocol convenience constructor. */
- (instancetype)init NS_UNAVAILABLE;

@end
