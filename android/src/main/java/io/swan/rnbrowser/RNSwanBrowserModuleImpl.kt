package io.swan.rnbrowser

import android.content.Intent
import android.os.Build

import androidx.annotation.ColorInt
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat
import androidx.core.graphics.ColorUtils
import androidx.core.net.toUri

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap

import io.swan.rnbrowser.helpers.CustomTabActivityHelper

object RNSwanBrowserModuleImpl {
  const val NAME = "RNSwanBrowser"
  const val ON_CLOSE_EVENT = "swanBrowserOnClose"

  internal fun open(
    reactContext: ReactApplicationContext,
    url: String,
    options: ReadableMap,
    promise: Promise
  ): Boolean {
    val activity = reactContext.currentActivity
      ?: return promise.reject(
        "no_current_activity",
        "Couldn't call open() when the app is in background"
      ).let { false }

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
      // FLAG_ACTIVITY_SINGLE_TOP prevents multiple browser instances from stacking,
      // but causes Custom Tabs to close immediately on Android 13 and below
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
      }
    }

    CustomTabActivityHelper.openCustomTab(
      activity, customTabsIntent, url.toUri()
    ) { currentActivity, uri ->
      currentActivity.startActivity(Intent(Intent.ACTION_VIEW, uri))
    }

    promise.resolve(null)
    return true
  }
}
