import {
  Linking,
  NativeEventEmitter,
  NativeModules,
  processColor,
} from "react-native";

const { RNSwanBrowser } = NativeModules;
const emitter = new NativeEventEmitter(RNSwanBrowser);

export type Options = {
  dismissButtonStyle?: "cancel" | "close" | "done";
  barTintColor?: string;
  controlTintColor?: string;
  onOpen?: () => void;
  onClose?: (url?: string) => void;
};

const processNativeOptions = (options: Options) => ({
  dismissButtonStyle: options.dismissButtonStyle,
  barTintColor: processColor(options.barTintColor),
  controlTintColor: processColor(options.controlTintColor),
});

const NativeModule = RNSwanBrowser as {
  open: (
    url: string,
    options: ReturnType<typeof processNativeOptions>,
  ) => Promise<null>;
  close: () => void;
};

export const openBrowser = (url: string, options: Options): Promise<void> => {
  const { onOpen, onClose, ...rest } = options;

  return NativeModule.open(url, processNativeOptions(rest)).then(() => {
    onOpen?.();

    if (onClose != null) {
      let deeplink: string | undefined;

      const linkListener = Linking.addListener(
        "url",
        ({ url }: { url: string }) => {
          deeplink = url;
          NativeModule.close();
        },
      );

      const closeListener = emitter.addListener("swanBrowserDidClose", () => {
        onClose?.(deeplink);

        linkListener.remove();
        closeListener.remove();
      });
    }
  });
};
