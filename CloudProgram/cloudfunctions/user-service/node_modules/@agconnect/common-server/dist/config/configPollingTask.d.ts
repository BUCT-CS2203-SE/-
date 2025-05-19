import { PollingEvent } from "./configConstants";
export declare class ConfigPollingTask {
    private static eventEmitter;
    private static pollingTask;
    static fire(event: PollingEvent): void;
    private static startTask;
    private static stopTask;
}
