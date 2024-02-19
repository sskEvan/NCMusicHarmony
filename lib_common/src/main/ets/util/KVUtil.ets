import dataPreferences from '@ohos.data.preferences';
import { LogUtil } from './LogUtil';

let preference: dataPreferences.Preferences;

/**
 * 键值对存储工具类
 */
export class KVUtil {
  static async getInstance() {
    try {
      preference = await dataPreferences.getPreferences(getContext(), "NCMusicHarmony");
    } catch (err) {
      LogUtil.error(`Failed to get preferences, Cause: ${err}`);
    }
  }

  static async putString(key: string, value: string) {
    try {
      if (!preference) {
        await this.getInstance();
      }
      try {
        await preference.put(key, value);
      } catch (err) {
        LogUtil.error(`Failed to put value, Cause: ${err}`);
      }
      await preference.flush();
    } catch (err) {
      LogUtil.error(`Failed to get preferences, Cause: ${err}`);
    }
  }

  static async getString(key: string) {
    let value: string = null;
    if (!preference) {
      await this.getInstance();
    }
    try {
      value = (await preference.get(key, '')).toString();
    } catch (err) {
      LogUtil.error(`Failed to get value, Cause: ${err}`);
    }
    return value;
  }

  static async get<T>(key: string) {
    let value: T = null;
    if (!preference) {
      await this.getInstance();
    }
    try {
      const json = await this.getString(key)
      if (json) {
        // value = plainToClass(Object, JSON.parse(json)) as T;
        value = JSON.parse(json) as T
      }
    } catch (err) {
      LogUtil.error(`Failed to get value, Cause: ${err}`);
    }
    return value;
  }
}

