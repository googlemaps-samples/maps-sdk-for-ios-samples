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

struct MapWithContainer: View {
    
    private let mapOptions: GMSMapViewOptions = {
        var options = GMSMapViewOptions()
        options.camera = .camera(.seattle)  // Initial camera centered on Seattle
        return options
    }()
        
    var body: some View {
        VStack(spacing: 16) {
            
            GoogleMapView(options: mapOptions)
                .ignoresSafeAreaExceptTop()   // Optional property for samples display
                .frame(maxWidth: .infinity, minHeight: 325)
            
            VStack(alignment: .leading) {
                Text("Working with Container Views")
                    .font(.headline)
                
                Text("The GoogleMapView seamlessly integrates with SwiftUI layouts, allowing for standard modifiers like frame and padding.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}
