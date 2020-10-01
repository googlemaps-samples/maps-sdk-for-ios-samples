// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


// [START maps_ios_dev_guides_place_autocomplete_fullscreen]
import GooglePlaces

class PlaceAutocomplete: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    makeButton()
  }

  // Present the Autocomplete view controller when the button is pressed.
  @objc func autocompleteClicked(_ sender: UIButton) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self

    // Specify the place data types to return.
    let fields: GMSPlaceField = GMSPlaceField(
      rawValue:GMSPlaceField.name.rawValue | GMSPlaceField.placeID.rawValue
    )!
    autocompleteController.placeFields = fields

    // Specify a filter.
    let filter = GMSAutocompleteFilter()
    filter.type = .address
    autocompleteController.autocompleteFilter = filter

    // Display the autocomplete view controller.
    present(autocompleteController, animated: true, completion: nil)
  }

  // Add a button to the view.
  func makeButton() {
    let btnLaunchAc = UIButton(frame: CGRect(x: 5, y: 150, width: 300, height: 35))
    btnLaunchAc.backgroundColor = .blue
    btnLaunchAc.setTitle("Launch autocomplete", for: .normal)
    btnLaunchAc.addTarget(self, action: #selector(autocompleteClicked), for: .touchUpInside)
    self.view.addSubview(btnLaunchAc)
  }
}

extension PlaceAutocomplete: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: \(String(describing: place.name))")
    print("Place ID: \(place.placeID ?? "unknown")")
    print("Place attributions: \(String(describing: place.attributions))")
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
// [END maps_ios_dev_guides_place_autocomplete_fullscreen]

class PlaceAutocomplete2: UIViewController, GMSAutocompleteResultsViewControllerDelegate {

  // [START maps_ios_dev_guides_place_autocomplete_results]
  var resultsViewController: GMSAutocompleteResultsViewController!
  var searchController: UISearchController!
  var resultView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    resultsViewController = GMSAutocompleteResultsViewController()
    resultsViewController.delegate = self

    searchController = UISearchController(searchResultsController: resultsViewController)
    searchController.searchResultsUpdater = resultsViewController

    // Put the search bar in the navigation bar.
    searchController.searchBar.sizeToFit()
    navigationItem.titleView = searchController?.searchBar

    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    definesPresentationContext = true

    // Prevent the navigation bar from being hidden when searching.
    searchController.hidesNavigationBarDuringPresentation = false
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
    searchController.isActive = false
    // Do something with the selected place.
    print("Place name: \(String(describing: place.name))")
    print("Place address: \(String(describing: place.formattedAddress))")
    print("Place attributions: \(String(describing: place.attributions))")
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  // [END maps_ios_dev_guides_place_autocomplete_results]

  func navBar() {
    // [START maps_ios_dev_guides_place_autocomplete_nav_bar]
    navigationController?.navigationBar.isTranslucent = false
    searchController.hidesNavigationBarDuringPresentation = false

    // This makes the view area include the nav bar even though it is opaque.
    // Adjust the view placement down.
    self.extendedLayoutIncludesOpaqueBars = true
    self.edgesForExtendedLayout = .top
    // [END maps_ios_dev_guides_place_autocomplete_nav_bar]
  }
}

class PlaceAutocomplete3: UIViewController {
  // [START maps_ios_dev_guides_place_autocomplete_search_bar]
  var searchController: UISearchController!

  override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))

    subView.addSubview((searchController?.searchBar)!)
    view.addSubview(subView)
    searchController?.searchBar.sizeToFit()
  }
  // [END maps_ios_dev_guides_place_autocomplete_search_bar]
}

class PlaceAutocomplete4: UIViewController {

  var searchController: UISearchController!

  // [START maps_ios_dev_guides_place_autocomplete_search_bar_popover]
  override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    // Add the search bar to the right of the nav bar,
    // use a popover to display the results.
    // Set an explicit size as we don't want to use the entire nav bar.
    searchController.searchBar.frame = (CGRect(x: 0, y: 0, width: 250.0, height: 44.0))
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    definesPresentationContext = true

    // Keep the navigation bar visible.
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.modalPresentationStyle = .popover
  }
  // [END maps_ios_dev_guides_place_autocomplete_search_bar_popover]

  func styling() {
    // [START maps_ios_dev_guides_place_autocomplete_appearance]
    let textField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    textField.defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.green]
    // [END maps_ios_dev_guides_place_autocomplete_appearance]

    // [START maps_ios_dev_guides_place_autocomplete_appearance2]
    // Define some colors.
    let darkGray = UIColor.darkGray
    let lightGray = UIColor.lightGray

    // Navigation bar background.
    let navBarAppearance = UINavigationBar.appearance()
    navBarAppearance.barTintColor = darkGray
    navBarAppearance.tintColor = lightGray

    // Color of typed text in the search bar.
    let searchBarTextAttributes = [
      NSAttributedString.Key.foregroundColor : lightGray,
      NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)
    ]
    let appearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    appearance.defaultTextAttributes = searchBarTextAttributes

    // Color of the placeholder text in the search bar prior to text entry.
    let placeholderAttributes = [
      NSAttributedString.Key.foregroundColor: lightGray,
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)
    ]

    // Color of the default search text.
    // NOTE: In a production scenario, "Search" would be a localized string.
    appearance.attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)

    // Color of the in-progress spinner.
    UIActivityIndicatorView.appearance().color = lightGray

    // To style the two image icons in the search bar (the magnifying glass
    // icon and the 'clear text' icon), replace them with different images.
    UISearchBar.appearance().setImage(
      UIImage(named: "custom_clear_x_high"), for: .clear, state: .highlighted
    )
    UISearchBar.appearance().setImage(
      UIImage(named: "custom_clear_x"), for: .clear, state: .normal
    )
    UISearchBar.appearance().setImage(
      UIImage(named: "custom_search"), for: .search, state: .normal
    )

    // Color of selected table cells.
    let selectedBackgroundView = UIView()
    selectedBackgroundView.backgroundColor = lightGray
    let tableViewCell = UITableViewCell.appearance(whenContainedInInstancesOf: [GMSAutocompleteViewController.self])
    tableViewCell.selectedBackgroundView = selectedBackgroundView
    // [END maps_ios_dev_guides_place_autocomplete_appearance2]
  }
}
