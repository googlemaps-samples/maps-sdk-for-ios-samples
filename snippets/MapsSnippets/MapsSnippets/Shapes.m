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



#import "Shapes.h"
@import GoogleMaps;

@implementation Shapes

GMSMapView *mapView;

- (void)polylines {
  // [START maps_ios_shapes_polylines]
  GMSMutablePath *path = [GMSMutablePath path];
  [path addCoordinate:CLLocationCoordinate2DMake(-33.85, 151.20)];
  [path addCoordinate:CLLocationCoordinate2DMake(-33.70, 151.40)];
  [path addCoordinate:CLLocationCoordinate2DMake(-33.73, 151.41)];
  GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
  // [END maps_ios_shapes_polylines]

  // [START maps_ios_shapes_polylines_map]
  GMSMutablePath *rectanglePath = [GMSMutablePath path];
  [rectanglePath addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];
  [rectanglePath addCoordinate:CLLocationCoordinate2DMake(37.45, -122.0)];
  [rectanglePath addCoordinate:CLLocationCoordinate2DMake(37.45, -122.2)];
  [rectanglePath addCoordinate:CLLocationCoordinate2DMake(37.36, -122.2)];
  [rectanglePath addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];

  GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
  rectangle.map = mapView;
  // [END maps_ios_shapes_polylines_map]

  // [START maps_ios_shapes_polylines_remove]
  [mapView clear];
  // [END maps_ios_shapes_polylines_remove]

  // [START maps_ios_shapes_polylines_modify]
  polyline.strokeColor = [UIColor blackColor];
  // [END maps_ios_shapes_polylines_modify]
}

- (void)customizePolyline {
  // [START maps_ios_shapes_polylines_customize]
  GMSMutablePath *path = [GMSMutablePath path];
  [path addLatitude:-37.81319 longitude:144.96298];
  [path addLatitude:-31.95285 longitude:115.85734];
  GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
  polyline.strokeWidth = 10.f;
  polyline.geodesic = YES;
  polyline.map = mapView;
  // [END maps_ios_shapes_polylines_customize]

  // [START maps_ios_shapes_polyline_customize_reference]
  polyline.strokeColor = [UIColor blueColor];
  // [END maps_ios_shapes_polyline_customize_reference]

  // [START maps_ios_shapes_polyline_customize_color]
  polyline.spans = @[[GMSStyleSpan spanWithColor:[UIColor redColor]]];
  // [END maps_ios_shapes_polyline_customize_color]

  // [START maps_ios_shapes_polyline_customize_color2]
  GMSStrokeStyle *solidRed = [GMSStrokeStyle solidColor:[UIColor redColor]];
  polyline.spans = @[[GMSStyleSpan spanWithStyle:solidRed]];
  // [END maps_ios_shapes_polyline_customize_color2]

  // [START maps_ios_shapes_polyline_stroke_color]
  polyline.strokeColor = [UIColor redColor];
  // [END maps_ios_shapes_polyline_stroke_color]

  // [START maps_ios_shapes_polyline_styles]
  // Create two styles: one that is solid blue, and one that is a gradient from red to yellow
  GMSStrokeStyle *solidBlue = [GMSStrokeStyle solidColor:[UIColor blueColor]];
  GMSStyleSpan *solidBlueSpan = [GMSStyleSpan spanWithStyle:solidBlue];
  GMSStrokeStyle *redYellow =
      [GMSStrokeStyle gradientFromColor:[UIColor redColor] toColor:[UIColor yellowColor]];
  GMSStyleSpan *redYellowSpan = [GMSStyleSpan spanWithStyle:redYellow];
  // [END maps_ios_shapes_polyline_styles]

  // [START maps_ios_shapes_polyline_styles_spans]
  polyline.spans = @[[GMSStyleSpan spanWithStyle:redYellow]];
  // [END maps_ios_shapes_polyline_styles_spans]

  // [START maps_ios_shapes_polyline_styles_spans_array]
  polyline.spans = @[[GMSStyleSpan spanWithStyle:solidRed],
                     [GMSStyleSpan spanWithStyle:solidRed],
                     [GMSStyleSpan spanWithStyle:redYellow]];
  // [END maps_ios_shapes_polyline_styles_spans_array]

  // [START maps_ios_shapes_polyline_styles_spans_segments]
  polyline.spans = @[[GMSStyleSpan spanWithStyle:solidRed segments:2],
                     [GMSStyleSpan spanWithStyle:redYellow segments:10]];
  // [END maps_ios_shapes_polyline_styles_spans_segments]

  // [START maps_ios_shapes_polyline_styles_spans_fractional]
  polyline.spans = @[[GMSStyleSpan spanWithStyle:solidRed segments:2.5],
                     [GMSStyleSpan spanWithColor:[UIColor grayColor]],
                     [GMSStyleSpan spanWithColor:[UIColor purpleColor] segments:0.75],
                     [GMSStyleSpan spanWithStyle:redYellow]];
  // [END maps_ios_shapes_polyline_styles_spans_fractional]

  // [START maps_ios_shapes_polyline_styles_spans_repeating_color]
  NSArray *styles = @[[GMSStrokeStyle solidColor:[UIColor whiteColor]],
                      [GMSStrokeStyle solidColor:[UIColor blackColor]]];
  NSArray *lengths = @[@100000, @50000];
  polyline.spans = GMSStyleSpans(polyline.path, styles, lengths, kGMSLengthRhumb);
  // [END maps_ios_shapes_polyline_styles_spans_repeating_color]
}

- (void)polygons {
  // [START maps_ios_shapes_polygon]
  // Create a rectangular path
  GMSMutablePath *rect = [GMSMutablePath path];
  [rect addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];
  [rect addCoordinate:CLLocationCoordinate2DMake(37.45, -122.0)];
  [rect addCoordinate:CLLocationCoordinate2DMake(37.45, -122.2)];
  [rect addCoordinate:CLLocationCoordinate2DMake(37.36, -122.2)];

  // Create the polygon, and assign it to the map.
  GMSPolygon *polygon = [GMSPolygon polygonWithPath:rect];
  polygon.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
  polygon.strokeColor = [UIColor blackColor];
  polygon.strokeWidth = 2;
  polygon.map = mapView;
  // [END maps_ios_shapes_polygon]

  // [START maps_ios_shapes_polygon_hollow]
  CLLocationCoordinate2D hydeParkLocation = CLLocationCoordinate2DMake(-33.87344, 151.21135);
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:hydeParkLocation
                                                             zoom:16];
  mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  NSString *hydePark = @"tpwmEkd|y[QVe@Pk@BsHe@mGc@iNaAKMaBIYIq@qAMo@Eo@@[Fe@DoALu@HUb@c@XUZS^ELGxOhAd@@ZB`@J^BhFRlBN\\BZ@`AFrATAJAR?rAE\\C~BIpD";
  NSString *archibaldFountain = @"tlvmEqq|y[NNCXSJQOB[TI";
  NSString *reflectionPool = @"bewmEwk|y[Dm@zAPEj@{AO";

  GMSPolygon *hollowPolygon = [[GMSPolygon alloc] init];
  hollowPolygon.path = [GMSPath pathFromEncodedPath:hydePark];
  hollowPolygon.holes = @[[GMSPath pathFromEncodedPath:archibaldFountain],
                    [GMSPath pathFromEncodedPath:reflectionPool]];
  hollowPolygon.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
  hollowPolygon.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
  hollowPolygon.strokeWidth = 2;
  hollowPolygon.map = mapView;
  // [END maps_ios_shapes_polygon_hollow]
}

- (void)circles {
  // [START maps_ios_shapes_circles]
  CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(37.35, -122.0);
  GMSCircle *circle = [GMSCircle circleWithPosition:circleCenter
                                           radius:1000];
  circle.map = mapView;
  // [END maps_ios_shapes_circles]

  // [START maps_ios_shapes_circles_customize]
  circle.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
  circle.strokeColor = [UIColor redColor];
  circle.strokeWidth = 5;
  // [END maps_ios_shapes_circles_customize]
}

@end
