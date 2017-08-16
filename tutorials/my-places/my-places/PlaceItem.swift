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

import Foundation
import Firebase

struct PlaceItem {

  var name: String
  var placeId: String
  var key: String

  init(name: String, placeId: String, key: String) {
    self.name = name
    self.placeId = placeId
    self.key = key
  }

  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    placeId = snapshotValue["placeId"] as! String
  }

  func toAnyObject() -> [String: String] {
    return [
      "name": name,
      "placeId": placeId
    ]
  }
}
