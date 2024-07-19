import { Linking, NativeEventEmitter, processColor } from "react-native";
import NativeModule from "./NativeRNSwanBrowser";

const emitter = new NativeEventEmitter(NativeModule);

export type AnimationType = "fade" | "slide";
export type DismissButtonStyle = "cancel" | "close" | "done";

export type Options = {
  animationType?: AnimationType;
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
  const { animationType, dismissButtonStyle, onOpen, onClose } = options;
  const barTintColor = convertColorToNumber(options.barTintColor);
  const controlTintColor = convertColorToNumber(options.controlTintColor);

  return NativeModule.open(url, {
    ...(animationType != null && { animationType }),
    ...(dismissButtonStyle != null && { dismissButtonStyle }),
    ...(barTintColor != null && { barTintColor }),
    ...(controlTintColor != null && { controlTintColor }),
  }).then(() => {
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
