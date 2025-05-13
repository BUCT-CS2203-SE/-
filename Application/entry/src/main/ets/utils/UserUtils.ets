/**
 * 用户工具类，处理用户信息相关的逻辑
 */
import preferences from '@ohos.data.preferences';
import { Constants } from '../common/constants/Constants';

/**
 * 用户信息接口
 */
export interface UserInfo {
  user_id: number;
  nickname: string;
  gender?: number;
  phone?: string;
  email?: string;
  img_url?: string;
}

/**
 * 存储用户信息到首选项存储
 * @param userInfo 用户信息
 */
export async function saveUserInfo(userInfo: UserInfo): Promise<void> {
  try {
    const preference = await preferences.getPreferences(Constants.getContext(), 'user_info');
    await preference.put('user_info', JSON.stringify(userInfo));
    await preference.flush();
  } catch (error) {
    console.error(`保存用户信息失败: ${error.message}`);
  }
}

/**
 * 从首选项存储获取用户信息
 * @returns 用户信息，如果未登录则返回null
 */
export async function getUserInfo(): Promise<UserInfo | null> {
  try {
    const preference = await preferences.getPreferences(Constants.getContext(), 'user_info');
    const userInfo = await preference.get('user_info', '');
    if (!userInfo) {
      return null;
    }
    return JSON.parse(userInfo as string);
  } catch (error) {
    console.error(`获取用户信息失败: ${error.message}`);
    return null;
  }
}

/**
 * 清除用户信息（退出登录）
 */
export async function clearUserInfo(): Promise<void> {
  try {
    const preference = await preferences.getPreferences(Constants.getContext(), 'user_info');
    await preference.delete('user_info');
    await preference.flush();
  } catch (error) {
    console.error(`清除用户信息失败: ${error.message}`);
  }
}

/**
 * 检查用户是否已登录
 * @returns 是否已登录
 */
export async function isUserLoggedIn(): Promise<boolean> {
  const userInfo = await getUserInfo();
  return userInfo !== null;
} 