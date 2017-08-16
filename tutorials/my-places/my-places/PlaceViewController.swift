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

/// A ViewController which displays the details for the selected place.
class PlaceViewController: UIViewController {

  // The place this view controller is showing.
  var place: PlaceItem!
  var placeDetails: GMSPlace!

  @IBOutlet weak var placeNameLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var attributionTextView: UITextView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var mapBarButton: UIBarButtonItem!

  let placesClient = GMSPlacesClient.shared()

  override func viewDidLoad() {
    super.viewDidLoad()

    print("Place ID: \(place.placeId)")

    lookupDetails()
  }

  // Fetch the place details when the user selects a place.
  func lookupDetails() {
    placesClient.lookUpPlaceID(place.placeId, callback: { (place, error) -> Void in
      if let error = error {
        print("Lookup place id query error: \(error.localizedDescription)")
        return
      }

      if let place = place {
        self.placeNameLabel.text = place.name
        self.addressLabel.text = place.formattedAddress
        self.phoneButton.setTitle(place.phoneNumber, for: .normal)
        self.placeDetails = place
      } else {
        print("No place details for \(self.place.placeId)")
      }
    })

    // Get metadata for photos belonging to the selected place.
    // The photos result returns metadata for up to 10 photos.
    placesClient.lookUpPhotos(forPlaceID: place.placeId, callback: { (photos, error) -> Void in
      if let error = error {
        print("Error retrieving photos: \(error.localizedDescription)")
        return
      } else {
        // If there are photos, call loadImage with the metadata for the first one.
        // The result ('photos') is an array of GMSPlacePhotoMetadata objects.
        if let firstPhoto = photos?.results.first {
          self.loadImage(for: firstPhoto)
        }
      }
    })
  }

  // Load the image in the UIImageView, and display the attribution text.
  func loadImage(for photoMetadata: GMSPlacePhotoMetadata) {
    placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
      if let error = error {
        print("Error loading photo metadata: \(error.localizedDescription)")
        return
      } else {
        // Display the first image and its attributions.
        self.imageView.image = photo;
        self.attributionTextView.attributedText = photoMetadata.attributions;
      }
    })
  }

  // Launch Google Maps, querying with the address of the selected place.
  @IBAction func launchMaps(_ sender: Any) {
    if let address = placeDetails.formattedAddress {
      let formattedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
      let placeUrl = URL(string: "https://maps.google.com?q=\(formattedAddress)&zoom=14")
      if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
        UIApplication.shared.open(placeUrl!, options: [:], completionHandler: nil)
      } else {
        print("Can't use https://maps.google.com.");
      }
    }
  }

  // Prompt the user to dial the phone number for the selected place.
  @IBAction func callPhone(_ sender: Any) {
    if let phoneNumber = placeDetails.phoneNumber {
      var formattedNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
      formattedNumber = formattedNumber.replacingOccurrences(of: " ", with: "")
      formattedNumber = formattedNumber.replacingOccurrences(of: "-", with: "")
      if let number = URL(string: "telprompt:\(formattedNumber)") {
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
        print(number)
      } else {
        print("There was a problem with the phone number.")
      }
    }
  }
}
