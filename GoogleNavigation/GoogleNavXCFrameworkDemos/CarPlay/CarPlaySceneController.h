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

NS_ASSUME_NONNULL_BEGIN

@class CPTemplate;
@class CPWindow;

/**
 * This is the protocol defining the creation and interface to CarPlay scene controllers.
 *
 * CarPlay scene controllers are allocated and freed by the scene delegate.
 */
@protocol CarPlaySceneController

/** A convenience constructor for creating a scene controller. */
+ (NSObject<CarPlaySceneController> *)sceneControllerWithWindow:(CPWindow *)window;

/**
 * Scene controllers should create their root template and make it available
 * in this property. The scene delegate will install this template as root
 * template after the controller is initialized.
 */
@property(nonatomic, nonnull, readonly) CPTemplate *carPlayTemplate;

@end

NS_ASSUME_NONNULL_END
