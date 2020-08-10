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
import GoogleMaps
import GooglePlaces

class LocationImageGenerator {
    
    /// This should be the dimension of the image generated, regardless of the iPhone model.
    private let dim: Double = 110
    
    // MARK: Image lookup and placement methods
    
    /// Checks to see if a location has an image and if it does, calls another method which sets the image appropriately
    ///
    /// - Parameters:
    ///   - placeId: The placeId of the location we wish to find an image of.
    ///   - localMarker: The marker that we want to set the image on.
    ///   - imageView: The image view that we want to set the image on.
    ///   - select: Indicates if we want the image on the image view; if this is false, tapped should be true.
    ///   - tapped: Indicates if we want the image on the GMSMarker; if this is false, select should be true.
    ///   - width: The width of the image; it is set to default at 110, found via trial/error to be good for all phone sizes.
    ///   - height: The height of the image; it is set to default at 110, found via trial/error to be good for all phone sizes.
    func viewImage(
        placeId: String,
        localMarker: GMSMarker,
        imageView: UIImageView,
        select: Bool = false,
        tapped: Bool = true,
        width: Int = 110,
        height: Int = 110
    ) {
        let placesClient: GMSPlacesClient = GMSPlacesClient.shared()
        let fields: GMSPlaceField = .photos
        placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil,
                                callback: {
            (place: GMSPlace?, error: Error?) in
            guard error == nil else {
                print("Some error occured here: \(error?.localizedDescription ?? "")")
                return
            }
            guard place != nil else {
                print("The location is nil or does not exist: \(error?.localizedDescription ?? "")")
                return
            }
            guard let place = place else {
                print("Error loading place metadata: \(error?.localizedDescription ?? "")")
                return
            }
            guard place.photos != nil else {
                if !select {
                    localMarker.icon = UIImage(systemName: "eye.slash.fill")
                    localMarker.icon?.withTintColor(.black)
                } else {
                    imageView.image = UIImage(systemName: "eye.slash.fill")
                }
                return
            }
            guard place.photos?.count ?? 0 > 0 else {
                print("There is no place photo data: \(error?.localizedDescription ?? "")")
                return
            }
            guard let photoMetadata = place.photos?[0] else {
                print("There is no photo data for location: \(error?.localizedDescription ?? "")")
                return
            }
            self.loadImage(
                photoMetadata: photoMetadata,
                placesClient: placesClient,
                localMarker: localMarker,
                imageView: imageView,
                select: select,
                tapped: tapped,
                width: width,
                height: height
            )
        })
    }
    
    /// Places the found image onto the card or marker
    ///
    /// - Parameters:
    ///   - placesClient: The GMSPlacesClient instance that loads the picture information.
    ///   - photoMetadata: The details about the photo needed.
    ///   - localMarker: The marker that we want to set the image on.
    ///   - imageView: The image view that we want to set the image on.
    ///   - select: Indicates if we want the image on the image view; if this is false, tapped should be true.
    ///   - tapped: Indicates if we want the image on the GMSMarker; if this is false, select should be true.
    ///   - width: The width of the image; it is set to default at 110.
    ///   - height: The height of the image; it is set to default at 110.
    func loadImage(
        photoMetadata: GMSPlacePhotoMetadata,
        placesClient: GMSPlacesClient,
        localMarker: GMSMarker,
        imageView: UIImageView,
        select: Bool = false,
        tapped: Bool = true,
        width: Int = 110,
        height: Int = 110
    ) {
        placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
            guard error == nil else {
                print("Some error occured: \(error?.localizedDescription ?? "")")
                return
            }
            let size = select ? CGSize(width: self.dim, height: self.dim) : CGSize(
                width: width,
                height: height
            )
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
            photo?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            let finalImage = select ? UIGraphicsGetImageFromCurrentImageContext()! :
                newImage.opac(alpha: 0.7)
            localMarker.icon = finalImage?.circleMask
            imageView.image = finalImage
            UIGraphicsEndImageContext()
        })
    }
}
