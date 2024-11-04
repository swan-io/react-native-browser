package io.swan.rnbrowser

import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RNSwanBrowserModuleImpl.NAME)
class RNSwanBrowserModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext),
  LifecycleEventListener {

  init {
    reactApplicationContext.addLifecycleEventListener(this)
  }

  override fun invalidate() {
    reactApplicationContext.removeLifecycleEventListener(this)
  }

  override fun getName(): String {
    return RNSwanBrowserModuleImpl.NAME
  }

  override fun onHostResume() {
    RNSwanBrowserModuleImpl.onHostResume(reactApplicationContext)
  }

  override fun onHostPause() {}

  override fun onHostDestroy() {}

  @ReactMethod
  fun open(url: String, options: ReadableMap, promise: Promise) {
    RNSwanBrowserModuleImpl.open(reactApplicationContext, url, options, promise)
  }

  @ReactMethod
  fun close() {
    // noop on Android since the modal is closed by deep-link
  }

  @ReactMethod
  fun addListener(eventName: String) {
    // iOS only
  }

  @ReactMethod
  fun removeListeners(count: Double) {
    // iOS only
  }
}
