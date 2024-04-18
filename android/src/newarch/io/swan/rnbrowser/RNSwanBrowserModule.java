package io.swan.rnbrowser;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = RNSwanBrowserModuleImpl.NAME)
public class RNSwanBrowserModule extends NativeRNSwanBrowserSpec implements LifecycleEventListener {

  private boolean mBrowserVisible = false;

  public RNSwanBrowserModule(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addLifecycleEventListener(this);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @Override
  public void onHostResume() {
    if (mBrowserVisible) {
      RNSwanBrowserModuleImpl.onHostResume(getReactApplicationContext());
      mBrowserVisible = false;
    }
  }

  @Override
  public void onHostPause() {}

  @Override
  public void onHostDestroy() {}

  @Override
  public void open(String url,
                   Double barTintColor,
                   Double controlTintColor,
                   @Nullable String dismissButtonStyle,
                   Promise promise) {
    if (mBrowserVisible) {
      promise.reject("swan_browser_visible",
        "An instance of the swan browser is already visible");
      return;
    }

    final Activity activity = getReactApplicationContext().getCurrentActivity();

    if (activity == null) {
      promise.reject("no_current_activity",
        "Couldn't call open() when the app is in background");
      return;
    }

    mBrowserVisible = true;
    RNSwanBrowserModuleImpl.open(activity, url, barTintColor, promise);
  }

  @Override
  public void close() {
    // noop on Android since the modal is closed by deep-link
  }

  @Override
  public void addListener(String eventName) {
    // iOS only
  }

  @Override
  public void removeListeners(double count) {
    // iOS only
  }

  @Override
  public void invalidate() {
    super.invalidate();
    getReactApplicationContext().removeLifecycleEventListener(this);
  }
}
