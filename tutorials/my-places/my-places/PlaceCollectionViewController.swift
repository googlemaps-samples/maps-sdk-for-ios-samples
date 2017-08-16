/*
 * Copyright 2017 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GooglePlaces
import GooglePlacePicker

/// A ViewController which displays a list of places for the selected collection.
class PlaceCollectionViewController: UIViewController {

  @IBOutlet weak var placesTableView: UITableView!

  // Location manager and Places client.
  var locationManager = CLLocationManager()
  let placesClient = GMSPlacesClient.shared()

  // The current collection being displayed by this ViewController.
  var collection: PlaceCollection!

  // The selected place to pass from the tableView delegate method
  // to the controller presented by segue.
  var selectedPlace: PlaceItem?

  // Dictionary to hold the list of collections (name, id).
  var items: [PlaceItem] = []

  // Cell reuse id (enables reuse of cells when they scroll out of view).
  let cellReuseIdentifier = "cell"

  override func viewDidLoad() {
    super.viewDidLoad()

    // Register the table view cell class and its reuse id
    placesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

    // Delegate method and data source for the table view.
    placesTableView.delegate = self
    placesTableView.dataSource = self

    // Populate the table with the list of places for the selected collection,
    // and respond to changes in the database.
    DatabaseWrapper.sharedInstance.observePlaces(for: collection) { newPlaces in
      self.items = newPlaces
      self.placesTableView.reloadData()
    }

    // Show the title of the collection.
    title = collection.title
  }

  // Edit the name of the collection.
  @IBAction func editCollectionName(_ sender: Any) {
    let nameEditor = NameEditor.create(existingText: collection.title) { newTitle in
      if let newTitle = newTitle {
        self.collection.title = newTitle
        DatabaseWrapper.sharedInstance.update(self.collection)

        // Update the text label.
        self.title = newTitle
      }
    }

    present(nameEditor, animated: true, completion: nil)
  }

  // Handle user interaction with the Place Picker.
  @IBAction func pickPlace(_ sender: UIBarButtonItem) {
    // Request location permissions for the Place Picker.
    locationManager.requestWhenInUseAuthorization()

    let config = GMSPlacePickerConfig(viewport: nil)
    let placePicker = GMSPlacePickerViewController(config: config)
    placePicker.delegate = self

    self.present(placePicker, animated: true, completion: nil)
  }

  // Segue to the PlaceViewController when a place is selected.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToPlace" {
      if let nextViewController = segue.destination as? PlaceViewController {
        nextViewController.place = selectedPlace

        // Make sure to reset this for the next time this is called.
        selectedPlace = nil
      }
    }
  }
}

// Delegates for GMSPlacePickerViewController.
extension PlaceCollectionViewController: GMSPlacePickerViewControllerDelegate {

  // Update the collection with the user's chosen place.
  func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
    DatabaseWrapper.sharedInstance.add(place, to: self.collection)

    // Dismiss the place picker, as it cannot dismiss itself.
    viewController.dismiss(animated: true, completion: nil)
  }

  func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
    // Dismiss the place picker, as it cannot dismiss itself.
    viewController.dismiss(animated: true, completion: nil)

    print("No place selected")
  }

  func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
    print("Pick Place error: \(error.localizedDescription)")
  }

}

// Delegates for UITableView.
extension PlaceCollectionViewController: UITableViewDelegate {

  // Respond when a user taps a table cell.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedPlace = items[indexPath.row]

    self.performSegue(withIdentifier: "segueToPlace", sender: self)
    print("You selected: \(selectedPlace?.name), Place ID: \(selectedPlace?.placeId)")
  }

  // Handle deletion of an item.
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      DatabaseWrapper.sharedInstance.delete(collection.key, itemKey: items[indexPath.row].key)
    }
  }
}

// Delegates for UITableViewDataSource.
extension PlaceCollectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    // Create a new cell if needed, or reuse an old one.
    let cell = self.placesTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
    let collectionItem = items[indexPath.row]

    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    cell.textLabel?.text = collectionItem.name

    return cell
  }
}
