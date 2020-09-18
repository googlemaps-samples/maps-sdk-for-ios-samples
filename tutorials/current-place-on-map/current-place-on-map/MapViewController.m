//
//  MapsViewController.m
//  current-place-on-map
//
//  Created by Chris Arriola on 9/18/20.
//  Copyright © 2020 William French. All rights reserved.
//

#import "MapViewController.h"
#import "PlacesViewController.h"
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
  float preciseLocationZoomLevel;
  float approximateLocationZoomLevel;
  // [END maps_ios_current_place_declare_params]
  
  // [START maps_ios_current_place_places_params]
  // An array to hold the list of likely places.
  NSMutableArray<GMSPlace *> *likelyPlaces;

  // The currently selected place.
  GMSPlace * _Nullable selectedPlace;
  // [END maps_ios_current_place_places_params]
}

- (void)viewDidLoad {
  [super viewDidLoad];
  preciseLocationZoomLevel = 15.0;
  approximateLocationZoomLevel = 15.0;

  // [START maps_ios_current_place_init_params]
  // Initialize the location manager.
  locationManager = [[CLLocationManager alloc] init];
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [locationManager requestWhenInUseAuthorization];
  locationManager.distanceFilter = 50;
  [locationManager startUpdatingLocation];
  locationManager.delegate = self;

  placesClient = [GMSPlacesClient sharedClient];
  // [END maps_ios_current_place_init_params]

  // [START maps_ios_current_place_create_a_map]
  // A default location to use when location permission is not granted.
  CLLocationCoordinate2D defaultLocation = CLLocationCoordinate2DMake(-33.869405, 151.199);
  
  // Create a map.
  float zoomLevel = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel;
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:defaultLocation.latitude
                                                          longitude:defaultLocation.longitude
                                                               zoom:zoomLevel];
  mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
  mapView.settings.myLocationButton = YES;
  mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  mapView.myLocationEnabled = YES;

  // Add the map to the view, hide it until we've got a location update.
  [self.view addSubview:mapView];
  mapView.hidden = YES;
  // [END maps_ios_current_place_create_a_map]

  [self listLikelyPlaces];
}

// [START maps_ios_current_place_list_likely_places]
// Populate the array with the list of likely places.
- (void) listLikelyPlaces
{
  // Clean up from previous sessions.
  likelyPlaces = [NSMutableArray array];

  GMSPlaceField placeFields = GMSPlaceFieldName | GMSPlaceFieldCoordinate;
  [placesClient findPlaceLikelihoodsFromCurrentLocationWithPlaceFields:placeFields callback:^(NSArray<GMSPlaceLikelihood *> * _Nullable likelihoods, NSError * _Nullable error) {
    if (error != nil) {
      // TODO: Handle the error.
      NSLog(@"Current Place error: %@", error.localizedDescription);
      return;
    }
    
    if (likelihoods == nil) {
      NSLog(@"No places found.");
      return;
    }
    
    for (GMSPlaceLikelihood *likelihood in likelihoods) {
      GMSPlace *place = likelihood.place;
      [likelyPlaces addObject:place];
    }
  }];
}
// [END maps_ios_current_place_list_likely_places]

// [START maps_ios_current_place_unwindtomain]
// Update the map once the user has made their selection.
- (void) unwindToMain:(UIStoryboardSegue *)segue
{
  // Clear the map.
  [mapView clear];

  // Add a marker to the map.
  if (selectedPlace != nil) {
    GMSMarker *marker = [GMSMarker markerWithPosition:selectedPlace.coordinate];
    marker.title = selectedPlace.name;
    marker.snippet = selectedPlace.formattedAddress;
    marker.map = mapView;
  }

  [self listLikelyPlaces];
}
// [END maps_ios_current_place_unwindtomain]

// [START maps_ios_current_place_segue]
// Prepare the segue.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"segueToSelect"]) {
    if ([segue.destinationViewController isKindOfClass:[PlacesViewController class]]) {
      PlacesViewController *placesViewController = (PlacesViewController *)segue.destinationViewController;
      placesViewController.likelyPlaces = likelyPlaces;
    }
  }
}
// [END maps_ios_current_place_segue]

// [START maps_ios_current_place_location_manager_delegate]
// Delegates to handle events for the location manager.
#pragma mark - CLLocationManagerDelegate

// Handle incoming location events.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
  CLLocation *location = locations.lastObject;
  NSLog(@"Location: %@", location);
  
  float zoomLevel = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel;
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
  // Check accuracy authorization
  CLAccuracyAuthorization accuracy = manager.accuracyAuthorization;
  switch (accuracy) {
    case CLAccuracyAuthorizationFullAccuracy:
      NSLog(@"Location accuracy is precise.");
      break;
    case CLAccuracyAuthorizationReducedAccuracy:
      NSLog(@"Location accuracy is not precise.");
      break;
  }
  
  // Handle authorization status
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
