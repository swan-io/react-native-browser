import { Linking, NativeEventEmitter, processColor } from "react-native";
import NativeModule from "./NativeModule";

const emitter = new NativeEventEmitter(NativeModule);

export type DismissButtonStyle = "cancel" | "close" | "done";

export type Options = {
  dismissButtonStyle?: DismissButtonStyle;
  barTintColor?: string;
  controlTintColor?: string;
  onOpen?: () => void;
  onClose?: (url?: string) => void;
};

const convertColorToNumber = (
  color: string | undefined,
): number | undefined => {
  const processed = processColor(color);

  if (typeof processed === "number") {
    return processed;
  }
};

export const openBrowser = (url: string, options: Options): Promise<void> => {
  const {
    dismissButtonStyle,
    barTintColor,
    controlTintColor,
    onOpen,
    onClose,
  } = options;

  return NativeModule.open(
    url,
    dismissButtonStyle,
    convertColorToNumber(barTintColor),
    convertColorToNumber(controlTintColor),
  ).then(() => {
    let deeplink: string | undefined;

    onOpen?.();

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
  });
};
