![GitHub contributors](https://img.shields.io/github/contributors/googlemaps/maps-sdk-for-ios-samples)
![Apache-2.0](https://img.shields.io/badge/license-Apache-blue)
# Google Maps SDK for iOS and Google Places API for iOS sample code

## Description

This repository contains sample code for use with the Google Maps SDK for iOS and Google Places API for iOS.

## Requirements

You will need an API key to run any of the samples.  Please see the
[documentation](https://developers.google.com/maps/documentation/ios-sdk/start#get-key)
for details on how to get an API Key.

## Installation

### GoogleMaps

The `GoogleMaps` and `GoogleMaps-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleMaps`.

__To use this project:__

```
$ cd GoogleMaps
$ pod install
$ open GoogleMapsDemos.xcworkspace
```

You will need to add your API Key to `GoogleMapsDemos/SDKDemoAPIKey.h`.

__For Swift samples:__

```
$ cd GoogleMaps-Swift
$ pod install
$ open GoogleMapsSwiftDemos.xcworkspace
```

You will need to add your API Key to `GoogleMapsSwiftDemo/SDKConstants.swift`.

### GooglePlaces

The `GooglePlaces` and `GooglePlaces-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GooglePlaces`.

__To use this project:__

```
$ cd GooglePlaces
$ pod install
$ open GooglePlacesDemos.xcworkspace
```

You will need to add your API Key to `GoogleMapsDemos/SDKDemoAPIKey.h`.

__For Swift samples:__

```
$ cd GooglePlaces-Swift
$ pod install
$ open GooglePlacesSwiftDemos.xcworkspace
```

You will need to add your API Key to `GoogleMapsSwiftDemo/SDKConstants.swift`.

### MapsAndPlacesDemo

This demo application looks to bridge some of the features found in the GooglePlaces and GoogleMaps demo applications as well as utilize some of the ways the two API's can work together.
Click this [link](https://www.youtube.com/watch?v=u4Ih8EWqZio) to watch a video demonstration.

__This project was made by Haiming Xu as an internship project from 05/2020 to 08/2020__

__Requirements__
- If you are emulating this from you Mac, please make sure to set the emulated phone's location (otherwise, location features will not work)
- A [Google Cloud Platform API key](https://developers.google.com/maps/documentation/ios-sdk/start#get-key) with Maps SDK for iOS and Places SDK for iOS enabled
- A light and dark themed map, which can be created [here](https://console.cloud.google.com/google/maps-apis/client-styles?project=verdant-medium-278819&folder=&organizationId=) (make sure you sign in first)
- If you want a different data set, ensure that it follows the correct formatting (and is also a JSON file) like the one provided (the data set provided can be found in dataset.json)

__Installation__
1. Make sure you are in the right folder (MapsAndPlacesDemo)
2. Run `pod install`
3. Open `MapsAndPlacesDemo.xcworkspace`
4. Drag the data set (`dataset.json`) into the Xcode file explorer (left pane)

## Sample App

* [Google Maps (Swift)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/tree/main/GoogleMaps-Swift)
* [Google Maps (Objective-C)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/tree/main/GoogleMaps)
* [Google Places (Swift)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/tree/main/GooglePlaces-Swift)
* [Google Places (Objective-C)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/tree/main/GooglePlaces)

## Documentation

* [Google Maps](https://developers.google.com/maps/documentation/ios-sdk/overview)
* [Google Places](https://developers.google.com/maps/documentation/places/ios-sdk/overview)

## Terms of Service

This library uses Google Maps Platform services, and any use of Google Maps Platform is subject to the [Terms of Service](https://cloud.google.com/maps-platform/terms).

For clarity, this library, and each underlying component, is not a Google Maps Platform Core Service.

## Support

This library is offered via an open source license. It is not governed by the Google Maps Platform Support [Technical Support Services Guidelines](https://cloud.google.com/maps-platform/terms/tssg), the [SLA](https://cloud.google.com/maps-platform/terms/sla), or the [Deprecation Policy](https://cloud.google.com/maps-platform/terms) (however, any Google Maps Platform services used by the library remain subject to the Google Maps Platform Terms of Service).

This library adheres to [semantic versioning](https://semver.org/) to indicate when backwards-incompatible changes are introduced. Accordingly, while the library is in version 0.x, backwards-incompatible changes may be introduced at any time. 

If you find a bug, or have a feature request, please [file an issue]() on GitHub. If you would like to get answers to technical questions from other Google Maps Platform developers, ask through one of our [developer community channels](https://developers.google.com/maps/developer-community). If you'd like to contribute, please check the [Contributing guide]().

You can also discuss this library on our [Discord server](https://discord.gg/hYsWbmk).
   
