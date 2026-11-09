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
    if let safariVC {
      if safariVC.presentingViewController != nil {
        return reject("swan_browser_visible", "An instance of the swan browser is already visible")
      }
      // The browser was dismissed without any delegate callback (e.g. along with a parent
      // modal): report it as closed instead of staying locked.
      handleOnClose()
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

    safariVC.delegate = self
    safariVC.presentationController?.delegate = self

    presenter.present(safariVC, animated: true)

    // present(_:animated:) fails without an error, e.g. when the presenter is mid-transition.
    // On success, presentingViewController is set as soon as present returns.
    guard safariVC.presentingViewController != nil else {
      return reject("swan_browser_present_failed", "Could not present the swan browser")
    }

    self.safariVC = safariVC
    resolve()
  }

  @objc public func close() {
    guard let safariVC else {
      return
    }

    // Already dismissed without any delegate callback: dismiss() would be a no-op and its
    // completion would never run.
    guard safariVC.presentingViewController != nil else {
      return handleOnClose()
    }

    safariVC.dismiss(animated: true) { [weak self] in
      if let self, self.safariVC === safariVC {
        self.handleOnClose()
      }
    }
  }

  private func handleOnClose() {
    safariVC = nil
    onClose()
  }
}

extension RNSwanBrowserImpl: SFSafariViewControllerDelegate {
  public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    if controller === safariVC {
      handleOnClose()
    }
  }
}

extension RNSwanBrowserImpl: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if presentationController.presentedViewController === safariVC {
      handleOnClose()
    }
  }
}
