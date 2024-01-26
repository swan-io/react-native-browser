# @swan-io/react-native-browser

[![mit licence](https://img.shields.io/dub/l/vibe-d.svg?style=for-the-badge)](https://github.com/swan-io/react-native-browser/blob/main/LICENSE)
[![npm version](https://img.shields.io/npm/v/@swan-io/react-native-browser?style=for-the-badge)](https://www.npmjs.org/package/@swan-io/react-native-browser)
[![bundlephobia](https://img.shields.io/bundlephobia/minzip/@swan-io/react-native-browser?label=size&style=for-the-badge)](https://bundlephobia.com/result?p=@swan-io/react-native-browser)
<br />
[![platform - android](https://img.shields.io/badge/platform-Android-3ddc84.svg?logo=android&style=for-the-badge)](https://www.android.com)
[![platform - ios](https://img.shields.io/badge/platform-iOS-000.svg?logo=apple&style=for-the-badge)](https://developer.apple.com/ios)

<p>
  <img width="261" src="./docs/demo.png" alt="Demo">
</p>

## Installation

```bash
$ yarn add @swan-io/react-native-browser
# --- or ---
$ npm install --save @swan-io/react-native-browser
```

## Quickstart

```tsx
import { openSwanBrowser } from "@swan-io/react-native-browser";
import { useCallback } from "react";
import { Button, SafeAreaView } from "react-native";
import parseUrl from "url-parse";

const App = () => {
  const handleOnPress = useCallback(() => {
    openSwanBrowser("https://swan.io", {
      onClose: (url) => {
        if (typeof url !== "undefined") {
          const parsed = parseUrl(url, true); // parse query params
          console.log("Parsed deeplink:", JSON.stringify(parsed, null, 2));
        }
      },
    }).catch((error) => {
      console.error(error);
    });
  }, []);

  return (
    <SafeAreaView>
      <Button title="Open browser" onPress={handleOnPress} />
    </SafeAreaView>
  );
};
```

## API

### openSwanBrowser

```tsx
import { openSwanBrowser } from "react-ux-form";

openSwanBrowser("https://swan.io", {
  dismissButtonStyle: "close", // "cancel" | "close" | "done" (default to "close")
  barTintColor: "#FFF", // in-app browser UI background color
  controlTintColor: "#000", // in-app browser buttons color
  onOpen: () => {
    // fired on browser opened
    // useful to switch the StatusBar color
  },
  onClose: (url) => {
    // fired on browser closed
    // url will be defined if the browser has been closed via deeplink
  },
}).catch((error) => {
  console.error(error);
});
```

## Handle deeplinks

In order to capture deeplink on browser close event, you have to setup deeplinks. We highty recommand defining a custom schema + url for this specific task. For example, `com.company.myapp://close`.

Once the redirect URI is hit (on your server), you can handle the result and perform a server redirect to `com.company.myapp://close?success=true&any=infos` (and pass any data you want back to your app using query params).

### On iOS

First, you need to [enable deeplinks support](https://reactnative.dev/docs/linking#enabling-deep-links).

Then edit your `Info.plist`:

```
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Viewer</string>
    <key>CFBundleURLName</key>
    <string>com.company.myapp</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.company.myapp</string>
    </array>
  </dict>
</array>
```

### On Android

Edit your `AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.BROWSABLE" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:scheme="com.company.myapp" android:host="close" />
  </intent-filter>
</activity>
```

- 📘 [**Documentation**](https://developer.android.com/training/app-links/deep-linking)

## Run the example app

```bash
$ git clone git@github.com:swan-io/react-native-browser.git
$ cd react-native-browser/example

$ yarn install && yarn start
# --- or ---
$ npm install && npm run start
```
