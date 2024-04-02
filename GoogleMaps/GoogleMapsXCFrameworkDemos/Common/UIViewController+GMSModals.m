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

#import "GoogleMapsXCFrameworkDemos/Common/UIViewController+GMSModals.h"

@implementation UIViewController (GMSModals)

- (void)gms_showToastWithMessage:(NSString *)message {
  UIAlertController *toast =
      [UIAlertController alertControllerWithTitle:nil
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  [self presentViewController:toast
                     animated:YES
                   completion:^{
                     const int kDuration = 2;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kDuration * NSEC_PER_SEC),
                                    dispatch_get_main_queue(), ^{
                                      [toast dismissViewControllerAnimated:YES completion:nil];
                                    });
                   }];
}

- (void)gms_promptForMapIDWithDescription:(NSString *)description
                                  handler:(void (^)(NSString *mapID))handler {
  UIAlertController *alertController = [UIAlertController
      alertControllerWithTitle:@"Map ID to use"
                       message:[NSString stringWithFormat:@"Enter a Map ID configured from the "
                                                          @"Cloud Console %@",
                                                          description]
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                         handler(nil);
                                                       }];
  [alertController addAction:cancelAction];
  UIAlertAction *okAction =
      [UIAlertAction actionWithTitle:@"Confirm"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                               handler(alertController.textFields.firstObject.text);
                             }];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Map ID";
  }];
  [alertController addAction:okAction];
  [self presentViewController:alertController animated:YES completion:nil];
}

@end
