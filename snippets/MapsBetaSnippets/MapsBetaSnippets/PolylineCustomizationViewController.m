//
//  PolylineCustomizationViewController.m
//  MapsBetaSnippets
//
//  Created by Chris Arriola on 8/27/20.
//  Copyright © 2020 Google. All rights reserved.
//

#import "PolylineCustomizationViewController.h"
@import GoogleMaps;

@interface PolylineCustomizationViewController ()

@end

@implementation PolylineCustomizationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.0169
                                                          longitude:-122.336471
                                                               zoom:12];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = mapView;
  
  // [START maps_polyline_customization]
  GMSMutablePath *path = [GMSMutablePath path];
  [path addLatitude:-37.81319 longitude:144.96298];
  [path addLatitude:-31.95285 longitude:115.85734];
  GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
  GMSStrokeStyle *redWithStamp = [GMSStrokeStyle solidColor:[UIColor redColor]];

  UIImage *image = [UIImage imageNamed:@"imageFromBundleOrAsset"]; // Image could be from anywhere
  redWithStamp.stampStyle = [GMSTextureStyle textureStyleWithImage:image];

  GMSStyleSpan *span = [GMSStyleSpan spanWithStyle:redWithStamp];
  polyline.spans = @[span];
  polyline.map = mapView;
  // [END maps_polyline_customization]
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
