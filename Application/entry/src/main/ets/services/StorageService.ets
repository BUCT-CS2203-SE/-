import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

/**
 * 存储服务错误类
 */
class StorageServiceError extends Error {
  constructor(message: string) {
    super(message);
  }
}

export class StorageService {
  private static readonly PREFERENCES_NAME = 'app_preferences';

  private getContext(): common.UIAbilityContext {
    const context = getContext(this) as common.UIAbilityContext;
    if (!context) {
      throw new StorageServiceError('无法获取应用上下文');
    }
    return context;
  }

  async set<T>(key: string, value: T): Promise<void> {
    try {
      const context = this.getContext();
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      const valueStr = JSON.stringify(value);
      console.info(`准备保存数据 - 键: ${key}, 值: ${valueStr}`);
      await prefs.put(key, valueStr);
      await prefs.flush();
      console.info(`数据保存成功 - 键: ${key}`);
    } catch (err) {
      console.error(`保存数据失败 - 键: ${key}, 错误: ${(err as ErrorWithMessage).message}`);
      throw new StorageServiceError(`保存数据失败: ${(err as ErrorWithMessage).message}`);
    }
  }

  async get<T>(key: string, defaultValue: T): Promise<T> {
    try {
      const context = this.getContext();
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      console.info(`准备获取数据 - 键: ${key}`);
      const value = await prefs.get(key, JSON.stringify(defaultValue));
      console.info(`获取到原始数据 - 键: ${key}, 值: ${value}`);
      if (typeof value === 'string') {
        try {
          const parsedValue = JSON.parse(value) as T;
          console.info(`数据解析成功 - 键: ${key}, 值: ${JSON.stringify(parsedValue)}`);
          return parsedValue;
        } catch (parseError) {
          console.error(`解析数据失败 - 键: ${key}, 错误: ${(parseError as ErrorWithMessage).message}`);
          return defaultValue;
        }
      }
      console.info(`返回默认值 - 键: ${key}, 值: ${JSON.stringify(defaultValue)}`);
      return defaultValue;
    } catch (err) {
      console.error(`获取数据失败 - 键: ${key}, 错误: ${(err as ErrorWithMessage).message}`);
      return defaultValue;
    }
  }

  async delete(key: string): Promise<void> {
    try {
      const context = this.getContext();
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      await prefs.delete(key);
      await prefs.flush();
      console.info(`数据删除成功: ${key}`);
    } catch (err) {
      console.error(`删除数据失败: ${(err as ErrorWithMessage).message}`);
      throw new StorageServiceError(`删除数据失败: ${(err as ErrorWithMessage).message}`);
    }
  }
} 