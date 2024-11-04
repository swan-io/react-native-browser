package io.swan.rnbrowser

import android.content.Intent
import android.net.Uri

import androidx.annotation.ColorInt
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat
import androidx.core.graphics.ColorUtils

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter

import io.swan.rnbrowser.helpers.CustomTabActivityHelper

object RNSwanBrowserModuleImpl {
  const val NAME = "RNSwanBrowser"
  private var browserVisible = false

  internal fun onHostResume(reactContext: ReactApplicationContext) {
    if (browserVisible && reactContext.hasActiveReactInstance()) {
      browserVisible = false

      reactContext
        .getJSModule(RCTDeviceEventEmitter::class.java)
        .emit("swanBrowserDidClose", null)
    }
  }

  internal fun open(
    reactContext: ReactApplicationContext,
    url: String,
    options: ReadableMap,
    promise: Promise
  ) {
    if (browserVisible) {
      return promise.reject(
        "swan_browser_visible",
        "An instance of the swan browser is already visible"
      )
    }

    val activity = reactContext.currentActivity
      ?: return promise.reject(
        "no_current_activity",
        "Couldn't call open() when the app is in background"
      )

    browserVisible = true

    val intentBuilder = CustomTabsIntent.Builder().apply {
      setBookmarksButtonEnabled(false)
      setDownloadButtonEnabled(false)
      setInstantAppsEnabled(false)
      setSendToExternalDefaultHandlerEnabled(false)
      setShowTitle(false)

      if (options.getString("animationType") == "fade") {
        setStartAnimations(activity, com.facebook.react.R.anim.catalyst_fade_in, R.anim.inert)
        setExitAnimations(activity, R.anim.inert, com.facebook.react.R.anim.catalyst_fade_out)
      } else {
        setStartAnimations(activity, com.facebook.react.R.anim.catalyst_slide_up, R.anim.inert)
        setExitAnimations(activity, R.anim.inert, com.facebook.react.R.anim.catalyst_slide_down)
      }
    }

    @ColorInt val blackColor = ContextCompat.getColor(activity ,android.R.color.black)

    val paramsBuilder = CustomTabColorSchemeParams.Builder().apply {
      setNavigationBarColor(blackColor)

      if (options.hasKey("barTintColor")) {
        @ColorInt val barTintColor = options.getInt("barTintColor")

        setToolbarColor(barTintColor)
        setSecondaryToolbarColor(barTintColor)

        intentBuilder.setColorScheme(
          when (ColorUtils.calculateLuminance(barTintColor) > 0.5) {
            true -> CustomTabsIntent.COLOR_SCHEME_LIGHT
            false -> CustomTabsIntent.COLOR_SCHEME_DARK
          }
        )
      }
    }

    intentBuilder.setDefaultColorSchemeParams(paramsBuilder.build())

    val customTabsIntent = intentBuilder.build().apply {
      intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
      intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }

    CustomTabActivityHelper.openCustomTab(
      activity, customTabsIntent, Uri.parse(url)
    ) { currentActivity, uri ->
      currentActivity.startActivity(Intent(Intent.ACTION_VIEW, uri))
    }

    promise.resolve(null)
  }
}
