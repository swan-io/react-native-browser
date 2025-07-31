package io.swan.rnbrowser

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RNSwanBrowserModuleImpl.NAME)
class RNSwanBrowserModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return RNSwanBrowserModuleImpl.NAME
  }

  @ReactMethod
  fun open(url: String, options: ReadableMap, promise: Promise) {
    RNSwanBrowserModuleImpl.open(reactApplicationContext, url, options, promise)
  }
}
