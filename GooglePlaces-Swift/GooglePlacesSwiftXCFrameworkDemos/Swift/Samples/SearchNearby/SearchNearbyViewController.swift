// Copyright 2024 Google LLC. All rights reserved.
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

import CoreLocation
import GooglePlaces
import UIKit

class SearchNearbyViewController: UIViewController,
  UITableViewDelegate,
  UITableViewDataSource
{

  private let googleMTV = "Google Mountain View"
  private let googleSunnyvale = "Google Sunnyvale"
  private let googleSanFrancisco = "Google San Francisco"

  private let googleMTVLatitude = "37.422095"
  private let googleMTVLongitude = "-122.085430"
  private let googleSunnyvaleLatitude = "37.407022"
  private let googleSunnyvaleLongitude = "-122.021402"
  private let googleSanFranciscoLatitude = "37.790736"
  private let googleSanFranciscoLongitude = "-122.390152"

  private let cellIdentifier = "SearchNearbyCellIdentifier"

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()

  private lazy var scrollViewStackView: UIStackView = {
    let scrollViewStackView = UIStackView()
    scrollViewStackView.axis = .vertical
    scrollViewStackView.spacing = 16
    scrollViewStackView.distribution = .fillProportionally
    scrollViewStackView.translatesAutoresizingMaskIntoConstraints = false
    return scrollViewStackView
  }()

  private lazy var latitudeField: UITextField = {
    let latitudeField = UITextField()
    latitudeField.delegate = self
    latitudeField.borderStyle = .roundedRect
    latitudeField.textColor = .label
    latitudeField.placeholder = "Latitude"
    latitudeField.backgroundColor = .secondarySystemBackground
    return latitudeField
  }()

  private lazy var longitudeField: UITextField = {
    let longitudeField = UITextField()
    longitudeField.delegate = self
    longitudeField.borderStyle = .roundedRect
    longitudeField.textColor = .label
    longitudeField.placeholder = "Longitude"
    longitudeField.backgroundColor = .secondarySystemBackground
    return longitudeField
  }()

  private lazy var radiusField: UITextField = {
    let radiusField = UITextField()
    radiusField.delegate = self
    radiusField.borderStyle = .roundedRect
    radiusField.textColor = .label
    radiusField.placeholder = "Radius"
    radiusField.backgroundColor = .secondarySystemBackground
    return radiusField
  }()

  private lazy var includedTypes = ParameterInputTextField(title: "Included Types")
  private lazy var excludedTypes = ParameterInputTextField(title: "Excluded Types")
  private lazy var includedPrimaryTypes = ParameterInputTextField(title: "Included Primary Types")
  private lazy var excludedPrimaryTypes = ParameterInputTextField(title: "Excluded Primary Types")
  private lazy var maxResultCount = ParameterInputTextField(title: "Max Result Count")
  private lazy var regionCode = ParameterInputTextField(title: "Region Code")

  private lazy var rankPreference: UISegmentedControl = {
    let rankPreference = UISegmentedControl(items: ["Popularity", "Distance"])
    rankPreference.selectedSegmentIndex = 0
    return rankPreference
  }()

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.isScrollEnabled = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private lazy var searchNearbyButton: UIButton = {
    let searchNearbyButton = UIButton()
    searchNearbyButton.setTitle("Search Nearby", for: .normal)
    searchNearbyButton.setTitleColor(.systemBlue, for: .normal)
    return searchNearbyButton
  }()

  private var tableViewHeightConstraint = NSLayoutConstraint()
  private var placeResults = [GMSPlace]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemBackground

    let placesButtonItem = UIBarButtonItem(
      title: "Places",
      style: .plain,
      target: self,
      action: nil)
    navigationItem.rightBarButtonItem = placesButtonItem
    navigationItem.rightBarButtonItem?.menu = setupPlacesMenu()

    setupScrollView()
    setupLocationTextFields()
    setupParametersTextFields()
    addSearchNearbyButton()
    setupTableView()
  }

  func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewStackView)

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      scrollViewStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      scrollViewStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      scrollViewStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
    ])
  }

  func setupLocationTextFields() {
    let stackView = UIStackView(arrangedSubviews: [latitudeField, longitudeField, radiusField])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.translatesAutoresizingMaskIntoConstraints = false
    scrollViewStackView.addArrangedSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
  }

  func setupParametersTextFields() {
    let stackView = UIStackView(arrangedSubviews: [
      includedTypes, excludedTypes, includedPrimaryTypes, excludedPrimaryTypes, maxResultCount,
      regionCode, rankPreference,
    ])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .fillEqually
    scrollViewStackView.addArrangedSubview(stackView)
  }

  func addSearchNearbyButton() {
    searchNearbyButton.addTarget(
      self, action: #selector(sendSearchNearbyRequest), for: .touchUpInside)
    scrollViewStackView.addArrangedSubview(searchNearbyButton)
  }

  @objc func sendSearchNearbyRequest() {

    guard let latitudeText = latitudeField.text, let longitudeText = longitudeField.text,
      let radiusText = radiusField.text
    else {
      showError("One or more of the text fields are invalid.")
      return
    }

    guard let latitude = Double(latitudeText), let longitude = Double(longitudeText),
      let radius = Double(radiusText)
    else {
      showError("One or more of the text fields are invalid")
      return
    }

    let circularRestriction = GMSPlaceCircularLocationOption(
      CLLocationCoordinate2DMake(latitude, longitude), radius)
    let request = GMSPlaceSearchNearbyRequest(
      locationRestriction: circularRestriction,
      placeProperties: [GMSPlaceProperty.name.rawValue, GMSPlaceProperty.coordinate.rawValue])
    request.includedTypes = splitStringToArray(string: includedTypes.textField.text)
    request.excludedTypes = splitStringToArray(string: excludedTypes.textField.text)
    request.includedPrimaryTypes = splitStringToArray(string: includedPrimaryTypes.textField.text)
    request.excludedPrimaryTypes = splitStringToArray(string: excludedPrimaryTypes.textField.text)
    request.maxResultCount = Int(maxResultCount.textField.text ?? "") ?? 20
    request.rankPreference = getRankPreference()
    request.regionCode = regionCode.textField.text

    GMSPlacesClient.shared().searchNearby(with: request) { [weak self] placeResults, error in
      guard let self else { return }

      guard let placeResults, error == nil else {
        if let error {
          self.showError(error.localizedDescription)
        }
        return
      }
      self.placeResults = placeResults
      self.tableView.reloadData()
      tableViewHeightConstraint.constant = tableView.contentSize.height + 32
    }
  }

  func setupTableView() {
    scrollView.addSubview(tableView)
    tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: scrollViewStackView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: scrollViewStackView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: scrollViewStackView.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      tableViewHeightConstraint,
    ])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placeResults.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
    let place = placeResults[indexPath.row]
    cell.textLabel?.text = place.name
    cell.detailTextLabel?.text = String(
      "Coordinates: \(place.coordinate.latitude), \(place.coordinate.longitude)")
    return cell
  }

  func setupPlacesMenu() -> UIMenu {
    let actionHandler: UIActionHandler = { action in
      if action.title == self.googleMTV {
        self.latitudeField.text = self.googleMTVLatitude
        self.longitudeField.text = self.googleMTVLongitude
      } else if action.title == self.googleSunnyvale {
        self.latitudeField.text = self.googleSunnyvaleLatitude
        self.longitudeField.text = self.googleSunnyvaleLongitude
      } else if action.title == self.googleSanFrancisco {
        self.latitudeField.text = self.googleSanFranciscoLatitude
        self.longitudeField.text = self.googleSanFranciscoLongitude
      }
    }
    let menuElements = [
      UIAction(title: googleMTV, handler: actionHandler),
      UIAction(title: googleSunnyvale, handler: actionHandler),
      UIAction(title: googleSanFrancisco, handler: actionHandler),
    ]
    let menu = UIMenu(title: "Places", children: menuElements)
    return menu
  }

  func showError(_ errorMessage: String) {
    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }

  func splitStringToArray(string: String?) -> [String] {
    guard var string = string else {
      return []
    }

    string.removeAll(where: { $0.isWhitespace })
    var stringComponents = string.lowercased().components(separatedBy: ",")
    stringComponents.removeAll(where: { $0.isEmpty })

    return stringComponents
  }

  func getRankPreference() -> GMSPlaceSearchNearbyRankPreference {
    if rankPreference.selectedSegmentIndex == 1 {
      return .distance
    } else {
      return .popularity
    }
  }
}

extension SearchNearbyViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
