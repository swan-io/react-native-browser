#import "RNSwanBrowser.h"

#import <React/RCTConvert.h>
#import <SafariServices/SafariServices.h>

@interface RNSwanBrowser() <SFSafariViewControllerDelegate, UIAdaptivePresentationControllerDelegate>

@property (nonatomic, strong) SFSafariViewController *safariVC;

@end

@implementation RNSwanBrowser

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (void)handleOnClose {
  _safariVC = nil;
  [self emitOnClose:true];
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)controller {
  [self handleOnClose];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [self handleOnClose];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNSwanBrowserSpecJSI>(params);
}

- (void)open:(NSString *)url
     options:(JS::NativeRNSwanBrowser::Options &)options
     resolve:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject {

  NSString *animationType = options.animationType();
  NSString *dismissButtonStyle = options.dismissButtonStyle();
  NSNumber *barTintColor = options.barTintColor().has_value() ? [NSNumber numberWithDouble:options.barTintColor().value()] : nil;
  NSNumber *controlTintColor = options.controlTintColor().has_value() ? [NSNumber numberWithDouble:options.controlTintColor().value()] : nil;

  if (_safariVC != nil) {
    return reject(@"swan_browser_visible", @"An instance of the swan browser is already visible", nil);
  }

  @try {
    SFSafariViewControllerConfiguration *config = [SFSafariViewControllerConfiguration new];
    [config setBarCollapsingEnabled:false];
    [config setEntersReaderIfAvailable:false];

    _safariVC = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url] configuration:config];

    if (dismissButtonStyle == nil || [dismissButtonStyle isEqualToString:@"close"]) {
      [_safariVC setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleClose];
    } else if ([dismissButtonStyle isEqualToString:@"cancel"]) {
      [_safariVC setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleCancel];
    } else if ([dismissButtonStyle isEqualToString:@"done"]) {
      [_safariVC setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleDone];
    }

    if (barTintColor != nil) {
      [_safariVC setPreferredBarTintColor:[RCTConvert UIColor:barTintColor]];
    }
    if (controlTintColor != nil) {
      [_safariVC setPreferredControlTintColor:[RCTConvert UIColor:controlTintColor]];
    }

    if (animationType != nil && [animationType isEqualToString:@"fade"]) {
      [_safariVC setModalPresentationStyle:UIModalPresentationOverFullScreen];
      [_safariVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    } else {
      [_safariVC setModalPresentationStyle:UIModalPresentationPageSheet];
    }

    [RCTPresentedViewController() presentViewController:_safariVC animated:true completion:nil];

    _safariVC.delegate = self;
    _safariVC.presentationController.delegate = self;

    resolve(nil);
  } @catch (NSException *exception) {
    _safariVC = nil;
    reject(exception.name, exception.reason, nil);
  }
}

- (void)close {
  if (_safariVC != nil) {
    [RCTPresentedViewController() dismissViewControllerAnimated:true completion:^{
      [self handleOnClose];
    }];
  }
}

@end
