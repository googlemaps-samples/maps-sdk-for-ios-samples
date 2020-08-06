/* Copyright (c) 2020 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import GoogleMapsUtils
import UIKit

class POIItem: NSObject, GMUClusterItem {
    internal var position: CLLocationCoordinate2D
    private var name: String = ""

    // MARK: Initialization functions

    /// The constructor
    ///
    /// - Parameters:
    ///   - position: The coordinates of the POIItem.
    ///   - name: A random name; not too relevant for current usage.
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
