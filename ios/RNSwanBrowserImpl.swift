import SafariServices
import UIKit

/// Presents and dismisses the in-app browser (SFSafariViewController).
///
/// React Native glue (TurboModule spec, legacy bridge, events, color conversion) lives in
/// RNSwanBrowser.mm, which forwards to this class. All methods must be called on the main queue.
@objc(RNSwanBrowserImpl)
public final class RNSwanBrowserImpl: NSObject {
  private var safariVC: SFSafariViewController?
  private let onClose: () -> Void

  @objc(initWithOnClose:)
  public init(onClose: @escaping () -> Void) {
    self.onClose = onClose
    super.init()
  }

  @objc public func open(
    _ url: String,
    animationType: String?,
    dismissButtonStyle: String?,
    barTintColor: UIColor?,
    controlTintColor: UIColor?,
    presenter: UIViewController?,
    resolve: () -> Void,
    reject: (_ code: String, _ message: String) -> Void
  ) {
    if safariVC != nil {
      return reject("swan_browser_visible", "An instance of the swan browser is already visible")
    }

    // SFSafariViewController raises an Objective-C exception for anything other than an
    // http(s) URL, which Swift cannot catch: validate up front instead.
    guard let parsedURL = URL(string: url),
          let scheme = parsedURL.scheme?.lowercased(),
          scheme == "http" || scheme == "https"
    else {
      return reject("swan_browser_invalid_url", "Only http and https URLs are supported, got: \(url)")
    }

    guard let presenter else {
      return reject("swan_browser_no_presenter", "No view controller is available to present the swan browser")
    }

    let config = SFSafariViewController.Configuration()
    config.barCollapsingEnabled = false
    config.entersReaderIfAvailable = false

    let safariVC = SFSafariViewController(url: parsedURL, configuration: config)

    switch dismissButtonStyle {
    case "cancel":
      safariVC.dismissButtonStyle = .cancel
    case "done":
      safariVC.dismissButtonStyle = .done
    default:
      safariVC.dismissButtonStyle = .close
    }

    if let barTintColor {
      safariVC.preferredBarTintColor = barTintColor
    }
    if let controlTintColor {
      safariVC.preferredControlTintColor = controlTintColor
    }

    if animationType == "fade" {
      safariVC.modalPresentationStyle = .overFullScreen
      safariVC.modalTransitionStyle = .crossDissolve
    } else {
      safariVC.modalPresentationStyle = .pageSheet
    }

    self.safariVC = safariVC
    presenter.present(safariVC, animated: true)

    safariVC.delegate = self
    safariVC.presentationController?.delegate = self

    resolve()
  }

  @objc public func close() {
    guard let safariVC else {
      return
    }

    safariVC.dismiss(animated: true) { [weak self] in
      self?.handleOnClose()
    }
  }

  private func handleOnClose() {
    safariVC = nil
    onClose()
  }
}

extension RNSwanBrowserImpl: SFSafariViewControllerDelegate {
  public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    handleOnClose()
  }
}

extension RNSwanBrowserImpl: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    handleOnClose()
  }
}
