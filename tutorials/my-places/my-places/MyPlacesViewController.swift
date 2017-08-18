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

/// A ViewController which displays a list of place collections.
/// Users can add and delete place collections here.
class MyPlacesViewController: UIViewController {

  @IBOutlet weak var collectionTable: UITableView!

  // The selected collection to pass from the tableView delegate method
  // to the controller presented by segue.
  var selectedCollection: PlaceCollection?

  // Array to hold the list of collections.
  var items: [PlaceCollection] = []

  // Cell reuse id (enables reuse of cells when they scroll out of view).
  let cellReuseIdentifier = "cell"

  override func viewDidLoad() {
    super.viewDidLoad()

    // Register the table view cell class and its reuse id.
    collectionTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

    // Delegate method and data source for the table view.
    collectionTable.delegate = self
    collectionTable.dataSource = self

    // Populate the table with the list of place collections,
    // and respond to changes in the database.
    DatabaseWrapper.sharedInstance.observeCollections { newCollections in
      self.items = newCollections
      self.collectionTable.reloadData()
    }
  }

  // Create a new collection.
  @IBAction func addNewCollection(_ sender: Any) {
    let nameEditor = NameEditor.create { collectionName in
      if let collectionName = collectionName {
        let newCollection = DatabaseWrapper.sharedInstance.addCollection(named: collectionName)

        self.edit(newCollection)
      }
    }

    present(nameEditor, animated: true, completion: nil)
  }

  // Edit the selected collection.
  func edit(_ collection: PlaceCollection) {
    // Store the selected collection so it can be accessed in prepare(for:sender:)
    selectedCollection = collection

    performSegue(withIdentifier: "segueToEdit", sender: self)
  }

  // If a collection was selected, pass the id to the new view controller.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "segueToEdit" {
      if let nextViewController = segue.destination as? PlaceCollectionViewController {
        nextViewController.collection = selectedCollection

        // Reset this to nil for the next time.
        selectedCollection = nil
      }
    }
  }
}

// Delegates for UITableView
extension MyPlacesViewController: UITableViewDelegate {

  // Respond when a user taps a table cell.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    edit(items[indexPath.row])
  }

  // Handle deletion of an item.
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      DatabaseWrapper.sharedInstance.delete(items[indexPath.row].key);
    }
  }
}

// Delegates for UITableViewDataSource
extension MyPlacesViewController: UITableViewDataSource {
  // Get the number of rows from the data source.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  // Create a cell for each table view row.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Create a new cell if needed, or reuse an old one.
    let cell = collectionTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
    let collectionItem = items[indexPath.row]

    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    cell.textLabel?.text = collectionItem.title

    return cell
  }
}
