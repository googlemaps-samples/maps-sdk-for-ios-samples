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

import Foundation
import Firebase
import GooglePlaces

/// A wrapper around Firebase which handles communication with databases and
/// synchronization with our in-app data models.
class DatabaseWrapper {

  /// Access the shared instance of the Database.
  static let sharedInstance = DatabaseWrapper()

  private let collectionRef: DatabaseReference
  private let placesRef: DatabaseReference

  let database = Database.database()

  private init() {
    // Create a reference to the collections Firebase DB (get the list of place collection titles).
    collectionRef = database.reference(withPath: "collections")

    // Create a reference to the places Firebase DB (get the list of places in a collection).
    placesRef = database.reference(withPath: "places")
  }

  /// Observe changes to the list of collections.
  ///
  ///  - param changeHandler The closure which is called whenever the list of collections is
  ///                        modified.
  func observeCollections(changeHandler: @escaping ([PlaceCollection]) -> ()) {
    collectionRef.observe(.value, with: { snapshot in
      var newItems: [PlaceCollection] = []
      for item in snapshot.children {
        let collectionItem = PlaceCollection(snapshot: item as! DataSnapshot)
        newItems.append(collectionItem)
      }

      changeHandler(newItems)
    })
  }

  /// Observe changes to the list of places for the specified collection.
  ///
  ///  - param collection The collection to monitor changes to.
  ///  - param changeHandler The closure which is called whenever the list of places for the
  ///                        specified collection is modified.
  func observePlaces(for collection: PlaceCollection, changeHandler: @escaping ([PlaceItem]) -> ()) {
    placesRef.child(collection.key).observe(.value, with: { snapshot in
      var newItems: [PlaceItem] = []
      for item in snapshot.children {
        let collectionItem = PlaceItem(snapshot: item as! DataSnapshot)
        newItems.append(collectionItem)
      }

      changeHandler(newItems)
    })
  }

  /// Delete the specified collection of places.
  func delete(_ itemKey: String) {
    // Remove the collection from the list.
    collectionRef.child(itemKey).removeValue()

    // Also remove the places for the collection.
    placesRef.child(itemKey).removeValue()
  }

  /// Delete the specified place.
  func delete(_ parentKey: String, itemKey: String) {
    // Remove the place from the collection.
    placesRef.child(parentKey).child(itemKey).removeValue()
  }

  /// Create a new collection with the specified name.
  func addCollection(named name: String) -> PlaceCollection {
    // Create a new entry in the database.
    let placeCollectionRef = collectionRef.childByAutoId()

    // Create the data for this entry and store it in the database.
    let placeCollection = PlaceCollection(key: placeCollectionRef.key, title: name)
    placeCollectionRef.setValue(placeCollection.toAnyObject())

    // Return the item which was added.
    return placeCollection
  }

  /// Add a place to the specified collection.
  func add(_ place: GMSPlace, to collection: PlaceCollection) -> PlaceItem {
    // Create a new entry in the database.
    let placeItemRef = placesRef.child(collection.key).childByAutoId()

    // Create the data for this entry and store it in the database.
    let placeItem = PlaceItem(name: place.name, placeId: place.placeID, key: placeItemRef.key)
    placeItemRef.setValue(placeItem.toAnyObject())

    // Return the item which was added.
    return placeItem
  }

  /// Update the values associated with the specified collection.
  func update(_ collection: PlaceCollection) {
    // Update the values for this collection.
    collectionRef.child(collection.key).updateChildValues(collection.toAnyObject())
  }
}
