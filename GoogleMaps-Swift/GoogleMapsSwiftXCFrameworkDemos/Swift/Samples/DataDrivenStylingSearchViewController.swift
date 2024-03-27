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
/// that enables the "Administrative Area Level 2" feature layer.
private let mapIDWithAdministrativeAreaLevel2Layer = ""

private let initialSearches = [
  "Nye County", "San Bernardino County", "Juab County", "Crook County",
]

private func buildSearchRequest(forPlaceName placeName: String) -> URLRequest {
  // URL initializer only returns nil when the URL string is malformed, but it is a known valid
  // string literal here.
  let requestURL = URL(string: "https://places.googleapis.com/v1/places:searchText")!
  var urlRequest = URLRequest(url: requestURL)
  urlRequest.httpMethod = "POST"
  urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
  urlRequest.addValue(SDKConstants.apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
  urlRequest.addValue("places.id", forHTTPHeaderField: "X-Goog-FieldMask")
  urlRequest.addValue(
    Bundle.main.bundleIdentifier ?? "unknown_ios", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
  urlRequest.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "textQuery": placeName,
      "includedType": "administrative_area_level_2",
      "languageCode": "en",
    ], options: [])
  return urlRequest
}

private struct PlaceTextSearchResponse: Codable {
  struct Place: Codable {
    let id: String
  }

  let places: [Place]
}

private class PlaceLookupController: NSObject {
  let serial: Int
  let controller: DataDrivenStylingSearchViewController

  var name: String? {
    didSet {
      let effectiveName = name ?? ""
      view.text = effectiveName
      guard !effectiveName.isEmpty else { return }
      let task = controller.urlSession.dataTask(
        with: buildSearchRequest(forPlaceName: effectiveName)
      ) {
        data, response, error in
        if let error {
          self.textSearchFailed(with: error)
          return
        }
        do {
          guard let data else {
            preconditionFailure("Response \(response) is empty")
          }
          let decoder = JSONDecoder()
          let decodedResponse = try decoder.decode(PlaceTextSearchResponse.self, from: data)
          if let extractedID = decodedResponse.places.first?.id {
            self.placeID = extractedID
          } else {
            preconditionFailure("Place ID not found from \(response)")
          }
        } catch {
          self.textSearchFailed(with: error)
        }
      }
      task.resume()
    }
  }

  var color: UIColor = .clear {
    didSet {
      colorSelectionButton.setTitleColor(color, for: .normal)
      controller.reloadStyle()
    }
  }

  private(set) var placeID: String? {
    didSet {
      colorSelectionButton.setTitle("⬤", for: .normal)
      controller.reloadStyle()
    }
  }

  private lazy var colorSelectionButton: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = button.titleLabel?.font.withSize(12)
    button.setTitle("❓", for: .normal)
    button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
    return button
  }()

  lazy var view: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = .white.withAlphaComponent(0.5)
    textField.font = textField.font?.withSize(12)
    textField.delegate = self

    textField.leftView = colorSelectionButton
    textField.leftViewMode = .always

    let clearButton = UIButton()
    clearButton.titleLabel?.font = clearButton.titleLabel?.font.withSize(12)
    clearButton.setTitle("🗑️", for: .normal)
    clearButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
    textField.rightView = clearButton
    textField.rightViewMode = .unlessEditing

    textField.clearButtonMode = .whileEditing
    return textField
  }()

  init(controller: DataDrivenStylingSearchViewController, serial: Int) {
    self.controller = controller
    self.serial = serial
  }

  func focusTextEdit() {
    view.becomeFirstResponder()
  }

  @objc func remove() {
    controller.removeFeature(self)
  }

  private func textSearchFailed(with error: Error) {
    colorSelectionButton.setTitle("❗", for: .normal)
    NSLog("Feature \(name) not found: \(error)")
  }

  @objc func selectionButtonTapped() {
    let selector = UIColorPickerViewController()
    selector.selectedColor = color ?? .white
    selector.supportsAlpha = false
    selector.delegate = self
    controller.present(selector, animated: true)
  }
}

extension PlaceLookupController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    guard !text.isEmpty else {
      colorSelectionButton.setTitle("❓", for: .normal)
      return
    }
    guard name != text else { return }
    colorSelectionButton.setTitle("⏳", for: .normal)
    name = text
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

extension PlaceLookupController: UIColorPickerViewControllerDelegate {
  func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
    color = viewController.selectedColor
  }
}

/// Table view that does not intercept gestures outside table cells.
class NotCapturingTouchesTableView: UITableView {
  // This override causes the view to not intercept gestures, unless the gesture occurs on one of
  // this view's subviews. The UITableView should not prevent the map from panning/zooming/tilting.
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    // If no descendent of this view contains the specified point, return nil. nil is returned if
    // the point does not fit inside the view.
    if view == self {
      return nil
    } else {
      // If there is a descendent of this view that contains the specified point, return that view.
      return view
    }
  }
}

class DataDrivenStylingSearchViewController: UIViewController {
  private let cellIdentifier = "cellIdentifier"

  fileprivate let urlSession = URLSession(
    configuration: .default, delegate: nil,
    delegateQueue: .main)

  private var placeSerial = 0
  private var places: [Int: PlaceLookupController] = [:]
  private var computedColorMapping: [String: UIColor]?

  private lazy var tableView: UITableView = {
    let view = NotCapturingTouchesTableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundView = nil
    view.backgroundColor = .clear
    view.contentInsetAdjustmentBehavior = .never
    view.rowHeight = 28
    view.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    return view
  }()

  private lazy var dataSource = UITableViewDiffableDataSource<Int, Int>(tableView: tableView) {
    (tableView: UITableView, indexPath: IndexPath, itemIdentifier: Int) -> UITableViewCell? in
    let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    cell.backgroundColor = .clear
    guard let view = self.places[itemIdentifier]?.view else { return cell }
    cell.contentView.addSubview(view)
    NSLayoutConstraint.activate(
      [
        cell.contentView.topAnchor.constraint(equalTo: view.topAnchor),
        cell.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        cell.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        cell.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    return cell
  }

  private var mapID = mapIDWithAdministrativeAreaLevel2Layer

  private lazy var mapView = {
    let camera = GMSCameraPosition(latitude: 40, longitude: -117.5, zoom: 5.5)
    let view = GMSMapView(
      frame: .zero, mapID: GMSMapID(identifier: mapID), camera: camera)
    view.translatesAutoresizingMaskIntoConstraints = false
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

    tableView.dataSource = dataSource
    view.addSubview(mapView)
    view.addSubview(tableView)

    NSLayoutConstraint.activate(
      [
        mapView.topAnchor.constraint(equalTo: view.topAnchor),
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.topAnchor.constraint(equalTo: view.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
      ])

    let addAction = UIAction(
      title: "+"
    ) { _ in self.addButtonTapped() }
    navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: addAction)

    var diff = NSDiffableDataSourceSnapshot<Int, Int>()
    diff.appendSections([0])
    diff.appendItems(
      initialSearches.map { addFeature(name: $0).0 }
    )
    dataSource.apply(diff)
  }

  private func addButtonTapped() {
    let (itemIdentifier, lookup) = addFeature()
    var diff = dataSource.snapshot()
    diff.appendItems([itemIdentifier])
    dataSource.apply(diff)
    DispatchQueue.main.async {
      lookup.focusTextEdit()
    }
  }

  private func nextColorHue() -> Float {
    var hueValues: [Float] = places.compactMap { (_, config) in
      var hue = CGFloat.nan
      if config.color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil) {
        if hue >= 0 && hue <= 1 {
          return Float(hue)
        }
      }
      return nil
    }
    var candidateHue = (hueValues.first ?? 0) - 0.5
    if hueValues.count > 1 {
      hueValues.sort()
      let diffs =
        [1 + hueValues.first! - hueValues.last!] + zip(hueValues.dropFirst(), hueValues).map(-)
      let (largestGap, endOfLargestGap) = (zip(diffs, hueValues).max { $0.0 < $1.0 })!
      candidateHue = endOfLargestGap - largestGap / 2
    }
    if candidateHue < 0 {
      candidateHue += 1
    }
    return candidateHue
  }

  private func addFeature(name: String? = nil) -> (Int, PlaceLookupController) {
    placeSerial += 1
    let itemIdentifier = placeSerial
    let featureConfig = PlaceLookupController(controller: self, serial: itemIdentifier)
    featureConfig.color = UIColor(
      hue: CGFloat(nextColorHue()),
      saturation: 1,
      brightness: 0.75,
      alpha: 1)
    featureConfig.name = name
    places[itemIdentifier] = featureConfig
    return (itemIdentifier, featureConfig)
  }

  fileprivate func removeFeature(_ feature: PlaceLookupController) {
    guard places.count > 1 else { return }
    var diff = dataSource.snapshot()
    diff.deleteItems([feature.serial])
    dataSource.apply(diff)

    places.removeValue(forKey: feature.serial)
    reloadStyle()
  }

  fileprivate func reloadStyle() {
    var colorMapping: [String: UIColor] = Dictionary(
      places.compactMap { (_, config) in
        config.placeID.map { ($0, config.color) }
      },
      uniquingKeysWith: { (first, _) in first })
    // Skip restyling if the mapping hasn't actually changed, since restyling can be expensive.
    guard colorMapping != computedColorMapping else { return }
    computedColorMapping = colorMapping
    mapView.featureLayer(of: .administrativeAreaLevel2).style = {
      guard let color = colorMapping[$0.placeID] else { return nil }
      return FeatureStyle(
        fill: color.withAlphaComponent(0.5),
        stroke: color,
        strokeWidth: 1.5
      )
    }
  }
}
