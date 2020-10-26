// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// [START maps_ios_quadtree]
import GoogleMapsUtils

class QuadTreeItem : NSObject, GQTPointQuadTreeItem {
  private let gqtPoint : GQTPoint

  init(point : GQTPoint) {
    self.gqtPoint = point
  }

  func point() -> GQTPoint {
    return gqtPoint
  }

  /// Function demonstrating how to create and use a quadtree
  private func test() {

    // Create a quadtree with bounds of [-2, -2] to [2, 2].
    let bounds = GQTBounds(minX: -2, minY: -2, maxX: 2, maxY: 2)
    guard let tree = GQTPointQuadTree(bounds: bounds) else {
      return
    }

    // Add 4 points to the tree.
    tree.add(QuadTreeItem(point: GQTPoint(x: -1, y: -1)))
    tree.add(QuadTreeItem(point: GQTPoint(x: -1, y: -1)))
    tree.add(QuadTreeItem(point: GQTPoint(x: -1, y: 1)))
    tree.add(QuadTreeItem(point: GQTPoint(x: 1, y: 1)))
    tree.add(QuadTreeItem(point: GQTPoint(x: 1, y: -1)))

    // Search for items within the rectangle with lower corner of (-1.5, -1.5)
    // and upper corner of (1.5, 1.5).
    let searchBounds = GQTBounds(minX: -1.5, minY: -1.5, maxX: 1.5, maxY: 1.5)
    for item in tree.search(with: searchBounds) as! [QuadTreeItem] {
      print("(\(item.point().x), \(item.point().y))");
    }
  }
}
// [END maps_ios_quadtree]
