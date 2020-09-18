//
//  MapsViewController.m
//  current-place-on-map
//
//  Created by Chris Arriola on 9/18/20.
//  Copyright © 2020 William French. All rights reserved.
//

#import "MapsViewController.h"
@import CoreLocation;
@import GooglePlaces;
@import GoogleMaps;

@interface MapsViewController ()

@end

@implementation MapsViewController {
  // [START maps_ios_current_place_declare_params]
  CLLocationManager *locationManager;
  CLLocation *currentLocation;
  GMSMapView *mapView;
  GMSPlacesClient *placesClient;
  float zoomLevel;
  // [END maps_ios_current_place_declare_params]
}

- (void)viewDidLoad {
  [super viewDidLoad];
  zoomLevel = 15.0;
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
