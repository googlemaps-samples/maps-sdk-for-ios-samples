/* Copyright (c) 2020 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import GooglePlaces
import GoogleMaps

class OverlayController {
    
    private var overlays = [GMSCircle]()
    private var lat: Double = 0.0
    private var long: Double = 0.0
    
    // MARK: Methods to get the placeID from a set of coordinates
    
    /// Searches an API for the entire data JSON file based on the lat and long values
    ///
    /// - Parameter completion: The completion handler.
    func fetchData(completion: @escaping ([String : Any]?, Error?) -> Void) {
        var apiKey: String = ApiKeys.mapsAPI
        let url =  "https://maps.googleapis.com/maps/api/geocode/json?&latlng=\(lat),\(long)&key="
        let search = URL(string: url + apiKey)!
        let task = URLSession.shared.dataTask(with: search) { (data, response, error) in
            guard let data = data else { return }
            do {
                if let array = try JSONSerialization.jsonObject(
                    with: data,
                    options: .allowFragments
                    ) as? [String : Any] {
                    completion(array, nil)
                }
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    /// Finds and parses data to extract a placeId from a set of coordinates and sends the appropriate data to the completion handler
    ///
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    ///   - completion: The completion handler.
    func geocode(
        latitude: Double,
        longitude: Double,
        completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?, _ pid: String) -> Void
    ) {
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(
                latitude: latitude,
                longitude: longitude
            )
        ) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(nil, error, "")
                return
            }
            self.lat = latitude
            self.long = longitude
            var ans: String = ""
            self.fetchData { (dict, error) in
                let convert = String(describing: dict?["results"])
                var counter: Int = 0
                
                // I want to find the key "place_id" somewhere in the JSON file
                var characters = [Character]()
                let search = "place_id"
                for letter in search {
                    characters.append(letter)
                }
                var startPlaceId: Bool = false
                for ch in convert {
                    if !startPlaceId {
                        
                        // Counter resembles the index of the "place_id" we are currently looking
                        // for; if the character matches, then counter is incremented
                        if ch == characters[counter] {
                            counter += 1
                        } else {
                            counter = 0
                            if ch == "p" {
                                counter = 1
                            }
                        }
                        
                        // If counter's length is equal to the length of "place_id," we've found it
                        if counter >= characters.count {
                            startPlaceId = true
                        }
                    } else {

                        // Once we've found "place_id," we want to build the actual place_id, so we
                        // need to ignore the punctuation
                        if ch == ":" {
                            continue
                        } else if ch == ";" {
                            break
                        } else {
                            ans += String(ch)
                        }
                    }
                }
                completion(placemark, nil, ans)
            }
        }
    }
    
    // MARK: - Draw and erase functions
    
    /// Draws a circle on a map
    ///
    /// - Parameters:
    ///   - mapView: The mapView to draw on.
    ///   - darkModeToggle: If on, the color of the circle should be white; otherwise, the color of the circle should be black.
    ///   - coord: The coordinates of the center of the circle.
    ///   - rad: The radius of the circle.
    func drawCircle(
        mapView: GMSMapView,
        darkModeToggle: Bool,
        coord: CLLocationCoordinate2D,
        rad: Double = 2000
    ) {
        let circle = GMSCircle()
        circle.map = nil
        circle.position = coord
        circle.radius = rad
        circle.fillColor = .clear
        circle.strokeColor = darkModeToggle ? .white : .black
        circle.strokeWidth = 3.4
        circle.map = mapView
        overlays.append(circle)
    }
    
    /// Clears all overlays created (for now, the only possible overlay is the circle)
    func clear() {
        for x in overlays {
            x.map = nil
        }
    }
}
