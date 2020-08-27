//
//  CloudBasedMapStylingViewController.m
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

#import "CloudBasedMapStylingViewController.h"
@import GoogleMaps;

@interface CloudBasedMapStylingViewController ()

@end

@implementation CloudBasedMapStylingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // [START maps_cloud_based_map_styling_init]
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.0169
                                                          longitude:-122.336471
                                                               zoom:12];
  GMSMapID *mapID = [GMSMapID mapIDWithIdentifier:@"<YOUR MAP ID>"];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero mapID:mapID camera:camera];
  self.view = mapView;
  // [END maps_cloud_based_map_styling_init]
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
