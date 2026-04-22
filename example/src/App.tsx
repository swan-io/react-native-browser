import { closeBrowser, openBrowser } from "@swan-io/react-native-browser";
import { useCallback, useEffect, useRef } from "react";
import { Alert, Button, Linking, SafeAreaView, StyleSheet } from "react-native";
import parseUrl from "url-parse";

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
});

export const App = () => {
  const closedByDeepLinkRef = useRef(false);

  useEffect(() => {
    const subscription = Linking.addListener(
      "url",
      ({ url }: { url: string }) => {
        const { protocol, host, query } = parseUrl(url, true);
        const origin = `${protocol}//${host}`;

        if (origin === "io.swan.rnbrowserexample://close") {
          closedByDeepLinkRef.current = true;
          closeBrowser(); // required on iOS
          Alert.alert("Deeplink received", JSON.stringify(query, null, 2));
        }
      },
    );

    return () => {
      subscription.remove();
    };
  }, []);

  const handleOnPress = useCallback(() => {
    openBrowser("https://swan.io", {
      animationType: "slide",
      dismissButtonStyle: "close",
      barTintColor: "#FFF",
      controlTintColor: "#000",
      onClose: () => {
        if (closedByDeepLinkRef.current) {
          console.log("Closed by deep link");
          closedByDeepLinkRef.current = false;
        } else {
          console.log("Closed manually (X button or swipe)");
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
