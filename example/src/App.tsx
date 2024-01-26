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
        if (entry != null) {
          StatusBar.popStackEntry(entry);
        }

        if (url != null) {
          const parsed = parseUrl(url, true);
          console.log("Parsed deeplink:", JSON.stringify(parsed, null, 2));
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
