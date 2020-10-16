//
//  GetStartedViewController.swift
//  PlacesSnippets
//
//  Created by Chris Arriola on 7/13/20.
//  Copyright © 2020 Google. All rights reserved.
//

// [START maps_places_ios_get_started]
import GooglePlaces
import UIKit

class GetStartedViewController : UIViewController {
  
  // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var addressLabel: UILabel!
  
  private var placesClient: GMSPlacesClient!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    placesClient = GMSPlacesClient.shared()
  }
  
  // Add a UIButton in Interface Builder, and connect the action to this function.
  @IBAction func getCurrentPlace(_ sender: UIButton) {
    let placeFields: GMSPlaceField = [.name, .formattedAddress]
    placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
      guard let strongSelf = self else {
        return
      }
      
      guard error == nil else {
        print("Current place error: \(error?.localizedDescription ?? "")")
        return
      }
      
      guard let place = placeLikelihoods?.first?.place else {
        strongSelf.nameLabel.text = "No current place"
        strongSelf.addressLabel.text = ""
        return
      }
      
      strongSelf.nameLabel.text = place.name
      strongSelf.addressLabel.text = place.formattedAddress
    }
  }
}
// [END maps_places_ios_get_started]
