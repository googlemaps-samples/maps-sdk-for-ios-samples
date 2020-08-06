# MapsAndPlacesDemo
## Description
This demo application looks to bridge some of the features found in the GooglePlaces and GoogleMaps demo applications as well as utilize some of the ways the two API's can work together.
Click this [link](https://www.youtube.com/watch?v=u4Ih8EWqZio) to watch a video demonstration.

__This project was made by Haiming Xu as an internship project from 05/2020 to 08/2020__
## Requirements
- A [Google Cloud Platform API key](https://developers.google.com/maps/documentation/ios-sdk/start#get-key) with Maps SDK for iOS and Places SDK for iOS enabled
- A light and dark themed map, which can be created [here](https://console.cloud.google.com/google/maps-apis/client-styles?project=verdant-medium-278819&folder=&organizationId=) (make sure you sign in first)
- If you want a different data set, ensure that it follows the correct formatting (and is also a JSON file) like the one provided  
- If you are emulating this from you Mac, please make sure to set the emulated phone's location (otherwise, location features will not work)
## Installation
1. Make sure you are in the right folder (MapsAndPlacesDemo)
2. Run `pod install`
3. Open `MapsAndPlacesDemo.xcworkspace`
4. Drag the data set (dataset.json) into the Xcode file explorer (left pane)
