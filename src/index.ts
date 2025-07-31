import { processColor } from "react-native";
import NativeModule from "./specs/NativeRNSwanBrowser";

export type AnimationType = "fade" | "slide";
export type DismissButtonStyle = "cancel" | "close" | "done";

export type Options = {
  animationType?: AnimationType;
  dismissButtonStyle?: DismissButtonStyle;
  barTintColor?: string;
  controlTintColor?: string;
};

const convertColorToNumber = (
  color: string | undefined,
): number | undefined => {
  const processed = processColor(color);

  if (typeof processed === "number") {
    return processed;
  }
};

export const openBrowser = (
  url: string,
  options: Options = {},
): Promise<void> => {
  const { animationType, dismissButtonStyle } = options;
  const barTintColor = convertColorToNumber(options.barTintColor);
  const controlTintColor = convertColorToNumber(options.controlTintColor);

  return NativeModule.open(url, {
    ...(animationType != null && { animationType }),
    ...(dismissButtonStyle != null && { dismissButtonStyle }),
    ...(barTintColor != null && { barTintColor }),
    ...(controlTintColor != null && { controlTintColor }),
  }).then(() => {});
};
