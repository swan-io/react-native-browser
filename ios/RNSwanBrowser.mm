#import "RNSwanBrowser.h"

#import <React/RCTConvert.h>
#import <SafariServices/SafariServices.h>

@implementation RNSwanBrowser

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

#ifdef RCT_NEW_ARCH_ENABLED
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

#else
RCT_EXPORT_METHOD(open:(NSString *)url
                  options:(NSDictionary * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

  NSString *animationType = [options valueForKey:@"animationType"];
  NSString *dismissButtonStyle = [options valueForKey:@"dismissButtonStyle"];
  NSNumber *barTintColor = [options valueForKey:@"barTintColor"];
  NSNumber *controlTintColor = [options valueForKey:@"controlTintColor"];

#endif
  @try {
    SFSafariViewControllerConfiguration *config = [SFSafariViewControllerConfiguration new];
    [config setBarCollapsingEnabled:false];
    [config setEntersReaderIfAvailable:false];

    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url] configuration:config];

    if (dismissButtonStyle == nil || [dismissButtonStyle isEqualToString:@"close"]) {
      [safari setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleClose];
    } else if ([dismissButtonStyle isEqualToString:@"cancel"]) {
      [safari setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleCancel];
    } else if ([dismissButtonStyle isEqualToString:@"done"]) {
      [safari setDismissButtonStyle:SFSafariViewControllerDismissButtonStyleDone];
    }

    if (barTintColor != nil) {
      [safari setPreferredBarTintColor:[RCTConvert UIColor:barTintColor]];
    }
    if (controlTintColor != nil) {
      [safari setPreferredControlTintColor:[RCTConvert UIColor:controlTintColor]];
    }

    if (animationType != nil && [animationType isEqualToString:@"fade"]) {
      [safari setModalPresentationStyle:UIModalPresentationOverFullScreen];
      [safari setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    } else {
      [safari setModalPresentationStyle:UIModalPresentationPageSheet];
    }

    [RCTPresentedViewController() presentViewController:safari animated:true completion:nil];

    resolve(nil);
  } @catch (NSException *exception) {
    reject(exception.name, exception.reason, nil);
  }
}

@end
