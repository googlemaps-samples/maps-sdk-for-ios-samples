//
//  GetStartedViewController.m
//  PlacesSnippets
//
//  Created by Chris Arriola on 7/13/20.
//  Copyright © 2020 Google. All rights reserved.
//

// [START maps_places_ios_get_started]
#import "GetStartedViewController.h"
@import GooglePlaces;

@interface GetStartedViewController ()
// Add a pair of UILabels in Interface Builder and connect the outlets to these variables
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@end

@implementation GetStartedViewController {
  GMSPlacesClient *_placesClient;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _placesClient = [GMSPlacesClient sharedClient];
}

// Add a pair of UILabels in Interface Builder and connect the outlets to these variables.
- (IBAction)getCurrentPlace:(UIButton *)sender {
  GMSPlaceField placeFields = (GMSPlaceFieldName | GMSPlaceFieldFormattedAddress);
  
  __weak typeof(self) weakSelf = self;
  [_placesClient findPlaceLikelihoodsFromCurrentLocationWithPlaceFields:placeFields callback:^(NSArray<GMSPlaceLikelihood *> * _Nullable likelihoods, NSError * _Nullable error) {
    __typeof__(self) strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    
    if (error != nil) {
      NSLog(@"An error occurred %@", [error localizedDescription]);
      return;
    }
    
    GMSPlace *place = likelihoods.firstObject.place;
    if (place == nil) {
      strongSelf.nameLabel.text = @"No current place";
      strongSelf.addressLabel.text = @"";
      return;
    }
    
    strongSelf.nameLabel.text = place.name;
    strongSelf.addressLabel.text = place.formattedAddress;
  }];
}

@end
// [END maps_places_ios_get_started]
