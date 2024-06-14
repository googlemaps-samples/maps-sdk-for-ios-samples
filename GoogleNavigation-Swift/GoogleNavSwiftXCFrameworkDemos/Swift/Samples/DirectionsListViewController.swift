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

import GoogleNavigation
import UIKit

class DirectionsListViewController: UIViewController {

  /// The controller that handles the display of the directions.
  var directionsListController: GMSNavigationDirectionsListController? {
    didSet {
      guard directionsListController != oldValue else { return }
      if let oldDirectionsListController = oldValue {
        oldDirectionsListController.directionsListView.removeFromSuperview()
      }
      guard let directionsListController = directionsListController else { return }
      if isViewLoaded {
        addSubviewFromDirectionsListController(directionsListController)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let directionsListController = directionsListController else { return }
    addSubviewFromDirectionsListController(directionsListController)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    directionsListController?.reloadData()
  }

  override func willTransition(
    to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.willTransition(to: newCollection, with: coordinator)
    coordinator.animate(alongsideTransition: { [weak self] _ in
      self?.directionsListController?.invalidateLayout()
    })
  }

  private func addSubviewFromDirectionsListController(
    _ directionsListController: GMSNavigationDirectionsListController
  ) {
    let directionsListView = directionsListController.directionsListView
    directionsListView.frame = view.bounds
    view.addSubview(directionsListView)
    directionsListView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      directionsListView.topAnchor.constraint(equalTo: view.topAnchor),
      directionsListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      directionsListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      directionsListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}
