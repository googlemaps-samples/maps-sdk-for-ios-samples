//
//  MapsViewController.m
//  current-place-on-map
//
//  Created by Chris Arriola on 9/18/20.
//  Copyright © 2020 William French. All rights reserved.
//

#import "MapViewController.h"
@import CoreLocation;
@import GooglePlaces;
@import GoogleMaps;

@interface MapViewController () <CLLocationManagerDelegate>

@end

@implementation MapViewController {
  // [START maps_ios_current_place_declare_params]
  CLLocationManager *locationManager;
  CLLocation * _Nullable currentLocation;
  GMSMapView *mapView;
  GMSPlacesClient *placesClient;
  float zoomLevel;
  // [END maps_ios_current_place_declare_params]
  
  // [START maps_ios_current_place_places_params]
  // An array to hold the list of likely places.
  NSArray<GMSPlace *> *likelyPlaces;

  // The currently selected place.
  GMSPlace * _Nullable selectedPlace;
  // [END maps_ios_current_place_places_params]
}

- (void)viewDidLoad {
  [super viewDidLoad];
  zoomLevel = 15.0;

  // [START maps_ios_current_place_init_params]
  // Initialize the location manager.
  locationManager = [[CLLocationManager alloc] init];
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [locationManager requestAlwaysAuthorization];
  locationManager.distanceFilter = 50;
  [locationManager startUpdatingLocation];
  locationManager.delegate = self;

  placesClient = [GMSPlacesClient sharedClient];
  // [END maps_ios_current_place_init_params]
}

- (void) listLikelyPlaces
{
  // TODO
}

// [START maps_ios_current_place_location_manager_delegate]
// Delegates to handle events for the location manager.
#pragma mark - CLLocationManagerDelegate

// Handle incoming location events.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  CLLocation *location = locations.lastObject;
  NSLog(@"Location: %@", location);
  
  GMSCameraPosition * camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                           longitude:location.coordinate.longitude
                                                                zoom:zoomLevel];
  
  if (mapView.isHidden) {
    mapView.hidden = NO;
    mapView.camera = camera;
  } else {
    [mapView animateToCameraPosition:camera];
  }

  [self listLikelyPlaces];
}

// Handle authorization for the location manager.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
  switch (status) {
    case kCLAuthorizationStatusRestricted:
      NSLog(@"Location access was restricted.");
      break;
    case kCLAuthorizationStatusDenied:
      NSLog(@"User denied access to location.");
      // Display the map using the default location.
      mapView.hidden = NO;
    case kCLAuthorizationStatusNotDetermined:
      NSLog(@"Location status not determined.");
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      NSLog(@"Location status is OK.");
  }
}

// Handle location manager errors.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  [manager stopUpdatingLocation];
  NSLog(@"Error: %@", error.localizedDescription);
}
// [END maps_ios_current_place_location_manager_delegate]

@end
