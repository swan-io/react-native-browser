package io.swan.rnbrowser;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.TurboReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.model.ReactModuleInfo;
import com.facebook.react.module.model.ReactModuleInfoProvider;

import java.util.HashMap;
import java.util.Map;

public class RNSwanBrowserPackage extends TurboReactPackage {

  @Nullable
  @Override
  public NativeModule getModule(String name, @NonNull ReactApplicationContext reactContext) {
    if (name.equals(RNSwanBrowserModuleImpl.NAME)) {
      return new RNSwanBrowserModule(reactContext);
    } else {
      return null;
    }
  }

  @Override
  public ReactModuleInfoProvider getReactModuleInfoProvider() {
    return () -> {
      final Map<String, ReactModuleInfo> moduleInfos = new HashMap<>();
      boolean isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED;

      ReactModuleInfo moduleInfo = new ReactModuleInfo(
        RNSwanBrowserModuleImpl.NAME,
        RNSwanBrowserModuleImpl.NAME,
        false,
        false,
        true,
        false,
        isTurboModule
      );

      moduleInfos.put(RNSwanBrowserModuleImpl.NAME, moduleInfo);
      return moduleInfos;
    };
  }
}
