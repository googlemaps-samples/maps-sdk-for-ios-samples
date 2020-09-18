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

#import "PlacesViewController.h"

// [START maps_ios_current_place_tableviewdelegate]
@interface PlacesViewController () <UITableViewDataSource, UITableViewDelegate>
// [START_EXCLUDE]
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation PlacesViewController {
  // Cell reuse id (cells that scroll out of view can be reused).
  NSString *cellReuseIdentifier;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  cellReuseIdentifier = @"cell";
}
// [END_EXCLUDE]

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
}

#pragma mark - UITableViewDelegate

// Respond when a user selects a place.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedPlace = [self.likelyPlaces objectAtIndex:indexPath.row];
  [self performSegueWithIdentifier:@"unwindToMain" sender:self];
}

// Adjust cell height to only show the first five items in the table
// (scrolling is disabled in IB).
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return self.tableView.frame.size.height/5;
}

// Make table rows display at proper height if there are less than 5 items.
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  if (section == tableView.numberOfSections - 1) {
    return 1;
  }
  return 0;
}
// [END maps_ios_current_place_tableviewdelegate]

// [START maps_ios_current_place_tableviewdatasource]
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.likelyPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
}
@end
// [END maps_ios_current_place_tableviewdatasource]
