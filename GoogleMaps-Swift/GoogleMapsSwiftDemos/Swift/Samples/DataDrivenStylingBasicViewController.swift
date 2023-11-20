// Copyright 2023 Google LLC. All rights reserved.
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
/// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style
/// that enables the "Postal Code" feature layer.
private let mapIDWithPostalCodeLayer = ""
/// Put your Map ID in the string below. In the cloud console, configure the Map ID with a style
/// that enables the "Country" feature layer.
private let mapIDWithCountryLayer = ""

private struct FeatureLayerConfig {
  let title: String
  let type: FeatureType
  var mapID: String
  let highlightPlaceName: String
  let highlightPlaceID: String
}

private class SliderControls {
  let view: UIStackView
  let fillColor: UISlider
  let strokeColor: UISlider
  let strokeWidth: UISlider
  let label: UILabel

  private static func addSliderAndLabel(to parent: UIStackView, text: String, initialValue: Float)
    -> UISlider
  {
    let label = UILabel()
    label.text = text
    label.font = label.font.withSize(9)
    parent.addArrangedSubview(label)

    let slider = UISlider()
    slider.value = initialValue
    parent.addArrangedSubview(slider)
    return slider
  }

  var style: FeatureStyle {
    let fillColor = UIColor(
      hue: CGFloat(fillColor.value),
      saturation: 1,
      brightness: 0.5,
      alpha: 0.5
    )
    let strokeColor = UIColor(
      hue: CGFloat(strokeColor.value),
      saturation: 1,
      brightness: 0.5,
      alpha: 1
    )
    let strokeWidth = CGFloat(strokeWidth.value * 15)
    return FeatureStyle(
      fill: fillColor,
      stroke: strokeColor,
      strokeWidth: strokeWidth
    )
  }

  var allSliders: [UISlider] {
    [fillColor, strokeColor, strokeWidth]
  }

  init(isBaseStyle: Bool) {
    view = UIStackView()
    view.axis = .vertical
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .white.withAlphaComponent(0.5)

    fillColor = SliderControls.addSliderAndLabel(
      to: view, text: "Fill color", initialValue: isBaseStyle ? 0.5 : 0.75)
    strokeColor = SliderControls.addSliderAndLabel(
      to: view, text: "Stroke color", initialValue: isBaseStyle ? 0 : 0.25)
    strokeWidth = SliderControls.addSliderAndLabel(
      to: view, text: "Stroke width", initialValue: isBaseStyle ? 0.1 : 0.2)

    label = UILabel()
    label.text = isBaseStyle ? "Others" : "Highlight"
    label.font = label.font.withSize(10)
    label.textAlignment = .center
    view.addArrangedSubview(label)
  }
}

class DataDrivenStylingBasicViewController: UIViewController {

  private lazy var config = [
    FeatureLayerConfig(
      title: "Administrative Area Level 2",
      type: FeatureType.administrativeAreaLevel2,
      mapID: mapIDWithAdministrativeAreaLevel2Layer,
      highlightPlaceName: "Nye County, NV",
      highlightPlaceID: "ChIJJcLL_DeWvoARQyqHFcY2se4"
    ),
    FeatureLayerConfig(
      title: "Postal Code",
      type: FeatureType.postalCode,
      mapID: mapIDWithPostalCodeLayer,
      highlightPlaceName: "89049",
      highlightPlaceID: "ChIJCY_aZdEwuoARZDbZn-snj68"
    ),
    FeatureLayerConfig(
      title: "Country",
      type: FeatureType.country,
      mapID: mapIDWithCountryLayer,
      highlightPlaceName: "Senegal",
      highlightPlaceID: "ChIJcbvFs_VywQ4RQFlhmVClRlo"
    ),
  ]

  private lazy var segmentedControl = UISegmentedControl(items: config.map { $0.title })
  private lazy var toggle = UISwitch()

  private lazy var highlightStyleSliderControls = SliderControls(isBaseStyle: false)
  private lazy var baseStyleSliderControls = SliderControls(isBaseStyle: true)

  private var activeConfig: FeatureLayerConfig? {
    guard segmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment else { return nil }
    return config[segmentedControl.selectedSegmentIndex]
  }

  private var mainView: UIView? {
    get {
      view.subviews.first
    }
    set {
      view.subviews.first?.removeFromSuperview()
      let newView = newValue ?? UIView()
      view.insertSubview(newView, at: 0)
      newView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate(
        [
          newView.topAnchor.constraint(equalTo: view.topAnchor),
          newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          newView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
  }

  private lazy var featureTypeSelectionLabel: UILabel = {
    let label = UILabel()
    label.text = "Select a feature type"
    label.textAlignment = .center
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    mainView = featureTypeSelectionLabel

    segmentedControl.addTarget(
      self, action: #selector(changeMapType), for: .valueChanged)
    navigationItem.titleView = segmentedControl

    toggle.addTarget(self, action: #selector(activateFeatureLayer), for: .valueChanged)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: toggle)

    (highlightStyleSliderControls.allSliders + baseStyleSliderControls.allSliders).forEach {
      $0.addTarget(self, action: #selector(activateFeatureLayer), for: .valueChanged)
    }

    view.addSubview(highlightStyleSliderControls.view)
    view.addSubview(baseStyleSliderControls.view)
    NSLayoutConstraint.activate(
      [
        highlightStyleSliderControls.view.widthAnchor.constraint(
          equalTo: baseStyleSliderControls.view.widthAnchor),
        highlightStyleSliderControls.view.trailingAnchor.constraint(
          equalTo: baseStyleSliderControls.view.leadingAnchor),
        highlightStyleSliderControls.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        baseStyleSliderControls.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        highlightStyleSliderControls.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        baseStyleSliderControls.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    changeMapType()
  }

  @objc func changeMapType() {
    guard let activeConfig else {
      mainView = featureTypeSelectionLabel
      highlightStyleSliderControls.view.isHidden = true
      baseStyleSliderControls.view.isHidden = true
      return
    }
    let configIndex = segmentedControl.selectedSegmentIndex

    var mapID = activeConfig.mapID
    if mapID.isEmpty {
      promptForMapID(description: "with \(activeConfig.title) layer enabled") {
        self.config[configIndex].mapID = $0
        self.setUp()
      }
    } else {
      self.setUp()
    }
  }

  private func setUp() {
    guard let activeConfig else {
      return
    }
    guard !activeConfig.mapID.isEmpty else {
      let label = UILabel()
      label.text = "A Map ID is required"
      label.textAlignment = .center
      mainView = label
      segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
      highlightStyleSliderControls.view.isHidden = true
      baseStyleSliderControls.view.isHidden = true
      return
    }

    let camera = GMSCameraPosition(latitude: 38.590240, longitude: -95.712891, zoom: 4)
    mainView = GMSMapView(
      frame: .zero, mapID: GMSMapID(identifier: activeConfig.mapID), camera: camera)
    toggle.setOn(false, animated: false)

    highlightStyleSliderControls.label.text = activeConfig.highlightPlaceName
    highlightStyleSliderControls.view.isHidden = false
    baseStyleSliderControls.view.isHidden = false
  }

  @objc func activateFeatureLayer() {
    guard let activeConfig, let mapView = mainView as? GMSMapView else { return }

    let layer = mapView.featureLayer(of: activeConfig.type)

    if toggle.isOn {
      if !layer.isAvailable {
        showToast(
          message: "Feature layer \(activeConfig.title) is not available; see debug log for details"
        )
      }
      let placeID = activeConfig.highlightPlaceID
      let specialStyle = highlightStyleSliderControls.style
      let style = baseStyleSliderControls.style
      layer.style = { ($0.placeID == placeID) ? specialStyle : style }
    } else {
      layer.style = nil
    }
  }
}
