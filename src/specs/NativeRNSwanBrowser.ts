import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

type Options = {
  animationType?: string;
  dismissButtonStyle?: string;
  barTintColor?: number;
  controlTintColor?: number;
};

export interface Spec extends TurboModule {
  open(url: string, options: Options): Promise<null>;
}

export default TurboModuleRegistry.getEnforcing<Spec>("RNSwanBrowser");
