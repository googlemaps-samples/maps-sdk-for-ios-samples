// Copyright 2022 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import GoogleMaps
import UIKit

/// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style
/// that enables all data-driven styling feature layers.
private let mapIDWithMultipleLayers = ""

class DataDrivenStylingEventsViewController: UIViewController {
  private let sectionIdentifierForLayerToggles = "sectionIdentifierForLayerToggles"
  private let cellIdentifier = "cellIdentifier"

  private lazy var featureLayerStates: [FeatureType: FeatureLayerState] = [
    .country: FeatureLayerState(label: "Country", color: .purple),
    .administrativeAreaLevel1: FeatureLayerState(label: "Admin1", color: .orange),
    .administrativeAreaLevel2: FeatureLayerState(label: "Admin2", color: .blue),
    .locality: FeatureLayerState(label: "Locality", color: .red),
    .postalCode: FeatureLayerState(label: "Postal Code", color: .brown),
    .schoolDistrict: FeatureLayerState(label: "School District", color: .cyan),
  ]

  private lazy var tableView = {
    let view = UITableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundView = nil
    view.backgroundColor = .white.withAlphaComponent(0.75)
    view.contentInsetAdjustmentBehavior = .never
    view.contentInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: -10)
    view.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    return view
  }()

  private lazy var dataSource = UITableViewDiffableDataSource<String, String>(tableView: tableView)
  {
    (tableView: UITableView, indexPath: IndexPath, itemIdentifier: String) -> UITableViewCell? in
    guard let section = self.sectionIdentifier(for: indexPath) else { return nil }
    let isToggleControl = section == self.sectionIdentifierForLayerToggles
    let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
    let textLabel = cell.textLabel!
    if isToggleControl {
      if let featureLayerState = self.featureLayerStates[FeatureType(rawValue: itemIdentifier)] {
        let layerActive = featureLayerState.layer != nil
        textLabel.text = "\(layerActive ? "☑" : "☐") \(featureLayerState.label)"
        textLabel.font = textLabel.font.withSize(14)
        textLabel.textColor = featureLayerState.color.withAlphaComponent(
          layerActive ? 1 : 0.75)
      }
    } else {
      if let featureLayerState = self.featureLayerStates[FeatureType(rawValue: section)] {
        textLabel.text = featureLayerState.featureNameByPlaceID[itemIdentifier]
        textLabel.font = textLabel.font.withSize(12)
        textLabel.textColor = featureLayerState.color
      }
    }
    return cell
  }

  private var mapID = mapIDWithMultipleLayers

  private lazy var mapView = {
    let camera = GMSCameraPosition(latitude: 47.61, longitude: -122.34, zoom: 10)
    let view = GMSMapView(
      frame: .zero, mapID: GMSMapID(identifier: mapID), camera: camera)
    view.delegate = self
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    if mapID.isEmpty {
      promptForMapID(description: "with all data-driven styling layers enabled") {
        self.mapID = $0
        self.setUp()
      }
    } else {
      setUp()
    }
  }

  private func setUp() {
    guard mapID.count != 0 else {
      let label = UILabel()
      label.text = "A Map ID is required"
      label.textAlignment = .center
      view = label
      return
    }
    view = mapView
    tableView.dataSource = dataSource
    tableView.delegate = self
    mapView.addSubview(tableView)
    NSLayoutConstraint.activate(
      [
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.widthAnchor.constraint(equalToConstant: 120),
      ])

    let featureTypes: Array = featureLayerStates.keys.map({ $0.rawValue }).sorted()
    var diff = NSDiffableDataSourceSnapshot<String, String>()
    diff.appendSections([sectionIdentifierForLayerToggles])
    diff.appendSections(featureTypes)
    diff.appendItems(
      featureTypes,
      toSection: sectionIdentifierForLayerToggles
    )
    dataSource.apply(diff)
  }
}

extension DataDrivenStylingEventsViewController: GMSMapViewDelegate {
  func mapView(
    _ mapView: GMSMapView, didTap features: [Feature],
    in featureLayer: FeatureLayer<Feature>, atLocation: CLLocationCoordinate2D
  ) {
    let featureType = featureLayer.featureType
    guard let state = featureLayerStates[featureType] else { return }

    var snapshot = dataSource.snapshot()
    for case let feature as PlaceFeature in features {
      if state.togglePlaceSelection(feature.placeID) {
        snapshot.appendItems([feature.placeID], toSection: featureType.rawValue)
      } else {
        snapshot.deleteItems([feature.placeID])
      }
    }
    dataSource.apply(snapshot)
    (featureLayer as? FeatureLayer<PlaceFeature>)?.style = state.makeStyleBlock()
  }
}

extension DataDrivenStylingEventsViewController: UITableViewDelegate {
  fileprivate func sectionIdentifier(for indexPath: IndexPath) -> String? {
    if #available(iOS 15.0, *) {
      return dataSource.sectionIdentifier(for: indexPath.section)
    } else {
      return dataSource.snapshot().sectionIdentifiers[indexPath.section]
    }
  }

  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    return (sectionIdentifier(for: indexPath) == sectionIdentifierForLayerToggles)
      ? 36 : 24
  }

  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    guard let section = sectionIdentifier(for: indexPath),
      let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
    else { return }
    if section == sectionIdentifierForLayerToggles {
      let featureType = FeatureType(rawValue: itemIdentifier)
      guard let state = featureLayerStates[featureType] else { return }
      if let layer = state.layer {
        layer.style = nil
        state.layer = nil
      } else {
        let layer = mapView.featureLayer(of: featureType)
        layer.style = state.makeStyleBlock()
        state.layer = layer
        if !layer.isAvailable {
          showToast(
            message:
              "Feature layer \(state.label) is not available; see debug log for details"
          )
        }
      }
      var diff = dataSource.snapshot()
      diff.reloadItems([itemIdentifier])
      dataSource.apply(diff)
    } else {
      guard let state = featureLayerStates[FeatureType(rawValue: section)] else { return }
      let previouslySelected = !state.togglePlaceSelection(itemIdentifier)
      assert(previouslySelected)
      state.layer?.style = state.makeStyleBlock()
      var diff = dataSource.snapshot()
      diff.deleteItems([itemIdentifier])
      dataSource.apply(diff)
    }
  }
}

private class FeatureLayerState {
  let label: String
  let color: UIColor
  var layer: FeatureLayer<PlaceFeature>? = nil

  private(set) var featureNameByPlaceID: [String: String] = [:]

  init(label: String, color: UIColor) {
    self.label = label
    self.color = color
  }

  // Toggles selection state of a place ID, returns true if it's added, false if it's removed.
  func togglePlaceSelection(_ placeID: String) -> Bool {
    let adding = featureNameByPlaceID.removeValue(forKey: placeID) == nil
    if adding {
      featureNameByPlaceID[placeID] = "[Place \(placeID)]"
    }
    return adding
  }

  func updateFeatureName(for placeID: String, to name: String?) {
    // Don't add the place to featureNameByPlaceID if it isn't already selected.
    if featureNameByPlaceID[placeID] == nil { return }
    featureNameByPlaceID[placeID] = name ?? "[Error \(placeID)]"
  }

  func makeStyleBlock() -> ((PlaceFeature) -> FeatureStyle) {
    let nonSelectedStyle = FeatureStyle(
      fill: color.withAlphaComponent(0.25),
      stroke: color,
      strokeWidth: 1.5
    )
    let selectedStyle = FeatureStyle(
      fill: color.withAlphaComponent(0.5),
      stroke: color,
      strokeWidth: 3
    )
    return { (self.featureNameByPlaceID[$0.placeID] != nil) ? selectedStyle : nonSelectedStyle }
  }
}
