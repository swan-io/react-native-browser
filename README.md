# @swan-io/react-native-browser

An easy-to-use in-app browser module for React Native, powered by **[Chrome Custom Tabs](https://developer.chrome.com/docs/android/custom-tabs)** / **[SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)**.

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
import { openBrowser } from "@swan-io/react-native-browser";
import { useCallback } from "react";
import { Button, SafeAreaView } from "react-native";
import parseUrl from "url-parse";

const App = () => {
  const handleOnPress = useCallback(() => {
    openBrowser("https://swan.io", {
      onClose: (url) => {
        if (url) {
          const { protocol, host, query } = parseUrl(url, true);
          const origin = `${protocol}//${host}`;

          if (origin === "com.company.myapp://close") {
            console.log(JSON.stringify(query, null, 2));
          }
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

### openBrowser(url: string, options: Options)

```tsx
import { openBrowser } from "@swan-io/react-native-browser";

openBrowser("https://swan.io", {
  animationType: "", // "fade" | "slide" (default to "slide")
  dismissButtonStyle: "close", // "cancel" | "close" | "done" (default to "close")
  barTintColor: "#FFF", // in-app browser UI background color
  controlTintColor: "#000", // in-app browser buttons color
  onOpen: () => {
    // fired on browser opened
    // useful to switch the StatusBar color, for example
  },
  onClose: (url) => {
    // fired on browser closed
    // url will be defined if the browser has been closed via deeplink
  },
}).catch((error) => {
  console.error(error);
});
```

> [!IMPORTANT]
> On Android, the Chrome app must be opened at least once for this to work — a step often overlooked when using emulators in development.

## Handle deeplinks

In order to receive deeplink on browser close event, you have to setup them first. We **highly** recommand defining a custom schema + url for this specific task. For example, `com.company.myapp://close`.

### On iOS

First, you need to **[enable react-native deeplinks support](https://reactnative.dev/docs/linking#enabling-deep-links)**. Then, edit your `Info.plist` file to add:

```xml
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

Edit your `AndroidManifest.xml` to add ([more documentation](https://developer.android.com/training/app-links/deep-linking)):

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

> [!TIP]
> Once the redirect URL is visited (a `GET` hits your server), handle the result and perform a server redirect to `com.company.myapp://close?success=true` to close the browser (and pass any data back to your app using query params ✨).

## Run the example app

```bash
$ git clone git@github.com:swan-io/react-native-browser.git
$ cd react-native-browser/example

$ yarn install && yarn start
# --- or ---
$ npm install && npm run start
```
