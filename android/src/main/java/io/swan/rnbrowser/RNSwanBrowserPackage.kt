package io.swan.rnbrowser

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class RNSwanBrowserPackage : TurboReactPackage() {

  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return when (name) {
      RNSwanBrowserModuleImpl.NAME -> RNSwanBrowserModule(reactContext)
      else -> null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      val isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED

      val moduleInfo = ReactModuleInfo(
        RNSwanBrowserModuleImpl.NAME,
        RNSwanBrowserModuleImpl.NAME,
        false,
        false,
        true,
        false,
        isTurboModule
      )

      moduleInfos[RNSwanBrowserModuleImpl.NAME] = moduleInfo
      moduleInfos
    }
  }
}
