import { NativeEventEmitter, processColor } from "react-native";
import NativeModule from "./specs/NativeRNSwanBrowser";

export type AnimationType = "fade" | "slide";
export type DismissButtonStyle = "cancel" | "close" | "done";

export type Options = {
  animationType?: AnimationType;
  dismissButtonStyle?: DismissButtonStyle;
  barTintColor?: string;
  controlTintColor?: string;
  onClose?: () => void;
};

const convertColorToNumber = (
  color: string | undefined,
): number | undefined => {
  const processed = processColor(color);

  if (typeof processed === "number") {
    return processed;
  }
};

const onCloseEventName = "swanBrowserOnClose";
const nativeEventEmitter = new NativeEventEmitter(NativeModule);
let onCloseSubscription: { remove: () => void } | null = null;
let onCloseHandler: (() => void) | null = null;

const setupOnCloseListener = (handler?: () => void) => {
  if (handler == null) {
    onCloseHandler = null;
    if (onCloseSubscription != null) {
      onCloseSubscription.remove();
      onCloseSubscription = null;
    }
    return;
  }

  onCloseHandler = handler;
  if (onCloseSubscription == null) {
    onCloseSubscription = nativeEventEmitter.addListener(
      onCloseEventName,
      () => {
        const callback = onCloseHandler;
        onCloseHandler = null;
        if (onCloseSubscription != null) {
          onCloseSubscription.remove();
          onCloseSubscription = null;
        }
        if (callback != null) {
          callback();
        }
      },
    );
  }
};

export const openBrowser = (
  url: string,
  options: Options = {},
): Promise<void> => {
  const { animationType, dismissButtonStyle } = options;
  const barTintColor = convertColorToNumber(options.barTintColor);
  const controlTintColor = convertColorToNumber(options.controlTintColor);

  setupOnCloseListener(options.onClose);

  return NativeModule.open(url, {
    ...(animationType != null && { animationType }),
    ...(dismissButtonStyle != null && { dismissButtonStyle }),
    ...(barTintColor != null && { barTintColor }),
    ...(controlTintColor != null && { controlTintColor }),
  }).then(() => {});
};

export const closeBrowser = (): void => {
  NativeModule.close();
};
