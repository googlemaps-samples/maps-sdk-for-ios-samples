/// Copyright 2024 Google LLC. All rights reserved.
///
///
/// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
/// file except in compliance with the License. You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software distributed under
/// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
/// ANY KIND, either express or implied. See the License for the specific language governing
/// permissions and limitations under the License.

import CarPlay
import Foundation
import GoogleNavigation

class CarPlayApplicationSceneInformationController {

  static func makeInformationTemplate(window: CPWindow) -> CPInformationTemplate {
    let navSDKVersion = GMSNavigationServices.navSDKVersion()
    let versionItem = CPInformationItem(title: "Version", detail: navSDKVersion)
    let noMapExplanationItem = CPInformationItem(
      title: "Status",
      detail:
        "Either no sample is currently running, or the current sample does not support CarPlay.")
    let showToSButton = CPTextButton(title: "Show TOS", textStyle: .normal) { _ in
      didTapShowToSButton()
    }
    let informationTemplate = CPInformationTemplate(
      title: "NavSDK Swift Demo Application", layout: .leading,
      items: [versionItem, noMapExplanationItem], actions: [showToSButton])
    return informationTemplate
  }

  private static func didTapShowToSButton() {
    GMSNavigationServices.resetTermsAndConditionsAccepted()
    GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(
      withCompanyName: "Nav Demo Company",
      callback: { termsAccepted in
      })
  }

}
