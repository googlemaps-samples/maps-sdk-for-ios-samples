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


import GoogleMaps

class Shapes {

  var mapView: GMSMapView!

  func polylines() {
    // [START maps_ios_shapes_polylines]
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: -33.85, longitude: 151.20))
    path.add(CLLocationCoordinate2D(latitude: -33.70, longitude: 151.40))
    path.add(CLLocationCoordinate2D(latitude: -33.73, longitude: 151.41))
    let polyline = GMSPolyline(path: path)
    // [END maps_ios_shapes_polylines]

    // [START maps_ios_shapes_polylines_map]
    let rectanglePath = GMSMutablePath()
    rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
    rectanglePath.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.0))
    rectanglePath.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.2))
    rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.2))
    rectanglePath.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))

    let rectangle = GMSPolyline(path: path)
    rectangle.map = mapView
    // [END maps_ios_shapes_polylines_map]

    // [START maps_ios_shapes_polylines_remove]
    mapView.clear()
    // [END maps_ios_shapes_polylines_remove]

    // [START maps_ios_shapes_polylines_modify]
    polyline.strokeColor = .black
    // [END maps_ios_shapes_polylines_modify]
  }

  func customizePolyline() {
    // [START maps_ios_shapes_polylines_customize]
    let path = GMSMutablePath()
    path.addLatitude(-37.81319, longitude: 144.96298)
    path.addLatitude(-31.95285, longitude: 115.85734)
    let polyline = GMSPolyline(path: path)
    polyline.strokeWidth = 10.0
    polyline.geodesic = true
    polyline.map = mapView
    // [END maps_ios_shapes_polylines_customize]

    // [START maps_ios_shapes_polyline_customize_reference]
    polyline.strokeColor = .blue
    // [END maps_ios_shapes_polyline_customize_reference]

    // [START maps_ios_shapes_polyline_customize_color]
    polyline.spans = [GMSStyleSpan(color: .red)]
    // [END maps_ios_shapes_polyline_customize_color]

    // [START maps_ios_shapes_polyline_customize_color2]
    let solidRed = GMSStrokeStyle.solidColor(.red)
    polyline.spans = [GMSStyleSpan(style: solidRed)]
    // [END maps_ios_shapes_polyline_customize_color2]

    // [START maps_ios_shapes_polyline_stroke_color]
    polyline.strokeColor = .red
    // [END maps_ios_shapes_polyline_stroke_color]

    // [START maps_ios_shapes_polyline_styles]
    // Create two styles: one that is solid blue, and one that is a gradient from red to yellow
    let solidBlue = GMSStrokeStyle.solidColor(.blue)
    let solidBlueSpan = GMSStyleSpan(style: solidBlue)
    let redYellow = GMSStrokeStyle.gradient(from: .red, to: .yellow)
    let redYellowSpan = GMSStyleSpan(style: redYellow)
    // [END maps_ios_shapes_polyline_styles]

    // [START maps_ios_shapes_polyline_styles_spans]
    polyline.spans = [GMSStyleSpan(style: redYellow)]
    // [END maps_ios_shapes_polyline_styles_spans]

    // [START maps_ios_shapes_polyline_styles_spans_array]
    polyline.spans = [
      GMSStyleSpan(style: solidRed),
      GMSStyleSpan(style: solidRed),
      GMSStyleSpan(style: redYellow)
    ]
    // [END maps_ios_shapes_polyline_styles_spans_array]

    // [START maps_ios_shapes_polyline_styles_spans_segments]
    polyline.spans = [
      GMSStyleSpan(style: solidRed, segments:2),
      GMSStyleSpan(style: redYellow, segments:10)
    ]
    // [END maps_ios_shapes_polyline_styles_spans_segments]

    // [START maps_ios_shapes_polyline_styles_spans_fractional]
    polyline.spans = [
      GMSStyleSpan(style: solidRed, segments: 2.5),
      GMSStyleSpan(color: .gray),
      GMSStyleSpan(color: .purple, segments: 0.75),
      GMSStyleSpan(style: redYellow)
    ]
    // [END maps_ios_shapes_polyline_styles_spans_fractional]

    // [START maps_ios_shapes_polyline_styles_spans_repeating_color]
    let styles = [
      GMSStrokeStyle.solidColor(.white),
      GMSStrokeStyle.solidColor(.black)
    ]
    let lengths: [NSNumber] = [100000, 50000]
    polyline.spans = GMSStyleSpans(
      polyline.path!,
      styles,
      lengths,
      GMSLengthKind.rhumb
    )
    // [END maps_ios_shapes_polyline_styles_spans_repeating_color]
  }

  func polygons() {
    // [START maps_ios_shapes_polygon]
    // Create a rectangular path
    let rect = GMSMutablePath()
    rect.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
    rect.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.0))
    rect.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.2))
    rect.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.2))

    // Create the polygon, and assign it to the map.
    let polygon = GMSPolygon(path: rect)
    polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
    polygon.strokeColor = .black
    polygon.strokeWidth = 2
    polygon.map = mapView
    // [END maps_ios_shapes_polygon]

    // [START maps_ios_shapes_polygon_hollow]
    let hydeParkLocation = CLLocationCoordinate2D(latitude: -33.87344, longitude: 151.21135)
    let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 16)
    let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
    mapView.animate(to: camera)

    let hydePark = "tpwmEkd|y[QVe@Pk@BsHe@mGc@iNaAKMaBIYIq@qAMo@Eo@@[Fe@DoALu@HUb@c@XUZS^ELGxOhAd@@ZB`@J^BhFRlBN\\BZ@`AFrATAJAR?rAE\\C~BIpD"
    let archibaldFountain = "tlvmEqq|y[NNCXSJQOB[TI"
    let reflectionPool = "bewmEwk|y[Dm@zAPEj@{AO"

    let hollowPolygon = GMSPolygon()
    hollowPolygon.path = GMSPath(fromEncodedPath: hydePark)
    hollowPolygon.holes = [GMSPath(fromEncodedPath: archibaldFountain)!, GMSPath(fromEncodedPath: reflectionPool)!]
    hollowPolygon.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
    hollowPolygon.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    hollowPolygon.strokeWidth = 2
    hollowPolygon.map = mapView
    // [END maps_ios_shapes_polygon_hollow]
  }

  func circles() {
    // [START maps_ios_shapes_circles]
    let circleCenter = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0)
    let circle = GMSCircle(position: circleCenter, radius: 1000)
    circle.map = mapView
    // [END maps_ios_shapes_circles]

    // [START maps_ios_shapes_circles_customize]
    circle.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
    circle.strokeColor = .red
    circle.strokeWidth = 5
    // [END maps_ios_shapes_circles_customize]
  }
}
