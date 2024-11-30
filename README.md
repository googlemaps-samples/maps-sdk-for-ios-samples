# Google Maps SDK for iOS, Google Places SDK for iOS, and Google Navigation SDK for iOS sample code

This repository contains sample code for use with the Google Maps SDK for iOS, Google Places SDK for iOS and Google Navigation SDK for iOS



The `GoogleMaps` and `GoogleMaps-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleMaps`. To use this 

You will need to add an API Key to `GoogleMapsDemos/SDKDemoAPIKey.h`. Please see the
[documentation](https://developers.google.com/maps/documentation/ios-sdk/start#get-key)
for details on how to get an API Key.

## GooglePlaces

The `GooglePlaces` and `GooglePlaces-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GooglePlaces`. To use this project:


You will need to add an API Key to `GooglePlacesDemos/SDKDemoAPIKey.h`. Please see the
[documentation](https://developers.google.com/places/ios-api/start#get-key)
for details on how to get an API Key.

# GoogleNavigation

The `GoogleNavigation` and `GoogleNavigation-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleNavigation`. To use this project:

You will need to add an API Key to `GoogleNavigationDemos/SDKDemoAPIKey.h`. Please see the
[documentation](https://developers.google.com/maps/documentation/navigation/ios-sdk/get-api-key)
for details on how to get an API Key.

## MapsAndPlacesDemo
### Description
This demo application looks to bridge some of the features found in the GooglePlaces and GoogleMaps demo applications as well as utilize some of the ways the two API's can work together.
### Requirements
- If you are emulating this from you Mac, please make sure to set the emulated phone's location (otherwise, location features will not work)
- A [Google Cloud Platform API key](https://developers.google.com/maps/documentation/ios-sdk/start#get-key) with Maps SDK for iOS and Places SDK for iOS enabled
- A light and dark themed map, which can be created [here](https://console.cloud.google.com/google/maps-apis/client-styles?project=verdant-medium-278819&folder=&organizationId=) (make sure you sign in first)
- If you want a different data set, ensure that it follows the correct formatting (and is also a JSON file) like the one provided (the data set provided can be found in dataset.json)






# Installation
1. Make sure you are in the right folder (MapsAndPlacesDemo)
2. Run `pod install`
3. Open `MapsAndPlacesDemo.xcworkspace`
4. Drag the data set (dataset.json) into the Xcode file explorer (left pane)

## Tutorials

The `tutorials` sub-directory contains sample code that accompanies tutorials in the developer
documentation, such as 
[Adding a Map with a Marker](https://developers.google.com/maps/documentation/ios-sdk/map-with-marker),
and more. Follow the tutorials for a quick guide to using the SDK.

## Snippets

The `snippets` sub-directory contains code snippets that can be found in the developer documentation site.

## Support

If you find a bug or have a feature request related to these samples, please [file an issue](https://github.com/googlemaps/maps-sdk-for-ios-samples/issues).

If you find a bug or have a feature request related to one of the SDKs, you can file an issue on either the
[Google Maps SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/ios-sdk/support#issue-tracker).or the
[Places SDK for iOS Issue Tracker](https://issuetracker.google.com/savedsearches/5050150).

You can also discover additional support services for the Google Maps Platform, including developer communities,
technical guidance, and expert support at the Google Maps Platform [support resources page](https://developers.google.com/maps/support/).

Thanks!
