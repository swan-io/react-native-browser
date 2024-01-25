#import "RNSwanBrowser.h"

#import <React/RCTConvert.h>

@import SafariServices;

@interface RNSwanBrowser() <SFSafariViewControllerDelegate, UIAdaptivePresentationControllerDelegate>

@property (nonatomic, strong) SFSafariViewController *safariVC;

@end

@implementation RNSwanBrowser {
  bool hasListeners;
}

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"swanBrowserDidClose"];
}

- (void)handleOnClose {
  _safariVC = nil;

  if (hasListeners) {
    [self sendEventWithName:@"swanBrowserDidClose" body:nil];
  }
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)controller {
  [self handleOnClose];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [self handleOnClose];
}

RCT_EXPORT_METHOD(open:(NSString *)url
                  options:(NSDictionary * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  if (_safariVC != nil) {
    return reject(@"swan_browser_visible", @"An instance of the swan browser is already visible", nil);
  }

  @try {
    NSString *dismissButtonStyle = [options valueForKey:@"dismissButtonStyle"];
    NSNumber *barTintColor = [options valueForKey:@"barTintColor"];
    NSNumber *controlTintColor = [options valueForKey:@"controlTintColor"];

    SFSafariViewControllerConfiguration *config = [SFSafariViewControllerConfiguration new];
    [config setBarCollapsingEnabled:false];
    [config setEntersReaderIfAvailable:false];

    _safariVC = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url] configuration:config];

    if (dismissButtonStyle == nil) {
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

    [_safariVC setModalPresentationStyle:UIModalPresentationPageSheet];
    [RCTPresentedViewController() presentViewController:_safariVC animated:true completion:nil];

    _safariVC.delegate = self;
    _safariVC.presentationController.delegate = self;

    resolve(nil);
  } @catch (NSException *exception) {
    reject(exception.name, exception.reason, nil);
  }
}

RCT_EXPORT_METHOD(close) {
  if (_safariVC != nil) {
    [RCTPresentedViewController() dismissViewControllerAnimated:true completion:^{
      [self handleOnClose];
    }];
  }
}

@end
