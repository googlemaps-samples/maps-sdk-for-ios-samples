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

import GoogleMaps

/// Demonstrate basic usage of the Cloud Styling feature.
class CloudBasedMapStylingViewController: UIViewController {

  private static let mapIdRetro = "13564581852493597319"
  private static let mapIdDemo = "11153850776783499500"
  private var mapIds = [
    mapIdRetro, mapIdDemo
  ]

  private var mapView: GMSMapView!

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView = GMSMapView(frame: .zero, camera: GMSCameraPosition(target: CLLocationCoordinate2D.newYork, zoom: 12))
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.view = mapView

    let styleButton = UIBarButtonItem(title: "Style Map", style: .plain, target: self, action: #selector(self.changeMapId))
    self.navigationItem.rightBarButtonItem = styleButton
  }

  /// Bring up a selection list of existing Map IDs, and the option to add a new one.
  @objc func changeMapId(sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Select Map ID", message: "Change the look of the map with a map ID", preferredStyle: .actionSheet)

    let alertAction = UIAlertAction(title: "Add a new Map ID", style: .destructive) { [weak self] action in
      guard let self = self else { return }
      self.showAddMapIdAlert()
    }
    alert.addAction(alertAction)

    // Lists the existing Map IDs for selection.
    mapIds.forEach { mapId in
      let mapIdAction = UIAlertAction(title: mapId, style: .default) { [weak self] _ in
        guard let self = self else { return }
        self.updateMap(withId: mapId)
      }
      alert.addAction(mapIdAction)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(cancelAction)

    alert.popoverPresentationController?.barButtonItem = sender
    present(alert, animated: true)
  }

  ///  Re-create the map view with the specified mapID.
  private func updateMap(withId id: String) {
    let mapId = GMSMapID(identifier: id)
    mapView = GMSMapView(frame: .zero, mapID: mapId, camera: mapView.camera)
    self.view = mapView
  }

  /// Bring up a selection list of existing Map IDs, and the option to add a new one.
  private func showAddMapIdAlert() {
    let alert = UIAlertController(title: "Add a new map ID", message: nil, preferredStyle: .alert)
    alert.addTextField { textField in
      textField.placeholder = "Map ID"
      textField.clearButtonMode = .whileEditing
    }

    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
      guard let self = self else { return }
      guard let textField = alert.textFields?.first else { return }
      guard let mapId = textField.text else { return }
      self.mapIds.append(mapId)
      self.updateMap(withId: mapId)
    }))
    present(alert, animated: true)
  }
}
