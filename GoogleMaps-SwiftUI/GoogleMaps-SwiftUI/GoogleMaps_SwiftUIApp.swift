// Copyright 2024 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import SwiftUI
import GoogleMaps

@main
struct GoogleMaps_SwiftUIApp: App {
    
    init() {
        /*
         API Key Setup:
         1. Create a .xcconfig file at the project root level
         2. Add this line: API_KEY = your_api_key_here
         3. Get an API key from: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
       
         Note: Never commit your actual API key to source control
        */
        
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else {
          fatalError("Info.plist not found")
        }
        guard let apiKey: String = infoDictionary["API_KEY"] as? String else {
          fatalError("API_KEY not set in Info.plist")
        }
       let _ = GMSServices.provideAPIKey(apiKey)
        
    }
    var body: some Scene {
        WindowGroup {
            //present the dialog of map samples
            Dialog()
        }
    }
}
