import { ValueOf } from "../utils/utils";
export declare class ConfigConstants {
    static readonly POLLING_INTERVAL: number;
    static readonly POLLING_EVENT: {
        readonly START: "POLLING_START_EVENT";
        readonly STOP: "POLLING_STOP_EVENT";
    };
}
export type PollingEvent = ValueOf<typeof ConfigConstants.POLLING_EVENT>;
