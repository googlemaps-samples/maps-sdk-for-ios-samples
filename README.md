![GitHub contributors](https://img.shields.io/github/contributors/googlemaps/maps-sdk-for-ios-samples)
![Apache-2.0](https://img.shields.io/badge/license-Apache-blue)

# Google Maps SDK for iOS and Google Places API for iOS sample code

This repository contains sample code for use with the Google Maps SDK for iOS
and Google Places API for iOS.

## GoogleMaps

The `GoogleMaps` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleMaps`. To use this project:

```
$ cd GoogleMaps
$ pod install
$ open GoogleMapsDemos.xcworkspace
```

You will need to add an API Key to `GoogleMapsDemos/SDKDemoAPIKey.h`. Please see the
[documentation](https://developers.google.com/maps/documentation/ios-sdk/start#get-key)
for details on how to get an API Key.

## GooglePlaces

The `GooglePlaces` sub-directory contains the sample code that is downloaded
when you run `pod try GooglePlaces`. To use this project:

```
$ cd GooglePlaces
$ pod install
$ open GooglePlacesDemos.xcworkspace
```

You will need to add an API Key to `GooglePlacesDemos/SDKDemoAPIKey.h`. Please see the
[documentation](https://developers.google.com/places/ios-api/start#get-key)
for details on how to get an API Key.

## MapsAndPlacesDemos
The MapsAndPlacesDemos sub-directory contains a demo application that showcases some of the capabilities the API's have when used together. There is also a Material Design influenced user interface. To use this project,

```
$ cd GoogleCombined
$ pod install
$ open GoogleProject.xcworkspace
```

Like the other subdirectories, you will need to add API keys for Google Maps and Google Places in the file GoogleProject/ApiKeys.swift

## Tutorials

The `tutorials` sub-directory contains sample code that accompanies tutorials in the developer
documentation, such as 
[Adding a Map with a Marker](https://developers.google.com/maps/documentation/ios-sdk/map-with-marker),
and more. Follow the tutorials for a quick guide to using the SDK.

## Snippets

The `snippets` sub-directory contains code snippets that can be found in the developer documentation site.

## Support

**NOTE: We are not accepting external contributions at this time.**

If you find a bug or have a feature request related to these samples, please [file an issue](https://github.com/googlemaps/maps-sdk-for-ios-samples/issues).

If you find a bug or have a feature request related to one of the SDKs, you can file an issue on either the
[Google Maps SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/ios-sdk/support#issue-tracker).or the
[Places SDK for iOS Issue Tracker](https://issuetracker.google.com/savedsearches/5050150).

You can also discover additional support services for the Google Maps Platform, including developer communities,
technical guidance, and expert support at the Google Maps Platform [support resources page](https://developers.google.com/maps/support/).

Thanks!
