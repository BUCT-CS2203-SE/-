export declare class ConfigService {
    static CONFIG_REGEX: string;
    static priorInstance: ConfigService;
    static INSTANCES: Map<string, ConfigService>;
    private configMap;
    static initialLoadServiceConfig(serviceName: string, configFilePath: string): void;
    static loadCustomConfig(): void;
    static getService(serviceName: string): ConfigService;
    static startPollingTask(): void;
    static stopPollingTask(): void;
    getConfigValue(key: string, defaultValue?: any): any;
}
