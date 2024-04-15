import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export interface Spec extends TurboModule {
  open(
    url: string,
    dismissButtonStyle?: string,
    barTintColor?: number,
    controlTintColor?: number,
  ): Promise<null>;

  close(): void;

  // Events
  addListener: (eventName: string) => void;
  removeListeners: (count: number) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>("RNSwanBrowser");
