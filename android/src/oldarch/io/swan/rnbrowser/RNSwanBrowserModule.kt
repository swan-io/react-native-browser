package io.swan.rnbrowser

import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RNSwanBrowserModuleImpl.NAME)
class RNSwanBrowserModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext),
  LifecycleEventListener {

  private var awaitingClose = false

  init {
    reactContext.addLifecycleEventListener(this)
  }

  override fun getName(): String {
    return RNSwanBrowserModuleImpl.NAME
  }

  @ReactMethod
  fun open(url: String, options: ReadableMap, promise: Promise) {
    awaitingClose = RNSwanBrowserModuleImpl.open(
      reactApplicationContext,
      url,
      options,
      promise
    )
  }

  @ReactMethod
  fun close() {
    // noop on Android since the modal is closed by deep-link
  }

  @ReactMethod
  fun addListener(eventName: String) {
    // Required for NativeEventEmitter support.
  }

  @ReactMethod
  fun removeListeners(count: Double) {
    // Required for NativeEventEmitter support.
  }

  override fun onHostResume() {
    if (!awaitingClose) return
    awaitingClose = false
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(RNSwanBrowserModuleImpl.ON_CLOSE_EVENT, null)
  }

  override fun onHostPause() {
    // no-op
  }

  override fun onHostDestroy() {
    // no-op
  }
}
