/*
 * Copyright 2017 Google Inc. All rights reserved.
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

/// A utility for creating a ViewController for entering the name of a collection.
struct NameEditor {

  /// Creates a controller to enter the collection name into. If the controller is canceled the
  /// callback is called with nil, otherwise it is called with the entered string.
  ///
  ///  - param existingText: The text to pre-fill the alert with
  ///  - param completion: The callback invoked when the alert is dismissed
  static func create(existingText: String? = nil,
                     completion: @escaping (String?) -> ()) -> UIAlertController {
    let alertController = UIAlertController(title: "Collection Name",
                                            message: "Enter a name for this collection.",
                                            preferredStyle: .alert)


    alertController.addTextField { (textField) in
      textField.text = existingText
    }

    alertController.addAction(UIAlertAction(title: "OK", style: .default,
                                            handler: { [weak alertController] (_) in
      let text = alertController?.textFields?.first?.text!
      completion(text)
    }))

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
      completion(nil)
    }))

    return alertController
  }
}
