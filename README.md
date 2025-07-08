[![Build](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/actions/workflows/build.yml/badge.svg)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/actions/workflows/build.yml)

![Contributors](https://img.shields.io/github/contributors/googlemaps-samples/maps-sdk-for-ios-samples?color=green)
[![License](https://img.shields.io/github/license/googlemaps-samples/maps-sdk-for-ios-samples?color=blue)][license]
[![StackOverflow](https://img.shields.io/stackexchange/stackoverflow/t/google-maps?color=orange&label=google-maps&logo=stackoverflow)](https://stackoverflow.com/questions/tagged/google-maps)
[![Discord](https://img.shields.io/discord/676948200904589322?color=6A7EC2&logo=discord&logoColor=ffffff)][Discord server]

# Google Maps SDK for iOS, Google Places SDK for iOS, and Google Navigation SDK for iOS sample code

## Description

This repository provides one or more samples demonstrating use of various **iOS SDKs** in the Google Maps Platform.

## Samples in this repo

This repository contains sample code for use with the

- [Google Maps SDK for iOS][ios-sdk]
- [Google Places SDK for iOS](https://developers.google.com/maps/documentation/places/ios-sdk), and
- [Google Navigation SDK for iOS](https://developers.google.com/maps/documentation/navigation/ios-sdk)

## Requirements

To run the samples, you will need:

- To [sign up with Google Maps Platform]
- A Google Maps Platform [project] with the relevant SDK enabled
- An [API key] associated with the project above ... follow the [API key instructions] if you're new to the process
- Swift or Objective-C
- Xcode 15+
- (Deployment target of) iOS 15+

## GoogleMaps

The `GoogleMaps` and `GoogleMaps-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleMaps`. To use this project:

For Objective-C samples:

```
$ cd GoogleMaps
$ pod install
$ open GoogleMapsDemos.xcworkspace
```

For Swift (UIKit) samples:

```
$ cd GoogleMaps-Swift
$ open GoogleMapsSwiftDemos.xcworkspace
```

You will need to add an API Key to your configuration. Please see the [documentation](https://developers.google.com/maps/documentation/ios-sdk/start#get-key) for details on how to get an API Key.

This project uses Swift Package Manager and requires the [GoogleMaps package](https://github.com/googlemaps/ios-maps-sdk). The sample code demonstrates best practices for integrating Google Maps into Swift-based iOS applications.


## GoogleMaps-SwiftUI

The `GoogleMaps-SwiftUI` sub-directory contains sample code demonstrating how to integrate Google Maps SDK with SwiftUI applications. It provides a modern SwiftUI wrapper around `GMSMapView` with a declarative API for common map configurations and interactions. To use this project:

```
$ cd GoogleMaps-SwiftUI
$ open GoogleMaps-SwiftUI.xcodeproj
```

This project uses Swift Package Manager and requires the [GoogleMaps package](https://github.com/googlemaps/ios-maps-sdk). The sample code demonstrates best practices for integrating Google Maps into SwiftUI-based iOS applications.

## GooglePlaces

The `GooglePlaces` and `GooglePlaces-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GooglePlaces`. To use this project:

```
$ cd GooglePlaces
$ pod install
$ open GooglePlacesDemos.xcworkspace
```

For Swift samples:

```
$ cd GooglePlaces-Swift
$ pod install
$ open GooglePlacesSwiftDemos.xcworkspace
```

Add your API Key to `GooglePlacesDemos/SDKDemoAPIKey.h`.

## GoogleNavigation

The `GoogleNavigation` and `GoogleNavigation-Swift` sub-directory contains the sample code that is downloaded
when you run `pod try GoogleNavigation`. To use this project:

```
$ cd GoogleNavigation
$ pod install
$ open GoogleNavigationDemos.xcworkspace
```

For Swift samples:

```
$ cd GoogleNavigation-Swift
$ pod install
$ open GoogleNavigationSwiftDemos.xcworkspace
```

Add your API Key to `GoogleNavigationDemos/SDKDemoAPIKey.h`.

## MapsAndPlacesDemo

This demo application looks to bridge some of the features found in the GooglePlaces and GoogleMaps demo applications as well as utilize some of the ways the two API's can work together.
Click this [link](https://www.youtube.com/watch?v=u4Ih8EWqZio) to watch a video demonstration.

- If you are emulating this from you Mac, please make sure to set the emulated phone's location (otherwise, location features will not work)
- A [Google Cloud Platform API key](https://developers.google.com/maps/documentation/ios-sdk/start#get-key) with Maps SDK for iOS and Places SDK for iOS enabled
- A light and dark themed map, which can be created [here](https://console.cloud.google.com/google/maps-apis/client-styles?project=verdant-medium-278819&folder=&organizationId=) (make sure you sign in first)
- If you want a different data set, ensure that it follows the correct formatting (and is also a JSON file) like the one provided (the data set provided can be found in dataset.json)

### Installation
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

## Contributing

External contributions are not accepted for this repository. See [contributing guide] for more info.

## Terms of Service

This sample uses Google Maps Platform services. Use of Google Maps Platform services through this sample is subject to the Google Maps Platform [Terms of Service].

**European Economic Area (EEA) developers**

If your billing address is in the European Economic Area, effective on 8 July 2025, the [Google Maps Platform EEA Terms of Service](https://cloud.google.com/terms/maps-platform/eea) will apply to your use of the Services. Functionality varies by region. [Learn more](https://developers.google.com/maps/comms/eea/faq).

This sample is not a Google Maps Platform Core Service. Therefore, the Google Maps Platform Terms of Service (e.g. Technical Support Services, Service Level Agreements, and Deprecation Policy) do not apply to the code in this sample.

## Support

This sample is offered via an open source [license]. It is not governed by the Google Maps Platform Support [Technical Support Services Guidelines], the [SLA], or the [Deprecation Policy]. However, any Google Maps Platform services used by the sample remain subject to the Google Maps Platform Terms of Service.

If you find a bug, or have a feature request, please [file an issue] on GitHub. If you would like to get answers to technical questions from other Google Maps Platform developers, ask through one of our [developer community channels]. If you'd like to contribute, please check the [contributing guide].

If you find a bug or have a feature request related to one of the SDKs, you can file an issue at their respective pages:

- [Maps SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/ios-sdk/support#issue-tracker)
- [Places SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/places/ios-sdk/support#issue-tracker)
- [Navigation SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/navigation/ios-sdk/support#issue-tracker)

You can also discuss these samples on our [Discord server].

[ios-sdk]: https://developers.google.com/maps/documentation/ios-sdk
[API key]: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
[API key instructions]: https://developers.google.com/maps/documentation/ios-sdk/config#get-key

[code of conduct]: ?tab=coc-ov-file#readme
[contributing guide]: CONTRIBUTING.md
[Deprecation Policy]: https://cloud.google.com/maps-platform/terms
[developer community channels]: https://developers.google.com/maps/developer-community
[Discord server]: https://discord.gg/hYsWbmk
[file an issue]: https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/issues/new/choose
[license]: LICENSE
[pull request]: https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/compare
[project]: https://developers.google.com/maps/documentation/ios-sdk/cloud-setup#enabling-apis
[Sign up with Google Maps Platform]: https://console.cloud.google.com/google/maps-apis/start
[SLA]: https://cloud.google.com/maps-platform/terms/sla
[Technical Support Services Guidelines]: https://cloud.google.com/maps-platform/terms/tssg
[Terms of Service]: https://cloud.google.com/maps-platform/terms
