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

import UIKit

/// A switch with a title label on the left hand side and the switch on the right hand side.
class NavDemoSwitch: UIView {
  private let control = UISwitch()
  private var titleLabel: UILabel
  private var textColor: UIColor

  /// The state of the switch.
  var isOn: Bool {
    get { control.isOn }
    set { control.isOn = newValue }
  }

  /// Whether the switch is enabled.
  var isEnabled: Bool {
    didSet {
      guard oldValue != isEnabled else { return }
      control.isEnabled = isEnabled
      titleLabel.textColor = isEnabled ? textColor : .lightGray
    }
  }

  /// Creates a switch with the given options.
  ///
  /// - Parameters:
  ///   - title: The title which appears on the left hand side of the switch.
  ///   - textColor: The text color of the title. Defaults to `.black`.
  ///   - initialState: The initial state of the switch. Defaults to `false`.
  ///   - onValueChanged: The target/action pair for the `.valueChanged` event.
  init(
    title: String?, textColor: UIColor = .black, initialState: Bool = false,
    onValueChanged targetActionPair: TargetActionPair
  ) {
    self.titleLabel = MenuUIHelpers.makeLabel(text: title ?? "")
    self.textColor = textColor
    self.isEnabled = true

    super.init(frame: .zero)

    titleLabel.textColor = textColor

    let stackView = MenuUIHelpers.makeStackView(arrangedSubviews: [titleLabel, control])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .fill
    addSubview(stackView)

    control.isOn = initialState
    control.addTarget(
      targetActionPair.target, action: targetActionPair.action, for: .valueChanged)

    addConstraints([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
