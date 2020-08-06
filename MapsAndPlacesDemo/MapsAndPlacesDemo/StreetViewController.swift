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

class StreetViewController: UIViewController {
    
    /// Button to trigger going back to main screen
    @IBOutlet private weak var backButton: UIButton!
    
    /// The coordinate that the panoramic view should show
    private var coord = CLLocationCoordinate2D()
    
    // MARK: View controller lifecycle methods
    
    /// Setup and calls showMap
    override func viewDidLoad() {
        super.viewDidLoad()
        showMap()
    }
    
    /// Returns to main screen
    @IBAction private func menu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Panorama related functions
    
    /// Shows the panoramic view
    private func showMap() {
        let panoView = GMSPanoramaView.panorama(
            withFrame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: view.frame.height
            ),
            nearCoordinate: coord
        )
        self.view.addSubview(panoView)
        panoView.moveNearCoordinate(coord)
        self.view.bringSubviewToFront(backButton)
    }
    
    /// Sets the coordinates to the new value passed in; this function is called from GoogleDemoApplicationsMainViewController
    ///
    /// - Parameters:
    ///   - resultsController: The connected resultsController that the option was chosen from.
    ///   - error: The error that occured
    public func setValues(newCoord: CLLocationCoordinate2D) {
        coord = newCoord
    }
}
