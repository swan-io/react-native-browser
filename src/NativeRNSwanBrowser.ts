import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";
import type { EventEmitter } from "react-native/Libraries/Types/CodegenTypes";

type Options = {
  animationType?: string;
  dismissButtonStyle?: string;
  barTintColor?: number;
  controlTintColor?: number;
};

export interface Spec extends TurboModule {
  open(url: string, options: Options): Promise<null>;
  close(): void;
  readonly onClose: EventEmitter<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>("RNSwanBrowser");
