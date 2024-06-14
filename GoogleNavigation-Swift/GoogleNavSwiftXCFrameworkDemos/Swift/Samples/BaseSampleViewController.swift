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

/// A base class for samples that provides common functionality such as a collapsible menu and does
/// not demonstrate any significant functionality of Google Navigation SDK.
class BaseSampleViewController: UIViewController {
  /// Displays a rolling list of ephemeral messages where individual messages will be displayed for
  /// a short amount of time before disappearing.
  @MainActor
  class MessagesView: UILabel {
    /// The duration for which each individual message will be displayed.
    var duration: TimeInterval = 3.0

    private let maxCount = 5

    private(set) var messages = [String]()

    func add(message: String) async {
      messages.append(message)
      if messages.count > maxCount {
        messages.removeFirst(messages.count - maxCount)
      }
      refresh()
      try? await Task.sleep(nanoseconds: duration.toNanoseconds)
      if let index = messages.firstIndex(of: message) {
        messages.remove(at: index)
      }
      refresh()
    }

    private func refresh() {
      text = messages.joined(separator: "\n")
    }
  }

  private enum Constants {
    static let defaultSpacing: CGFloat = 8
    static let defaultMenuExpandedValue: CGFloat = 250
    static let menuButtonWidth: CGFloat = 90
    static let maximumMenuExpansionFactor: CGFloat = 0.6
  }

  /// The duration in seconds for menu animations.
  static let menuAnimationsDuration = 0.3

  /// The primary stack view for this view controller which can be used to layout views along side
  /// the map view and the menu (if the menu is not an overlay).
  var primaryStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  lazy var messagesView: BaseSampleViewController.MessagesView = {
    let messagesView = BaseSampleViewController.MessagesView()
    messagesView.translatesAutoresizingMaskIntoConstraints = false
    messagesView.backgroundColor = .overlay
    messagesView.numberOfLines = 0
    return messagesView
  }()

  /// If true the menu is overlaid (with a semi-transparent background) over other views; otherwise
  /// the menu is added to the primary stack view.
  ///
  /// Defaults to `true`.
  var isMenuAnOverlay = true

  /// A scroll view for the menu controls.
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    // Set an appropriate background color for the menu.
    scrollView.backgroundColor = isMenuAnOverlay ? .overlay : .systemGroupedBackground

    return scrollView
  }()

  /// The menu controls.
  private var controls: UIStackView = {
    let controls = UIStackView()
    controls.translatesAutoresizingMaskIntoConstraints = false
    controls.spacing = Constants.defaultSpacing
    controls.axis = .vertical
    controls.layoutMargins = UIEdgeInsets(
      top: Constants.defaultSpacing,
      left: Constants.defaultSpacing,
      bottom: Constants.defaultSpacing,
      right: Constants.defaultSpacing)
    controls.isLayoutMarginsRelativeArrangement = true
    return controls
  }()

  /// A button to expand/collapse the menu.
  private lazy var collapseButton: UIButton = {
    let collapseButton = UIButton(type: .custom)
    collapseButton.translatesAutoresizingMaskIntoConstraints = false
    collapseButton.setTitle("Menu", for: .normal)
    collapseButton.addTarget(self, action: #selector(touchUpInsideMenuButton), for: .touchUpInside)
    collapseButton.addTarget(
      self, action: #selector(dragged(_:event:)), for: [.touchDragInside, .touchDragOutside])
    collapseButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
    return collapseButton
  }()

  private var menuExpandedHeight: CGFloat = Constants.defaultMenuExpandedValue
  private var menuExpandedWidth: CGFloat = Constants.defaultMenuExpandedValue
  private var sharedConstraints: [NSLayoutConstraint] = []
  private var regularConstraints: [NSLayoutConstraint] = []
  private var compactConstraints: [NSLayoutConstraint] = []
  private var menuScrollViewBottomConstraint = NSLayoutConstraint()
  private var menuExpandedHeightConstraint = NSLayoutConstraint()
  private var menuExpandedWidthConstraint = NSLayoutConstraint()
  private var controlsExpandedWidthConstraint = NSLayoutConstraint()
  private var shouldToggleMenuCollapsed = true

  // MARK: - View controller methods

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add the primary stack view.
    view.addSubview(primaryStackView)

    // Add the (empty) menu and its scroll view. It's up to subclasses to populate the menu.
    if isMenuAnOverlay {
      view.addSubview(scrollView)
    } else {
      primaryStackView.addArrangedSubview(scrollView)
    }
    scrollView.addSubview(controls)

    // Add a button to collapse the UI controls area to make the map occupy the full screen.
    view.addSubview(collapseButton)

    // Add a view for messages.
    view.addSubview(messagesView)

    setupConstraints()
    layout(basedOn: UIScreen.main.traitCollection)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Register for keyboard notifications in order to adjust the UI.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    layout(basedOn: UIScreen.main.traitCollection)
  }

  // MARK: - Menu manipulation methods

  /// Adds the given `view` as a subview of the menu.
  ///
  /// Menu subviews will appear vertically stacked in the order they were added.
  func addMenuSubview(_ view: UIView) {
    controls.addArrangedSubview(view)
  }

  /// Toggles whether the menu is collased or expanded.
  ///
  /// When collapsed only the menu collapse button will be visible.
  func toggleMenuCollapsed() {
    UIView.animate(withDuration: BaseSampleViewController.menuAnimationsDuration) {
      self.menuExpandedHeightConstraint.constant =
        (self.menuExpandedHeightConstraint.constant == 0.0) ? self.menuExpandedHeight : 0.0
      self.menuExpandedWidthConstraint.constant =
        (self.menuExpandedWidthConstraint.constant == 0.0) ? self.menuExpandedWidth : 0.0
      self.view.layoutIfNeeded()
    }
  }

  /// Adjusts the menu's width/height according to the given location.
  ///
  /// The width/height will be adjusted such that the menu button will be centered at the
  /// appropriate coordinate for the current size class. The menu will only be allowed to expand so
  /// much depending on the contents of the menu and to prevent too much of the map from being
  /// covered.
  ///
  /// - Note: Due to an issue with autolayout, if the entire contents of a menu can be displayed it
  ///   cannot be expanded vertically.
  ///
  /// - Parameter location: The location to use when adjusting the menu size. The y coordinate will
  ///   be used in a compact horizontal regular vertical size class. The x coordinate is use for all
  ///   other size classes.
  func adjustMenuSize(using location: CGPoint) {
    func calculateMenuExpandedDimension(
      using viewDimension: CGFloat,
      _ locationDimension: CGFloat,
      _ buttonDimension: CGFloat,
      _ controlsDimension: CGFloat = .greatestFiniteMagnitude
    ) -> CGFloat {
      return min(
        viewDimension - locationDimension - (buttonDimension / 2),
        min(viewDimension * Constants.maximumMenuExpansionFactor, controlsDimension))
    }

    if UIScreen.main.traitCollection.horizontalSizeClass == .compact
      && UIScreen.main.traitCollection.verticalSizeClass == .regular
    {
      guard scrollView.frame.height < controls.frame.height else { return }
      let viewHeight = view.frame.height
      // Don't let the menu exceed the total controls height. For some reason that causes the app to
      // freeze.
      menuExpandedHeight = calculateMenuExpandedDimension(
        using: viewHeight, location.y, collapseButton.frame.height, controls.frame.height)
      menuExpandedHeightConstraint.constant = menuExpandedHeight
    } else {
      let viewWidth = view.frame.width
      // Don't let the menu exceed a certain width to prevent covering the map too much.
      menuExpandedWidth = calculateMenuExpandedDimension(
        using: viewWidth, location.x, collapseButton.frame.width)
      menuExpandedWidthConstraint.constant = menuExpandedWidth
      controlsExpandedWidthConstraint.constant = menuExpandedWidth
    }
  }

  // MARK: - Private

  @objc private func touchUpInsideMenuButton() {
    if shouldToggleMenuCollapsed {
      toggleMenuCollapsed()
    }
    shouldToggleMenuCollapsed = true
  }

  @objc private func dragged(_ menuButton: UIButton, event: UIEvent) {
    guard let touchLocation = event.allTouches?.randomElement()?.location(in: view) else { return }
    adjustMenuSize(using: touchLocation)
    shouldToggleMenuCollapsed = false
  }

  private func setupConstraints() {
    menuScrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    sharedConstraints = [
      primaryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      primaryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      primaryStackView.topAnchor.constraint(equalTo: view.topAnchor),
      primaryStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      menuScrollViewBottomConstraint,
      // Constrain controls to be positioned vertically inside the scroll view.
      controls.topAnchor.constraint(equalTo: scrollView.topAnchor),
      controls.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      // Menu button
      collapseButton.widthAnchor.constraint(equalToConstant: Constants.menuButtonWidth),
    ]

    menuExpandedWidthConstraint =
      scrollView.widthAnchor.constraint(equalToConstant: menuExpandedWidth)
    controlsExpandedWidthConstraint =
      controls.widthAnchor.constraint(equalToConstant: menuExpandedWidth)
    let collapseButtonTopConstraint =
      collapseButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    regularConstraints = [
      menuExpandedWidthConstraint,
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      // Constrain controls width to the expanded menu width to enforce vertical scrolling.
      controlsExpandedWidthConstraint,
      controls.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      controls.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      // Menu button
      collapseButton.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      collapseButtonTopConstraint,
      // Messages view
      messagesView.topAnchor.constraint(
        equalToSystemSpacingBelow: collapseButton.bottomAnchor,
        multiplier: 1.0),
      messagesView.widthAnchor.constraint(equalToConstant: 200),
      scrollView.leadingAnchor.constraint(
        equalToSystemSpacingAfter: messagesView.trailingAnchor,
        multiplier: 1.0),
    ]

    menuExpandedHeightConstraint =
      scrollView.heightAnchor.constraint(lessThanOrEqualToConstant: menuExpandedHeight)
    let controlsHeightConstraint = controls.heightAnchor.constraint(
      equalTo: scrollView.heightAnchor)
    controlsHeightConstraint.priority = .defaultLow
    compactConstraints = [
      scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      menuExpandedHeightConstraint,
      controlsHeightConstraint,
      // Constrain controls width to the main view to enforce vertical scrolling.
      controls.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      controls.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      // Menu button
      collapseButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      collapseButton.bottomAnchor.constraint(equalTo: scrollView.topAnchor),
      // Messages view
      messagesView.leadingAnchor.constraint(
        equalToSystemSpacingAfter: view.leadingAnchor,
        multiplier: 1.0),
      collapseButton.leadingAnchor.constraint(
        equalToSystemSpacingAfter: messagesView.trailingAnchor,
        multiplier: 1.0),
      scrollView.topAnchor.constraint(
        equalToSystemSpacingBelow: messagesView.bottomAnchor,
        multiplier: 1.0),
    ]
  }

  private func layout(basedOn traitCollection: UITraitCollection) {
    if !sharedConstraints[0].isActive {
      NSLayoutConstraint.activate(sharedConstraints)
    }

    if traitCollection.horizontalSizeClass == .compact
      && traitCollection.verticalSizeClass == .regular
    {
      primaryStackView.axis = .vertical
      if regularConstraints.count > 0 && regularConstraints[0].isActive {
        NSLayoutConstraint.deactivate(regularConstraints)
      }
      NSLayoutConstraint.activate(compactConstraints)
    } else {
      primaryStackView.axis = .horizontal
      if compactConstraints.count > 0 && compactConstraints[0].isActive {
        NSLayoutConstraint.deactivate(compactConstraints)
      }
      NSLayoutConstraint.activate(regularConstraints)
    }
  }

  @objc private func keyboardWillShow(notification: NSNotification) {
    animateWithKeyboard(notification: notification) { keyboardFrame in
      self.menuScrollViewBottomConstraint.constant = -keyboardFrame.height
    }
  }

  @objc private func keyboardWillHide(notification: NSNotification) {
    animateWithKeyboard(notification: notification) { keyboardFrame in
      self.menuScrollViewBottomConstraint.constant = 0
    }
  }

  private func animateWithKeyboard(
    notification: NSNotification,
    animations: @escaping ((_ keyboardFrame: CGRect) -> Void)
  ) {
    guard let userInfo = notification.userInfo else { return }
    guard let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
      return
    }
    let animationDuration =
      userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
    let animationCurveRawValue =
      (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int)
      ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue)
    let animationCurve = UIView.AnimationOptions(rawValue: UInt(animationCurveRawValue))
    UIView.animate(
      withDuration: animationDuration,
      delay: TimeInterval(0),
      options: animationCurve,
      animations: {
        animations(endFrame)
        self.view.layoutIfNeeded()
      },
      completion: nil)
  }
}

extension TimeInterval {
  var toNanoseconds: UInt64 {
    UInt64(self * 1E9)
  }
}

extension UIColor {
  static let overlay = UIColor {
    ($0.userInterfaceStyle == .dark)
      ? UIColor(white: 0, alpha: 0.75) : UIColor(white: 1, alpha: 0.75)
  }
}
