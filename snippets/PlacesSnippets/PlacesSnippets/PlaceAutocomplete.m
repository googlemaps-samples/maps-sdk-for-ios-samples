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
#import "PlaceAutocomplete.h"
@import GooglePlaces;

@interface PlaceAutocomplete () <GMSAutocompleteViewControllerDelegate>

@end

@implementation PlaceAutocomplete

- (void)viewDidLoad {
  [super viewDidLoad];
  [self makeButton];
}

// Present the autocomplete view controller when the button is pressed.
- (void)autocompleteClicked {
  GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
  acController.delegate = self;

  // Specify the place data types to return.
  GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPlaceID);
  acController.placeFields = fields;

  // Specify a filter.
  GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
  filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
  acController.autocompleteFilter = filter;

  // Display the autocomplete view controller.
  [self presentViewController:acController animated:YES completion:nil];
}

// Add a button to the view.
- (void)makeButton{
  UIButton *btnLaunchAc = [UIButton buttonWithType:UIButtonTypeCustom];
  [btnLaunchAc addTarget:self
                  action:NSSelectorFromString(@"autocompleteClicked")
        forControlEvents:UIControlEventTouchUpInside];
  [btnLaunchAc setTitle:@"Launch autocomplete" forState:UIControlStateNormal];
  btnLaunchAc.frame = CGRectMake(5.0, 150.0, 300.0, 35.0);
  btnLaunchAc.backgroundColor = [UIColor blueColor];
  [self.view addSubview:btnLaunchAc];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
  [self dismissViewControllerAnimated:YES completion:nil];
  // Do something with the selected place.
  NSLog(@"Place name %@", place.name);
  NSLog(@"Place ID %@", place.placeID);
  NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
  // TODO: handle the error.
  NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
// [END maps_ios_dev_guides_place_autocomplete_fullscreen]

@interface PlaceAutocomplete2 : UIViewController <GMSAutocompleteResultsViewControllerDelegate>

@end

@implementation PlaceAutocomplete2

// [START maps_ios_dev_guides_place_autocomplete_results]
GMSAutocompleteResultsViewController *_resultsViewController;
UISearchController *_searchController;

- (void)viewDidLoad {
  [super viewDidLoad];

  // ...
  _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
  _resultsViewController.delegate = self;

  _searchController = [[UISearchController alloc]
                       initWithSearchResultsController:_resultsViewController];
  _searchController.searchResultsUpdater = _resultsViewController;

  // Put the search bar in the navigation bar.
  [_searchController.searchBar sizeToFit];
  self.navigationItem.titleView = _searchController.searchBar;

  // When UISearchController presents the results view, present it in
  // this view controller, not one further up the chain.
  self.definesPresentationContext = YES;

  // Prevent the navigation bar from being hidden when searching.
  _searchController.hidesNavigationBarDuringPresentation = NO;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(GMSPlace *)place {
    _searchController.active = NO;
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didFailAutocompleteWithError:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
  // TODO: handle the error.
  NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:(GMSAutocompleteResultsViewController *)resultsController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:(GMSAutocompleteResultsViewController *)resultsController {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
// [END maps_ios_dev_guides_place_autocomplete_results]

- (void)navBar {
  // [START maps_ios_dev_guides_place_autocomplete_nav_bar]
  self.navigationController.navigationBar.translucent = NO;
  _searchController.hidesNavigationBarDuringPresentation = NO;

  // This makes the view area include the nav bar even though it is opaque.
  // Adjust the view placement down.
  self.extendedLayoutIncludesOpaqueBars = YES;
  self.edgesForExtendedLayout = UIRectEdgeTop;
  // [END maps_ios_dev_guides_place_autocomplete_nav_bar]
}

@end

@interface PlaceAutocomplete3 : UIViewController

@end

@implementation PlaceAutocomplete3

// [START maps_ios_dev_guides_place_autocomplete_search_bar]
UISearchController *_searchController;

- (void)viewDidLoad {
  [super viewDidLoad];

  // ...

  // Add a search bar
  UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.0, 250, 50)];
  [subView addSubview:_searchController.searchBar];
  [_searchController.searchBar sizeToFit];
  [self.view addSubview:subView];
}
// [END maps_ios_dev_guides_place_autocomplete_search_bar]

@end

@interface PlaceAutocomplete4 : UIViewController

@end

@implementation PlaceAutocomplete4

UISearchController *_searchController;

// [START maps_ios_dev_guides_place_autocomplete_search_bar_popover]
- (void)viewDidLoad {
  [super viewDidLoad];

  // ...

  // Add the search bar to the right of the nav bar,
  // use a popover to display the results.
  // Set an explicit size as we don't want to use the entire nav bar.
  _searchController.searchBar.frame = CGRectMake(0, 0, 250.0f, 44.0f);
  self.navigationItem.rightBarButtonItem =
  [[UIBarButtonItem alloc] initWithCustomView:_searchController.searchBar];

  // When UISearchController presents the results view, present it in
  // this view controller, not one further up the chain.
  self.definesPresentationContext = YES;

  // Keep the navigation bar visible.
  _searchController.hidesNavigationBarDuringPresentation = NO;

  _searchController.modalPresentationStyle = UIModalPresentationPopover;
}
// [END maps_ios_dev_guides_place_autocomplete_search_bar_popover]

- (void)styling {
  // [START maps_ios_dev_guides_place_autocomplete_appearance]
  UITextField *textField = [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]];
  [textField setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]}];
  // [END maps_ios_dev_guides_place_autocomplete_appearance]

  // [START maps_ios_dev_guides_place_autocomplete_appearance2]
  // Define some colors.
  UIColor *darkGray = [UIColor darkGrayColor];
  UIColor *lightGray = [UIColor lightGrayColor];

  // Navigation bar background.
  [[UINavigationBar appearance] setBarTintColor:darkGray];
  [[UINavigationBar appearance] setTintColor:lightGray];

  // Color of typed text in the search bar.
  NSDictionary *searchBarTextAttributes = @{
    NSForegroundColorAttributeName: lightGray,
    NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
  };
  UITextField *appearance = [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]];
  appearance.defaultTextAttributes = searchBarTextAttributes;

  // Color of the placeholder text in the search bar prior to text entry.
  NSDictionary *placeholderAttributes = @{
    NSForegroundColorAttributeName: lightGray,
    NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
  };

  // Color of the default search text.
  // NOTE: In a production scenario, "Search" would be a localized string.
  appearance.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search"
                                                                     attributes:placeholderAttributes];

  // Color of the in-progress spinner.
  [[UIActivityIndicatorView appearance] setColor:lightGray];

  // To style the two image icons in the search bar (the magnifying glass
  // icon and the 'clear text' icon), replace them with different images.
  [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_clear_x_high"]
                    forSearchBarIcon:UISearchBarIconClear
                              state:UIControlStateHighlighted];
  [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_clear_x"]
                    forSearchBarIcon:UISearchBarIconClear
                              state:UIControlStateNormal];
  [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_search"]
                      forSearchBarIcon:UISearchBarIconSearch
                              state:UIControlStateNormal];

  // Color of selected table cells.
  UIView *selectedBackgroundView = [[UIView alloc] init];
  selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
  UITableViewCell *tableViewCell = [UITableViewCell appearanceWhenContainedInInstancesOfClasses:@[[GMSAutocompleteViewController class]]];
  tableViewCell.selectedBackgroundView = selectedBackgroundView;
  // [END maps_ios_dev_guides_place_autocomplete_appearance2]
}

@end
