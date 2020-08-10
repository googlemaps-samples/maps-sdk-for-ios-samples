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
import MaterialComponents.MDCCard
import GoogleMaps

class PopUpViewController: UIViewController {

    /// A LocationImageController to access an image based on the location
    private let imageController = LocationImageGenerator()
    
    /// The PID of the location
    private var pid: String = ""
    
    /// A card to place everything on
    private var infoCard = MDCCard()
    
    /// The coordinates of the location
    private var coord = CLLocationCoordinate2D()
    
    /// Dark mode indicator
    private var darkMode = false
    
    // MARK: View controller lifecycle methods
    
    /// Creates up the popup and sets up the information
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the dimensions and offset with margins as a sixth of the width and height of the
        // phone; the offsets are calculated so there is 1 / 6 margins on both sides of the card
        // while the card itself takes 4 / 6 of the screen space
        let xOffset = view.frame.width / 6
        let yOffset = view.frame.height / 6
        let dim: CGFloat = 4 * (view.frame.width) / 6

        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        showAnimate()
        infoCard = MDCCard(frame: CGRect(x: xOffset, y: yOffset, width: dim, height: dim))
        let imageView = UIImageView()
        imageView.frame = CGRect(x: xOffset, y: yOffset, width: dim, height: dim * 2 / 3)
        imageController.viewImage(
            placeId: pid,
            localMarker: GMSMarker(),
            imageView: imageView,
            select: true
        )
        let infoText =  UITextView(
            frame: CGRect(
                x: xOffset,
                y: yOffset + imageView.frame.height,
                width: dim,
                height: dim / 6
            )
        )
        infoText.textColor = darkMode ? .white : .black
        infoText.backgroundColor = darkMode ? .black : .white
        infoText.text = "The current coordinates are (\(coord.latitude), \((coord.longitude)))."
        infoText.font = UIFont.systemFont(ofSize: 10)
        infoText.centerVertically()
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(
            x: xOffset,
            y: yOffset + imageView.frame.height + infoText.frame.height,
            width: dim,
            height: dim / 6
        )
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 1
        backButton.clipsToBounds = true
        backButton.backgroundColor = .systemTeal
        backButton.addTarget(self, action: #selector(removeAnimate), for: .touchUpInside)
        backButton.setTitle("Go Back", for: .normal)
        view.addSubview(infoCard)
        view.addSubview(imageView)
        view.sendSubviewToBack(infoCard)
        view.addSubview(backButton)
        view.bringSubviewToFront(backButton)
        view.addSubview(infoText)
    }
    
    /// Shows the popup view controller with an animation
    private func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    /// Dismisses the popup view controller
    @objc private func removeAnimate() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Setter methods
    
    /// Updates the instance variables to a new location
    ///
    /// - Parameters:
    ///   - newCoord: The new coordinates to represent.
    ///   - newPid: The new PID to represent.
    func update(newCoord: CLLocationCoordinate2D, newPid: String, setDarkMode: Bool) {
        coord = newCoord
        pid = newPid
        darkMode = setDarkMode
    }
}
