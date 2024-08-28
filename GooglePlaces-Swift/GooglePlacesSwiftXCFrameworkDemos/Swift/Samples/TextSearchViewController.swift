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

import GooglePlaces
import UIKit

class TextSearchViewController: AutocompleteBaseViewController,
  UITextFieldDelegate,
  UITableViewDelegate,
  UITableViewDataSource
{
  private let cellIdentifier = "TextSearchCellIdentifier"

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private lazy var textQueryField: UITextField = {
    let textQueryField = UITextField()
    textQueryField.delegate = self
    textQueryField.borderStyle = .roundedRect
    textQueryField.textColor = .label
    textQueryField.placeholder = "Enter Text Search Query"
    textQueryField.backgroundColor = .secondarySystemBackground
    textQueryField.translatesAutoresizingMaskIntoConstraints = false
    return textQueryField
  }()

  private var placeResults = [GMSPlace]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemBackground

    setupTextField()
    setupTableView()
  }

  func setupTextField() {
    view.addSubview(textQueryField)

    NSLayoutConstraint.activate([
      textQueryField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      textQueryField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      textQueryField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      textQueryField.heightAnchor.constraint(equalToConstant: 50),
    ])
  }

  func setupTableView() {
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: textQueryField.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let text = textField.text, text.count > 0, let autocompleteConfiguration else {
      return false
    }

    placeResults = []
    tableView.reloadData()
    tableView.isHidden = false

    let request = GMSPlaceSearchByTextRequest(
      textQuery: text,
      placeProperties: autocompleteConfiguration.placeProperties.map { $0.rawValue })
    // Coordinates of Googleplex, 1 kilometer radius
    request.locationBias = GMSPlaceCircularLocationOption(
      CLLocationCoordinate2DMake(37.4220604, -122.087809), 1000.0)
    let callback: GMSPlaceSearchByTextResultCallback = { [weak self] placeResults, error in
      guard let self, let placeResults, error == nil else {
        if let error {
          print(error.localizedDescription)
          self?.autocompleteDidFail(error)
        }
        return
      }

      self.placeResults = placeResults
      self.tableView.reloadData()
    }

    GMSPlacesClient.shared().searchByText(with: request, callback: callback)
    return true
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placeResults.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let place = placeResults[indexPath.row]
    cell.textLabel?.text = place.name
    cell.detailTextLabel?.text = place.formattedAddress
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let place = placeResults[indexPath.row]
    tableView.isHidden = true
    super.autocompleteDidSelectPlace(place)
  }

}
