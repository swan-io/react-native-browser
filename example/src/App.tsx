import { openSwanBrowser } from "@swan-io/react-native-browser";
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

export const App = () => (
  <SafeAreaView style={styles.container}>
    <Button
      title="Open browser"
      onPress={() => {
        let entry: StatusBarProps | undefined;

        openSwanBrowser("http://192.168.1.15:3000", {
          dismissButtonStyle: "close",
          onOpen: () => {
            entry = StatusBar.pushStackEntry({
              animated: true,
              barStyle:
                Platform.OS === "ios" &&
                Number.parseInt(Platform.Version, 10) >= 13
                  ? "light-content"
                  : "dark-content",
            });
          },
          onClose: (url) => {
            if (url != null) {
              const parsed = parseUrl(url, true);
              console.log("Parsed deeplink:", JSON.stringify(parsed, null, 2));
            }

            if (entry != null) {
              StatusBar.popStackEntry(entry);
            }
          },
        }).catch((error) => {
          console.error(error);
        });
      }}
    />
  </SafeAreaView>
);
