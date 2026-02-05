import { closeBrowser, openBrowser } from "@swan-io/react-native-browser";
import { useCallback, useEffect } from "react";
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
  useEffect(() => {
    const subscription = Linking.addListener(
      "url",
      ({ url }: { url: string }) => {
        const { protocol, host, query } = parseUrl(url, true);
        const origin = `${protocol}//${host}`;

        if (origin === "io.swan.rnbrowserexample://close") {
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
        console.log("onClose trigger");
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
