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

struct Dialog: View {
    
    @StateObject private var viewModel = MapExamplesViewModel()
    @State private var mapOptions: GMSMapViewOptions
    
    init() {
        _mapOptions = State(initialValue: MapExamplesViewModel().mapOptions)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top half - Map View centered on Seattle
                GoogleMapView(options: $mapOptions)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                
                // Bottom half - Examples List
                List(viewModel.examples) { example in
                    NavigationLink(destination: example.destination) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(example.title)
                                .font(.headline)
                            Text(example.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Google Maps SwiftUI Samples")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
