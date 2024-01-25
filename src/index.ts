import {
  Linking,
  NativeEventEmitter,
  NativeModules,
  processColor,
} from "react-native";

const { RNSwanBrowser } = NativeModules;
const emitter = new NativeEventEmitter(RNSwanBrowser);

type Options = {
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

export const openSwanBrowser = (
  url: string,
  { onOpen, onClose, ...options }: Options,
): Promise<void> => {
  return NativeModule.open(url, processNativeOptions(options)).then(() => {
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
