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

#import "PlaceAutocompleteViewController.h"
@import GooglePlaces;
@import UIKit;

@interface PlaceAutocompleteViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate>

@end

@implementation PlaceAutocompleteViewController {
  UITableView *tableView;
  GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
  searchBar.delegate = self;
  
  [self.view addSubview:searchBar];
  
  tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
  tableDataSource.delegate = self;
  
  tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 44)];
  tableView.delegate = tableDataSource;
  tableView.dataSource = tableDataSource;
  
  [self.view addSubview:tableView];
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
  // Turn the network activity indicator off.
  UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
  
  // Reload table data.
  [tableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
  // Turn the network activity indicator on.
  UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
  
  // Reload table data.
  [tableView reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
  // Do something with the selected place.
  NSLog(@"Place name: %@", place.name);
  NSLog(@"Place address: %@", place.formattedAddress);
  NSLog(@"Place attributions: %@", place.attributions);
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
  // Handle the error
  NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
  return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  // Update the GMSAutocompleteTableDataSource with the search text.
  [tableDataSource sourceTextHasChanged:searchText];
}

@end
