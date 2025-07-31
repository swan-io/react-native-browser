#ifdef RCT_NEW_ARCH_ENABLED

#import <RNSwanBrowserSpec/RNSwanBrowserSpec.h>

@interface RNSwanBrowser : NSObject <NativeRNSwanBrowserSpec>
@end

#else

#import <React/RCTBridgeModule.h>

@interface RNSwanBrowser : NSObject <RCTBridgeModule>
@end

#endif
