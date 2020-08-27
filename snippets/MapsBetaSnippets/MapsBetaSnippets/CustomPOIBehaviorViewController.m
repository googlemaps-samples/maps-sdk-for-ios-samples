//
//  CustomPOIBehaviorViewController.m
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

#import "CustomPOIBehaviorViewController.h"
@import GoogleMaps;

@interface CustomPOIBehaviorViewController ()

@end

@implementation CustomPOIBehaviorViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.0169
                                                          longitude:-122.336471
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = mapView;
  
  // [START maps_custom_poi_behavior_collision]
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(47.0169, -122.336471);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  marker.zIndex = 10;
  marker.collisionBehavior = GMSCollisionBehaviorOptionalAndHidesLowerPriority;
  marker.map = mapView;
  // [END maps_custom_poi_behavior_collision]
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
