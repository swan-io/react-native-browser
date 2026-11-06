#import "RNSwanBrowser.h"

#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import <SafariServices/SafariServices.h>

// The generated Swift header declares SafariServices delegate conformances, so the import above
// must come first.
#if __has_include("RNSwanBrowser-Swift.h")
#import "RNSwanBrowser-Swift.h"
#else
#import <RNSwanBrowser/RNSwanBrowser-Swift.h>
#endif

// React Native glue only: the browser itself is implemented in RNSwanBrowserImpl.swift.
// The TurboModule spec is a C++ protocol, so this layer has to stay in Objective-C++.

static NSString *const RNSwanBrowserOnCloseEvent = @"swanBrowserOnClose";

@implementation RNSwanBrowser {
  RNSwanBrowserImpl *_impl;
  BOOL _hasListeners;
}

RCT_EXPORT_MODULE();

- (instancetype)init {
  if (self = [super init]) {
    __weak RNSwanBrowser *weakSelf = self;
    _impl = [[RNSwanBrowserImpl alloc] initWithOnClose:^{
      [weakSelf handleOnClose];
    }];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
  return @[RNSwanBrowserOnCloseEvent];
}

- (void)startObserving {
  _hasListeners = YES;
}

- (void)stopObserving {
  _hasListeners = NO;
}

- (void)handleOnClose {
  if (_hasListeners) {
    [self sendEventWithName:RNSwanBrowserOnCloseEvent body:nil];
  }
}

- (void)openURL:(NSString *)url
  animationType:(NSString *)animationType
dismissButtonStyle:(NSString *)dismissButtonStyle
   barTintColor:(NSNumber *)barTintColor
controlTintColor:(NSNumber *)controlTintColor
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  [_impl open:url
       animationType:animationType
  dismissButtonStyle:dismissButtonStyle
        barTintColor:barTintColor != nil ? [RCTConvert UIColor:barTintColor] : nil
    controlTintColor:controlTintColor != nil ? [RCTConvert UIColor:controlTintColor] : nil
           presenter:RCTPresentedViewController()
             resolve:^{
               resolve(nil);
             }
              reject:^(NSString *code, NSString *message) {
                reject(code, message, nil);
              }];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNSwanBrowserSpecJSI>(params);
}

- (void)open:(NSString *)url
     options:(JS::NativeRNSwanBrowser::Options &)options
     resolve:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject {
  [self openURL:url
       animationType:options.animationType()
  dismissButtonStyle:options.dismissButtonStyle()
        barTintColor:options.barTintColor().has_value() ? @(options.barTintColor().value()) : nil
    controlTintColor:options.controlTintColor().has_value() ? @(options.controlTintColor().value()) : nil
             resolve:resolve
              reject:reject];
}

- (void)close {
  [_impl close];
}

- (void)addListener:(NSString *)eventName {
  [super addListener:eventName];
}

- (void)removeListeners:(double)count {
  [super removeListeners:count];
}
#else
RCT_EXPORT_METHOD(open:(NSString *)url
                  options:(NSDictionary * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [self openURL:url
       animationType:options[@"animationType"]
  dismissButtonStyle:options[@"dismissButtonStyle"]
        barTintColor:options[@"barTintColor"]
    controlTintColor:options[@"controlTintColor"]
             resolve:resolve
              reject:reject];
}

RCT_EXPORT_METHOD(close) {
  [_impl close];
}

RCT_EXPORT_METHOD(addListener:(NSString *)eventName) {
  [super addListener:eventName];
}

RCT_EXPORT_METHOD(removeListeners:(double)count) {
  [super removeListeners:count];
}
#endif

@end
