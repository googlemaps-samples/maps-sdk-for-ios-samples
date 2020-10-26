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

#import "QuadTree.h"
// [START maps_ios_quadtree]
@import GoogleMapsUtils;

@interface QuadTreeItem : NSObject<GQTPointQuadTreeItem>
- (instancetype)initWithPoint:(GQTPoint)point;
@end

@implementation QuadTreeItem {
  GQTPoint _point;
}

- (instancetype)initWithPoint:(GQTPoint)point {
  if ((self = [super init])) {
    _point = point;
  }
  return self;
}

- (GQTPoint)point {
  return _point;
}

/// Function demonstrating how to create and use a quadtree
- (void)test {
  // Create a quadtree with bounds of [-2, -2] to [2, 2].
  GQTBounds bounds = {-2, -2, 2, 2};
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] initWithBounds:bounds];

  // Add 4 points to the tree.
  [tree add:[[QuadTreeItem alloc] initWithPoint:(GQTPoint){-1, -1}]];
  [tree add:[[QuadTreeItem alloc] initWithPoint:(GQTPoint){-1, 1}]];
  [tree add:[[QuadTreeItem alloc] initWithPoint:(GQTPoint){1, 1}]];
  [tree add:[[QuadTreeItem alloc] initWithPoint:(GQTPoint){1, -1}]];

  // Search for items within the rectangle with lower corner of (-1.5, -1.5)
  // and upper corner of (1.5, 1.5).
  NSArray *foundItems = [tree searchWithBounds:(GQTBounds){-1.5, -1.5, 1.5, 1.5}];

  for (QuadTreeItem *item in foundItems) {
    NSLog(@"(%lf, %lf)", item.point.x, item.point.y);
  }
}

@end
// [END maps_ios_quadtree]
