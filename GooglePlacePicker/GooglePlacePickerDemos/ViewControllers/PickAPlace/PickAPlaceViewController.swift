/*
 * Copyright 2016 Google Inc. All rights reserved.
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

import UIKit
import GooglePlacePicker

/// A view controller which displays a UI for opening the Place Picker. Once a place is selected
/// it navigates to the place details screen for the selected location.
class PickAPlaceViewController: UIViewController {
  @IBOutlet private weak var pickAPlaceButton: UIButton!
  @IBOutlet weak var buildNumberLabel: UILabel!
  var mapViewController: BackgroundMapViewController?

  init() {
    super.init(nibName: String(describing: type(of: self)), bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // This is the size we would prefer to be.
    self.preferredContentSize = CGSize(width: 330, height: 600)

    // Configure our view.
    view.backgroundColor = Colors.blue1
    view.clipsToBounds = true

    // Set the build number.
    buildNumberLabel.text = "Places API Build: \(GMSPlacesClient.sdkVersion())"
  }

  @IBAction func buttonTapped() {
    // Create a place picker. Attempt to display it as a popover if we are on a device which
    // supports popovers.
    let config = GMSPlacePickerConfig(viewport: nil)
    let placePicker = GMSPlacePickerViewController(config: config)
    placePicker.delegate = self
    placePicker.modalPresentationStyle = .popover
    placePicker.popoverPresentationController?.sourceView = pickAPlaceButton
    placePicker.popoverPresentationController?.sourceRect = pickAPlaceButton.bounds

    // Display the place picker. This will call the delegate methods defined below when the user
    // has made a selection.
    self.present(placePicker, animated: true, completion: nil)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

extension PickAPlaceViewController : GMSPlacePickerViewControllerDelegate {
  func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
    // Create the next view controller we are going to display and present it.
    let nextScreen = PlaceDetailViewController(place: place)
    self.splitPaneViewController?.push(viewController: nextScreen, animated: false)
    self.mapViewController?.coordinate = place.coordinate

    // Dismiss the place picker.
    viewController.dismiss(animated: true, completion: nil)
  }

  func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
    // In your own app you should handle this better, but for the demo we are just going to log
    // a message.
    NSLog("An error occurred while picking a place: \(error)")
  }

  func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
    NSLog("The place picker was canceled by the user")

    // Dismiss the place picker.
    viewController.dismiss(animated: true, completion: nil)
  }
}
