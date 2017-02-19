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

## GooglePlacePicker

The `GooglePlacePicker` sub-directory contains the sample code that is 
downloaded when you run `pod try GooglePlacePicker`. To use this project:

```
$ cd GooglePlacePicker
$ pod install
$ open GooglePlacePickerDemos.xcworkspace
```

You will need to add an API Key to `GooglePlacePickerDemos/SDKDemoAPIKey.swift`. Please see the
[documentation](https://developers.google.com/places/ios-api/start#get-key)
for details on how to get an API Key.

## Tutorials

The `tutorials` sub-directory contains sample code that accompanies tutorials in the developer
documentation, such as 
[Adding a Map with a Marker](https://developers.google.com/maps/documentation/ios-sdk/map-with-marker),
and more. Follow the tutorials for a quick guide to using the SDK.
