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

import UIKit

typealias TargetActionPair = (target: Any?, action: Selector)

/// Helper functions for creating UI elements to add to a menu. This provides common functionality
/// for samples and does not demonstrate any significant functionality of Google Navigation SDK.
enum MenuUIHelpers {
  private static let cornerRadius: CGFloat = 5.0
  private static let minimumFontScaleFactor: CGFloat = 0.7
  private static let defaultSpacing: CGFloat = 4

  /// Makes a `UIStackView` with the given options suitable for use in a menu.
  ///
  /// - Parameters:
  ///   - axis: The stack view axis. Defaults to `.horizontal`.
  ///   - arrangedSubviews: The list of subviews to be added to the stack view.
  /// - Returns: The created stack view.
  static func makeStackView(
    axis: NSLayoutConstraint.Axis = .horizontal,
    arrangedSubviews: [UIView]
  ) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.spacing = defaultSpacing
    stack.distribution = .fillEqually
    stack.axis = axis
    return stack
  }

  /// Makes a `UILabel` suitable as a title in a menu using the given title text.
  ///
  /// - Parameters:
  ///   - text: Set as `text` for the label. Defaults to an empty string.
  ///   - numberOfLines: Set as `numberOfLines` for the label. Defaults to 1.
  /// - Returns: The created label.
  static func makeLabel(text: String = "", numberOfLines: Int = 1) -> UILabel {
    let label = UILabel()
    label.text = text
    label.numberOfLines = numberOfLines
    configure(label)
    return label
  }

  /// Makes a `UIButton` with the given options suitable for use in a menu.
  /// - Parameters:
  ///   - title: Set as the button's title.
  ///   - targetActionPair: Set as the button's target/action for the `.touchUpInside` event.
  /// - Returns: The created button.
  static func makeMenuButton(
    title: String,
    onTouchUpInside targetActionPair: TargetActionPair
  ) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.addTarget(targetActionPair.target, action: targetActionPair.action, for: .touchUpInside)
    button.backgroundColor = .systemGray
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = cornerRadius
    if let titleLabel = button.titleLabel {
      configure(titleLabel)
    }
    return button
  }

  /// Makes a `UISegmentedControl` with the given options suitable for use in a menu.
  ///
  /// - Parameters:
  ///   - title: An optional title set for a label centered above the segmented control. Defaults to
  ///     nil.
  ///   - segmentTitles: The list of titles for the controls segments.
  ///   - targetActionPair: Set as the segmented control's target/action for the `.valueChanged`
  ///     event.
  /// - Returns: If `title` is present, returns a `UIStackView` with a label centered above the
  ///   segmented control. Otherwise returns just the segmented control.
  static func makeSegmentedControl(
    title: String? = nil,
    segmentTitles: [String],
    onValueChanged targetActionPair: TargetActionPair,
    selectedSegmentIndex: Int = 0
  ) -> UIView {
    let segmentedControl = UISegmentedControl(items: segmentTitles)
    segmentedControl.addTarget(
      targetActionPair.target, action: targetActionPair.action, for: .valueChanged)
    segmentedControl.selectedSegmentIndex = selectedSegmentIndex

    guard let title = title else { return segmentedControl }

    let titleLabel = makeLabel(text: title)
    titleLabel.textAlignment = .center
    return makeStackView(axis: .vertical, arrangedSubviews: [titleLabel, segmentedControl])
  }

  /// Makes a `UITextField` with the given options suitable for use in a menu.
  ///
  /// - Parameters:
  ///   - placeholder: Optional placeholder text for the text field. Defaults to nil.
  ///   - keyboardType: Keyboard type to use for the text field. Defaults to `.default`.
  /// - Returns: The created text field.
  static func makeTextField(
    placeholder: String? = nil,
    keyboardType: UIKeyboardType = .default
  ) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.keyboardType = keyboardType
    textField.borderStyle = .roundedRect
    return textField
  }

  /// Configures the given label to be suitable for use in a menu as a single line title.
  ///
  /// - Parameter label: The label to be configured.
  private static func configure(_ label: UILabel) {
    label.adjustsFontSizeToFitWidth = true
    label.allowsDefaultTighteningForTruncation = true
    label.lineBreakMode = .byTruncatingTail
    label.minimumScaleFactor = minimumFontScaleFactor
  }
}

extension UITextField {
  /// Adds a toolbar as the `inputAccessoryView` with "Done" and "Cancel" buttons.
  ///
  /// - Parameters:
  ///   - doneTargetActionPair: Set as the "Done" bar button's target/action.
  ///   - cancelTargetActionPair: Set as the "Cancel" bar button's target/action.
  func addDoneCancelToolbar(
    onDone doneTargetActionPair: TargetActionPair? = nil,
    onCancel cancelTargetActionPair: TargetActionPair? = nil
  ) {
    let onCancel = doneTargetActionPair ?? (target: self, action: #selector(cancelButtonTapped))
    let onDone = cancelTargetActionPair ?? (target: self, action: #selector(doneButtonTapped))

    let toolbar: UIToolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.items = [
      UIBarButtonItem(
        title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
      UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action),
    ]
    toolbar.sizeToFit()

    self.inputAccessoryView = toolbar
  }

  @objc private func doneButtonTapped() { self.resignFirstResponder() }
  @objc private func cancelButtonTapped() { self.resignFirstResponder() }
}
