/// Copyright 2020 Google LLC. All rights reserved.
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

import UIKit

/// A sample that will be used to demonstrate functionality of the SDK.
struct Sample {
  typealias ViewControllerProvider = () -> UIViewController
  let provider: ViewControllerProvider
  let title: String

  init(title: String, provider: @escaping ViewControllerProvider) {
    self.title = title
    self.provider = provider
  }

  init(viewControllerClass: UIViewController.Type, title: String) {
    self.provider = { viewControllerClass.init() }
    self.title = title
  }

  var viewController: UIViewController {
    provider()
  }
}

/// A section of samples.
struct Section {
  let name: String
  let samples: [Sample]
}

/// All samples to be displayed in the demo app.
enum Samples {
  static func allSamples() -> [Section] {
    let navigationSamples = [
      Sample(viewControllerClass: BasicNavigationViewController.self, title: "Basic Navigation"),
      Sample(viewControllerClass: RoutingOptionsViewController.self, title: "Routing Options"),
      Sample(viewControllerClass: SideOfRoadViewController.self, title: "SideOfRoad"),
      Sample(viewControllerClass: StopoverViewController.self, title: "Stopover"),
      Sample(viewControllerClass: NavigationUIOptionsViewController.self, title: "UI Options"),
      Sample(viewControllerClass: DataBackViewController.self, title: "Data Back"),
      Sample(
        viewControllerClass: NavigationSessionViewController.self, title: "Navigation Session"),
    ]

    var sections = [
      Section(name: "Navigation", samples: navigationSamples)
    ]

    return sections
  }
}
