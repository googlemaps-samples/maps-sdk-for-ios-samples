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

#import "GoogleNavXCFrameworkDemos/Utils/NavDemoSwitch.h"
#import <UIKit/UIKit.h>

@implementation NavDemoSwitch {
  UILabel *_label;
  UIColor *_textColor;
  UISwitch *_control;
}

+ (instancetype)switchWithLabel:(NSString *)label
                         target:(nullable id)target
                       selector:(nullable SEL)selector {
  return [self switchWithLabel:label initialState:NO target:target selector:selector];
}

+ (instancetype)switchWithLabel:(NSString *)label
                   initialState:(BOOL)initialState
                         target:(nullable id)target
                       selector:(nullable SEL)selector {
  return [[self alloc] initWithLabel:label
                           textColor:UIColor.labelColor
                        initialState:initialState
                              target:target
                            selector:selector];
}

- (instancetype)initWithLabel:(NSString *)label
                    textColor:(UIColor *)textColor
                 initialState:(BOOL)initialState
                       target:(nullable id)target
                     selector:(nullable SEL)selector {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    _enabled = YES;
    _textColor = textColor;

    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.text = label;
    _label.textColor = textColor;
    _label.font = [UIFont systemFontOfSize:12];
    [self addArrangedSubview:_label];

    _control = [[UISwitch alloc] initWithFrame:CGRectZero];
    _control.tintColor = [UIColor blackColor];
    _control.on = initialState;
    _control.accessibilityIdentifier = [NSString stringWithFormat:@"switch - %@", label];
    if (target && selector) {
      SEL _Nonnull validSelector = (SEL _Nonnull)selector;
      [_control addTarget:target action:validSelector forControlEvents:UIControlEventValueChanged];
    }
    _control.translatesAutoresizingMaskIntoConstraints = NO;
    [self addArrangedSubview:_control];
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)setEnabled:(BOOL)enabled {
  if (enabled == _enabled) {
    return;
  }
  _enabled = enabled;
  _control.enabled = enabled;
  _label.textColor = enabled ? _textColor : UIColor.lightGrayColor;
}

- (BOOL)isOn {
  return _control.on;
}

- (void)setOn:(BOOL)on {
  _control.on = on;
}

@end
