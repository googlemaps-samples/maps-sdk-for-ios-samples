let placeID = "ChIJV4k8_9UodTERU5KXbkYpSYs"

let properties: [GMSPlaceProperty] = [.name, .website]

let fetchPlaceRequest = FetchPlaceRequest(
        placeID: placeID,
        placeProperties: properties
      )

client.fetchPlace(with: fetchPlaceRequest, callback: {
  (place: GMSPlace?, error: Error?) in
  guard let place, error == nil else { return }
  print("Place found: \(place.name)")
})
