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

## Links

- ⚖️ [**License**](./LICENSE)

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

## Run the example app

```bash
$ git clone git@github.com:swan-io/react-native-browser.git
$ cd react-native-browser/example

$ yarn install && yarn start
# --- or ---
$ npm install && npm run start
```
