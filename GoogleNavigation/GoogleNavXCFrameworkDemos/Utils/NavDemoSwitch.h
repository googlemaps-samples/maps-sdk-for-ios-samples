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

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** A control incorporating a label and a switch laid out horizontally. */
@interface NavDemoSwitch : UIStackView

/** Whether or not the switch is currently on. */
@property(nonatomic, getter=isOn) BOOL on;

/**
 * Whether or not this control is enabled.
 *
 * This affects both whether the switch responds to taps and the label text color.
 */
@property(nonatomic) BOOL enabled;

/**
 * Creates a NavDemoSwitch with the given label, target, and selector.
 *
 * If @c target and @c selector are nonnull, they will be set as the action for the touch up
 * inside event. The switch will initially be off. The label text color will be UIColor.labelColor.
 */
+ (NavDemoSwitch *)switchWithLabel:(NSString *)label
                            target:(nullable id)target
                          selector:(nullable SEL)selector;

/**
 * Creates a NavDemoSwitch with the given label and initial state.
 *
 * If @c target and @c selector are nonnull, they will be set as the action for the touch up
 * inside event. The label text color will be UIColor.labelColor.
 */
+ (NavDemoSwitch *)switchWithLabel:(NSString *)label
                      initialState:(BOOL)initialState
                            target:(nullable id)target
                          selector:(nullable SEL)selector;

/**
 * Initializes a NavDemoSwitch with the given values.
 *
 * If @c target and @c selector are nonnull, they will be set as the action for the touch up
 * inside event.
 */
- (instancetype)initWithLabel:(nonnull NSString *)label
                    textColor:(nonnull UIColor *)textColor
                 initialState:(BOOL)initialState
                       target:(nullable id)target
                     selector:(nullable SEL)selector NS_DESIGNATED_INITIALIZER;

/** Use the above designated initializer instead. */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
