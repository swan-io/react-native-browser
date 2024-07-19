import { openBrowser } from "@swan-io/react-native-browser";
import * as React from "react";
import {
  Button,
  Platform,
  SafeAreaView,
  StatusBar,
  StatusBarProps,
  StyleSheet,
} from "react-native";
import parseUrl from "url-parse";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
});

export const App = () => {
  const handleOnPress = React.useCallback(() => {
    let entry: StatusBarProps | undefined;

    openBrowser("https://swan.io", {
      animationType: "slide",
      dismissButtonStyle: "close",
      barTintColor: "#FFF",
      controlTintColor: "#000",
      onOpen: () => {
        entry = StatusBar.pushStackEntry({
          animated: true,
          barStyle:
            Platform.OS === "ios" && Number.parseInt(Platform.Version, 10) >= 13
              ? "light-content"
              : "dark-content",
        });
      },
      onClose: (url) => {
        if (entry) {
          StatusBar.popStackEntry(entry);
        }

        if (url) {
          const { protocol, host, query } = parseUrl(url, true);
          const origin = `${protocol}//${host}`;

          if (origin === "io.swan.rnbrowserexample://close") {
            console.log(JSON.stringify(query, null, 2));
          }
        }
      },
    }).catch((error) => {
      console.error(error);
    });
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <Button title="Open browser" onPress={handleOnPress} />
    </SafeAreaView>
  );
};
