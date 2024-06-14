/// Copyright 2020 Google LLC. All rights reserved.
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

import GoogleNavigation
import UIKit

/// The class which displays the list of samples.
class SampleListViewController: UITableViewController {
  private static let sampleCellIdentifier = "sampleCellIdentifier"
  private static let companyName = "Example Company"

  private let sampleSections = Samples.allSamples()
  private let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = NSLocalizedString(
      "Navigation SDK Demos", comment: "Navigation SDK Demos")
    tableView.register(
      UITableViewCell.self, forCellReuseIdentifier: SampleListViewController.sampleCellIdentifier)
  }

  // MARK: - Override UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section <= sampleSections.count else {
      return 0
    }
    return sampleSections[section].samples.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: SampleListViewController.sampleCellIdentifier, for: indexPath)
    if let sample = sample(at: indexPath) {
      cell.textLabel?.text = sample.title
    }
    return cell
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sampleSections.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  {
    guard section <= sampleSections.count else {
      return nil
    }
    return sampleSections[section].name
  }

  // MARK: - Override UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let sample = sample(at: indexPath) {
      loadSampleWithTermsAndAutorizationsRequest(sample)
    }
  }

  // MARK: - Private

  /// Returns the sample at the given `indexPath`.
  private func sample(at indexPath: IndexPath) -> Sample? {
    guard indexPath.section >= 0 && indexPath.section < sampleSections.count else { return nil }
    let section = sampleSections[indexPath.section]
    guard indexPath.row >= 0 && indexPath.row < section.samples.count else { return nil }
    return section.samples[indexPath.row]
  }

  /// Ensures terms and conditions have been accepted and if so loads the given `sample`.
  private func loadSampleWithTermsAndAutorizationsRequest(_ sample: Sample) {
    // Show the terms and conditions.
    GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(
      withCompanyName: SampleListViewController.companyName
    ) { termsAccepted in
      if termsAccepted {
        // First check the existing location authorization status, to ensure that an error is
        // printed if the location authorization has already been rejected. In this case, the system
        // dialog won't be displayed and the authorization status will not change.
        var status = CLAuthorizationStatus.notDetermined
        status = self.locationManager.authorizationStatus
        self.logIfLocationStatusNotAuthorized(status)

        // Request authorization to use location services. The outcome of the location authorization
        // dialog if it is shown is handled by the
        // locationManagerDidChangeAuthorization(CLLocationManager) delegate method.
        self.locationManager.requestAlwaysAuthorization()

        // Request authorization for alert notifications which deliver guidance instructions
        // in the background.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
          (granted, error) in
          // Handle rejection of notification authorization.
          if !granted || error != nil {
            print("Authorization to deliver notifications was rejected.")
          }
        }

        self.load(sample)
      } else {
        // Handle rejection of terms and conditions.
        print("Terms and conditions were not accepted.")
      }
    }
  }

  /// Loads and presents the view controller associated with the given `sample`.
  private func load(_ sample: Sample) {
    let viewController = sample.viewController
    viewController.title = sample.title
    let detail = UINavigationController(rootViewController: viewController)
    detail.navigationBar.isTranslucent = false
    viewController.navigationItem.leftItemsSupplementBackButton = true
    viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    showDetailViewController(detail, sender: self)
  }

  /// Prints an error message if the given authorization status is .denied or .restricted because
  /// NavDemo won't work properly in this case.
  private func logIfLocationStatusNotAuthorized(_ status: CLAuthorizationStatus) {
    var statusText = ""
    switch status {
    case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
      return
    case .restricted:
      statusText = "Restricted"
    case .denied:
      statusText = "Denied"
    @unknown default:
      print("NavDemo warning: Location authorization status is unknown: \(status.rawValue)")
    }
    print(
      "NavDemo error: Location authorization failed to be granted or was revoked with status: "
        + "\(statusText)")
  }
}

extension SampleListViewController: CLLocationManagerDelegate {
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    logIfLocationStatusNotAuthorized(status)
  }
}
