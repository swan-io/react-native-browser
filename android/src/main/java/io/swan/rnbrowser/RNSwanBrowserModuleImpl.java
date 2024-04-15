package io.swan.rnbrowser;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.ColorInt;
import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.graphics.ColorUtils;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter;

import io.swan.rnbrowser.helpers.CustomTabActivityHelper;

public class RNSwanBrowserModuleImpl {

  static final String NAME = "RNSwanBrowser";

  protected static void onHostResume(final ReactApplicationContext reactContext) {
    if (reactContext.hasActiveReactInstance()) {
      reactContext
        .getJSModule(RCTDeviceEventEmitter.class)
        .emit("swanBrowserDidClose", null);
    }
  }

  protected static void open(final Activity activity,
                             final String url,
                             final Double barTintColor,
                             final Promise promise) {
    CustomTabsIntent.Builder intentBuilder = new CustomTabsIntent.Builder();
    intentBuilder.setShowTitle(false);
    intentBuilder.setInstantAppsEnabled(false);

    intentBuilder.setStartAnimations(activity,
      com.facebook.react.R.anim.catalyst_slide_up, io.swan.rnbrowser.R.anim.inert);
    intentBuilder.setExitAnimations(activity,
      io.swan.rnbrowser.R.anim.inert, com.facebook.react.R.anim.catalyst_slide_down);

    @ColorInt int blackColor = activity.getResources().getColor(android.R.color.black);
    CustomTabColorSchemeParams.Builder paramsBuilder = new CustomTabColorSchemeParams.Builder();
    paramsBuilder.setNavigationBarColor(blackColor);

    if (barTintColor != null) {
      @ColorInt int intValue = barTintColor.intValue();

      paramsBuilder.setToolbarColor(intValue);
      paramsBuilder.setSecondaryToolbarColor(intValue);

      intentBuilder.setColorScheme(ColorUtils.calculateLuminance(intValue) > 0.5
        ? CustomTabsIntent.COLOR_SCHEME_LIGHT
        : CustomTabsIntent.COLOR_SCHEME_DARK);
    }

    intentBuilder.setDefaultColorSchemeParams(paramsBuilder.build());
    CustomTabsIntent customTabsIntent = intentBuilder.build();

    customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
    customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);

    CustomTabActivityHelper.openCustomTab(activity, customTabsIntent, Uri.parse(url),
      new CustomTabActivityHelper.CustomTabFallback() {
      @Override
      public void openUri(Activity activity, Uri uri) {
        activity.startActivity(new Intent(Intent.ACTION_VIEW, uri));
      }
    });

    promise.resolve(null);
  }
}
