import preferences from '@ohos.data.preferences';

export class StorageService {
  private static readonly PREFERENCES_NAME = 'app_preferences';

  async set<T>(key: string, value: T): Promise<void> {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      await prefs.put(key, JSON.stringify(value));
      await prefs.flush();
    } catch (err) {
      console.error(`保存数据失败: ${err.message}`);
      throw new Error(`保存数据失败: ${err.message}`);
    }
  }

  async get<T>(key: string, defaultValue: T): Promise<T> {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      const value = await prefs.get(key, JSON.stringify(defaultValue));
      return JSON.parse(value.toString());
    } catch (err) {
      console.error(`获取数据失败: ${err.message}`);
      return defaultValue;
    }
  }

  async delete(key: string): Promise<void> {
    try {
      const context = getContext(this);
      const prefs = await preferences.getPreferences(context, StorageService.PREFERENCES_NAME);
      await prefs.delete(key);
      await prefs.flush();
    } catch (err) {
      console.error(`删除数据失败: ${err.message}`);
      throw new Error(`删除数据失败: ${err.message}`);
    }
  }
} 