[![Build](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/actions/workflows/build.yml/badge.svg)](https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/actions/workflows/build.yml)

![Contributors](https://img.shields.io/github/contributors/googlemaps-samples/maps-sdk-for-ios-samples?color=green)
[![License](https://img.shields.io/github/license/googlemaps-samples/maps-sdk-for-ios-samples?color=blue)][license]
[![StackOverflow](https://img.shields.io/stackexchange/stackoverflow/t/google-maps?color=orange&label=google-maps&logo=stackoverflow)](https://stackoverflow.com/questions/tagged/google-maps)
[![Discord](https://img.shields.io/discord/676948200904589322?color=6A7EC2&logo=discord&logoColor=ffffff)][Discord server]

# Google Maps SDK for iOS sample code

## Description

This repository provides samples demonstrating use of the [Google Maps Platform Maps SDK for iOS][ios-sdk].

### Samples for other Google Maps Platform iOS SDKs

Sample code for the [Places SDK for iOS][ios-places-sdk], [Maps 3D SDK for iOS][ios-3d-sdk] and [Navigation SDK for iOS][ios-nav-sdk] can be found in the following repositories:

- [Google Places SDK for iOS Samples][ios-places-sdk-samples]
- [Google Maps 3D SDK for iOS Samples][ios-3d-sdk-samples]
- [Google Navigation SDK for iOS Samples][ios-nav-sdk-samples]


## Requirements

To run the samples, you will need:

- To [sign up with Google Maps Platform]
- A Google Maps Platform [project] with the relevant SDK enabled
- An [API key] associated with the project above ... follow the [API key instructions] if you're new to the process
- Swift or Objective-C
- Xcode 16+
- (Deployment target of) iOS 16+

## GoogleMaps-SwiftUI

The `GoogleMaps-SwiftUI` sub-directory contains sample code demonstrating how to integrate Google Maps SDK with SwiftUI applications. It provides a modern SwiftUI wrapper around `GMSMapView` with a declarative API for common map configurations and interactions. To use this project:

```
$ cd GoogleMaps-SwiftUI
$ open GoogleMaps-SwiftUI.xcodeproj
```

This project uses Swift Package Manager and requires the [GoogleMaps package](https://github.com/googlemaps/ios-maps-sdk). The sample code demonstrates best practices for integrating Google Maps into SwiftUI-based iOS applications.

## GoogleMaps-Swift

The `GoogleMaps-Swift` and `GoogleMaps` sub-directories contain the sample code that is downloaded
when you run `pod try GoogleMaps`. To use this project:

For Swift (UIKit) samples:

```
$ cd GoogleMaps-Swift
$ pod install
$ open GoogleMapsSwiftDemos.xcworkspace
```

For Objective-C samples:

```
$ cd GoogleMaps
$ pod install
$ open GoogleMapsDemos.xcworkspace
```

Add your API Key to `GoogleMapsDemos/SDKDemoAPIKey.h`.

## Tutorials

The `tutorials` sub-directory contains sample code that accompanies tutorials in the developer
documentation, such as
[Adding a Map with a Marker](https://developers.google.com/maps/documentation/ios-sdk/map-with-marker),
and more. Follow the tutorials for a quick guide to using the SDK.

## Snippets

The `snippets` sub-directory contains code snippets that can be found in the developer documentation site.

## Deprecated Samples

The `GoogleNavigation`, `GoogleNavigation-Swift`, `GooglePlaces`, `GooglePlaces-Swift` and `MapsAndPlacesDemo` folders contain deprecated code samples and will be removed in the near future. For Navigation SDK and Places SDK please see the separate sample app repos listed above.

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

If you find a bug or have a feature request related to one of the SDK, you can file an issue at the Maps SDK for iOS Issue Tracker page:

- [Maps SDK for iOS Issue Tracker](https://developers.google.com/maps/documentation/ios-sdk/support#issue-tracker)

You can also discuss these samples on our [Discord server].

[ios-sdk]: https://developers.google.com/maps/documentation/ios-sdk
[API key]: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
[API key instructions]: https://developers.google.com/maps/documentation/ios-sdk/config#get-key
[ios-nav-sdk]: https://developers.google.com/maps/documentation/navigation/ios-sdk
[ios-places-sdk]: https://developers.google.com/maps/documentation/places/ios-sdk/overview
[ios-3d-sdk]: https://developers.google.com/maps/documentation/maps-3d/ios-sdk
[ios-3d-sdk-samples]: https://github.com/googlemaps-samples/ios-maps-3d-sdk-samples
[ios-nav-sdk-samples]: https://github.com/googlemaps-samples/ios-navigation-sdk-samples
[ios-places-sdk-samples]: https://github.com/googlemaps-samples/ios-places-sdk-samples

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
