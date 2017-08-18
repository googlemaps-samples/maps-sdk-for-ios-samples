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

struct PlaceCollection {

  var key: String
  var title: String

  init(key: String, title: String) {
    self.key = key
    self.title = title
  }

  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    title = snapshotValue["title"] as! String
  }

  func toAnyObject() -> [String: String] {
    return [
      "title": title,
      "key": key
    ]
  }
}
