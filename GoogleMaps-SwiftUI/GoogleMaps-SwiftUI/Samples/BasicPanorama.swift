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

struct BasicPanorama: View {

    let viewModel = PanoramaViewModel()

    var body: some View {
        PanoramaView(viewModel: viewModel)
            .task {
                viewModel.move(near: .newYork)
            }
    }
}

// MARK: - ViewModel

class PanoramaViewModel: NSObject, ObservableObject {

    let panoramaView: GMSPanoramaView = {
        let panoramaView = GMSPanoramaView()
        return panoramaView
    }()

    override init() {
        super.init()
        panoramaView.delegate = self
    }

    func move(near coordinate: CLLocationCoordinate2D) {
        panoramaView.moveNearCoordinate(coordinate)
    }

    func move(to panoramaID: String) {
        panoramaView.move(toPanoramaID: panoramaID)
    }
}

extension PanoramaViewModel: GMSPanoramaViewDelegate {
    func panoramaView(_ panoramaView: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
        let panoramaID = panorama?.panoramaID ?? "Unknown"
        print("Did move to panorama: \(panoramaID)")
    }

    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        print("Did move to panorama: \(panorama.panoramaID) near coordinate: \(coordinate)")
    }

    func panoramaViewDidStartRendering(_ panoramaView: GMSPanoramaView) {
        print("Panorama view started rendering")
    }

    func panoramaViewDidFinishRendering(_ panoramaView: GMSPanoramaView) {
        print("Panorama did finish rendering")
    }

    func panoramaView(_ view: GMSPanoramaView, error: any Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        print("Failed to move to coordinate: \(coordinate)")
    }

    func panoramaView(_ view: GMSPanoramaView, error: any Error, onMoveToPanoramaID panoramaID: String) {
        print("Failed to move to  panoramaID: \(panoramaID)")
    }
}

// MARK: - UIViewRepresentable

struct PanoramaView: UIViewRepresentable {
    let viewModel: PanoramaViewModel

    init(viewModel: PanoramaViewModel) {
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> GMSPanoramaView {
        return viewModel.panoramaView
    }

    func updateUIView(_ uiView: GMSPanoramaView, context: Context) {}
}


