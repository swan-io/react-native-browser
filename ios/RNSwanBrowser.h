#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED

#import <RNSwanBrowserSpec/RNSwanBrowserSpec.h>

@interface RNSwanBrowser : RCTEventEmitter <NativeRNSwanBrowserSpec>
@end

#else

#import <React/RCTBridgeModule.h>

@interface RNSwanBrowser : RCTEventEmitter <RCTBridgeModule>
@end

#endif
