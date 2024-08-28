/// Copyright 2024 Google LLC. All rights reserved.
///
///
/// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
/// file except in compliance with the License. You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software distributed under
/// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
/// ANY KIND, either express or implied. See the License for the specific language governing
/// permissions and limitations under the License.

import CarPlay
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var carPlayInterfaceController: CPInterfaceController?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = scene as? UIWindowScene else { return }
    window = .init(windowScene: scene)

    let sampleListViewController = SampleListViewController()
    let master = UINavigationController(rootViewController: sampleListViewController)
    master.navigationBar.isTranslucent = false

    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithDefaultBackground()
    master.navigationBar.standardAppearance = navBarAppearance
    master.navigationBar.scrollEdgeAppearance = navBarAppearance

    let splitViewController = UISplitViewController()
    splitViewController.preferredDisplayMode = .allVisible
    splitViewController.viewControllers = [master]

    window?.rootViewController = splitViewController
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate: CPTemplateApplicationSceneDelegate, CPInterfaceControllerDelegate {

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController, to window: CPWindow
  ) {
    carPlayInterfaceController = interfaceController
    carPlayInterfaceController?.delegate = self
    let applicationSceneController =
      CarPlayApplicationSceneInformationController.makeInformationTemplate(window: window)
    carPlayInterfaceController?.setRootTemplate(applicationSceneController, animated: false)
  }

}
