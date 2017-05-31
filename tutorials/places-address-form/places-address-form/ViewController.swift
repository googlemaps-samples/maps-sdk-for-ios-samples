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

class ViewController: UIViewController {

  // Declare UI elements.
  @IBOutlet weak var address_line_1: UITextField!
  @IBOutlet weak var address_line_2: UITextField!
  @IBOutlet weak var city: UITextField!
  @IBOutlet weak var state: UITextField!
  @IBOutlet weak var postal_code_field: UITextField!
  @IBOutlet weak var country_field: UITextField!
  @IBOutlet weak var button: UIButton!

  // Declare variables to hold address form values.
  var street_number: String = ""
  var route: String = ""
  var neighborhood: String = ""
  var locality: String = ""
  var administrative_area_level_1: String = ""
  var country: String = ""
  var postal_code: String = ""
  var postal_code_suffix: String = ""

  // Present the Autocomplete view controller when the user taps the search field.
  @IBAction func autocompleteClicked(_ sender: UIButton) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self

    // Set a filter to return only addresses.
    let addressFilter = GMSAutocompleteFilter()
    addressFilter.type = .address
    autocompleteController.autocompleteFilter = addressFilter

    present(autocompleteController, animated: true, completion: nil)
  }

  // Populate the address form fields.
  func fillAddressForm() {
    address_line_1.text = street_number + " " + route
    city.text = locality
    state.text = administrative_area_level_1
    if postal_code_suffix != "" {
      postal_code_field.text = postal_code + "-" + postal_code_suffix
    } else {
      postal_code_field.text = postal_code
    }
    country_field.text = country

    // Clear values for next time.
    street_number = ""
    route = ""
    neighborhood = ""
    locality = ""
    administrative_area_level_1  = ""
    country = ""
    postal_code = ""
    postal_code_suffix = ""
  }

}

extension ViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    // Print place info to the console.
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")

    // Get the address components.
    if let addressLines = place.addressComponents {
      // Populate all of the address fields we can find.
      for field in addressLines {
        switch field.type {
        case kGMSPlaceTypeStreetNumber:
          street_number = field.name
        case kGMSPlaceTypeRoute:
          route = field.name
        case kGMSPlaceTypeNeighborhood:
          neighborhood = field.name
        case kGMSPlaceTypeLocality:
          locality = field.name
        case kGMSPlaceTypeAdministrativeAreaLevel1:
          administrative_area_level_1 = field.name
        case kGMSPlaceTypeCountry:
          country = field.name
        case kGMSPlaceTypePostalCode:
          postal_code = field.name
        case kGMSPlaceTypePostalCodeSuffix:
          postal_code_suffix = field.name
        // Print the items we aren't using.
        default:
          print("Type: \(field.type), Name: \(field.name)")
        }
      }
    }

    // Call custom function to populate the address form.
    fillAddressForm()

    // Close the autocomplete widget.
    self.dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Show the network activity indicator.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  // Hide the network activity indicator.
  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
}
