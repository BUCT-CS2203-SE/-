import { User, UserComment } from '../model/UserModel';
import { Constants } from '../common/constants/Constants';
import preferences from '@ohos.data.preferences';
import { ApiService } from './ApiService';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

/**
 * 用户服务错误类
 */
class UserServiceError extends Error {
  constructor(message: string) {
    super(message);
  }
}

/**
 * 用户服务类
 */
export class UserService {
  // 首选项文件名
  private static readonly PREFERENCES_NAME = 'userPreferences';
  // 用户信息键名
  private static readonly USER_KEY = 'user_info';
  // 登录状态键名
  private static readonly LOGIN_STATE_KEY = 'login_state';
  
  // API服务实例
  private apiService: ApiService = new ApiService();
  
  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<User> {
    try {
      console.info(`尝试登录，用户名: ${username}`);
      
      // 调用API服务登录
      const user = await this.apiService.login(username, password);
      console.info('登录成功');
      
      // 保存用户信息至首选项
      await this.saveUserInfo(user);
      
      return user;
    } catch (error) {
      console.error('登录失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param email 电子邮箱
   */
  async register(username: string, password: string, email: string): Promise<User> {
    try {
      console.info(`尝试注册，用户名: ${username}`);
      
      // 调用API服务注册
      const user = await this.apiService.register(username, password, email);
      console.info('注册成功');
      
      return user;
    } catch (error) {
      console.error('注册失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<User | null> {
    try {
      const context = getContext(this);
      // 获取首选项
      const prefs = await preferences.getPreferences(context, UserService.PREFERENCES_NAME);
      // 获取用户信息
      const userInfoStr = await prefs.get(UserService.USER_KEY, '');
      if (userInfoStr) {
        return JSON.parse(userInfoStr.toString()) as User;
      }
      return null;
    } catch (err) {
      console.error(`获取用户信息失败: ${(err as ErrorWithMessage).message}`);
      return null;
    }
  }
  
  /**
   * 保存用户信息
   * @param user 用户信息
   */
  private async saveUserInfo(user: User): Promise<void> {
    try {
      const context = getContext(this);
      // 获取首选项
      const prefs = await preferences.getPreferences(context, UserService.PREFERENCES_NAME);
      // 保存用户信息
      await prefs.put(UserService.USER_KEY, JSON.stringify(user));
      // 保存登录状态
      await prefs.put(UserService.LOGIN_STATE_KEY, true);
      // 提交更改
      await prefs.flush();
    } catch (err) {
      console.error(`保存用户信息失败: ${(err as ErrorWithMessage).message}`);
      throw new UserServiceError(`保存用户信息失败: ${(err as ErrorWithMessage).message}`);
    }
  }
  
  /**
   * 用户登出
   */
  async logout(): Promise<boolean> {
    try {
      const context = getContext(this);
      // 获取首选项
      const prefs = await preferences.getPreferences(context, UserService.PREFERENCES_NAME);
      // 清除用户信息
      await prefs.delete(UserService.USER_KEY);
      // 更新登录状态
      await prefs.put(UserService.LOGIN_STATE_KEY, false);
      // 提交更改
      await prefs.flush();
      return true;
    } catch (err) {
      console.error(`登出失败: ${(err as ErrorWithMessage).message}`);
      return false;
    }
  }
  
  /**
   * 检查登录状态
   */
  async isLoggedIn(): Promise<boolean> {
    try {
      const context = getContext(this);
      // 获取首选项
      const prefs = await preferences.getPreferences(context, UserService.PREFERENCES_NAME);
      // 获取登录状态
      return await prefs.get(UserService.LOGIN_STATE_KEY, false) as boolean;
    } catch (err) {
      console.error(`检查登录状态失败: ${(err as ErrorWithMessage).message}`);
      return false;
    }
  }
  
  /**
   * 更新用户信息
   * @param userData 用户数据
   */
  async updateUserInfo(userData: Partial<User>): Promise<boolean> {
    try {
      // 获取当前用户
      const currentUser = await this.getCurrentUser();
      if (!currentUser) {
        throw new UserServiceError('用户未登录');
      }
      
      // 调用API服务更新用户信息
      await this.apiService.updateUserInfo(currentUser.id, userData);
      
      // 更新本地存储的用户信息
      const updatedUser: User = new User(
        currentUser.id,
        userData.username || currentUser.username,
        userData.avatarUrl || currentUser.avatarUrl,
        userData.email || currentUser.email,
        userData.isVerified !== undefined ? userData.isVerified : currentUser.isVerified,
        userData.favorites || currentUser.favorites
      );
      await this.saveUserInfo(updatedUser);
      
      return true;
    } catch (error) {
      console.error('更新用户信息失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 添加评论
   * @param artifactId 文物ID
   * @param content 评论内容
   */
  async addComment(artifactId: string, content: string): Promise<boolean> {
    try {
      // 获取当前用户
      const currentUser = await this.getCurrentUser();
      if (!currentUser) {
        throw new UserServiceError('用户未登录');
      }
      
      // 调用API服务添加评论
      await this.apiService.addComment(artifactId, currentUser.id, content);
      
      return true;
    } catch (error) {
      console.error('添加评论失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户评论
   * @param userId 用户ID，如果不提供则获取当前用户的评论
   */
  async getComments(userId?: string): Promise<UserComment[]> {
    try {
      // 如果未提供用户ID，获取当前用户
      if (!userId) {
        const currentUser = await this.getCurrentUser();
        if (!currentUser) {
          throw new UserServiceError('用户未登录');
        }
        userId = currentUser.id;
      }
      
      // 调用API服务获取用户评论
      return await this.apiService.getUserComments(userId);
    } catch (error) {
      console.error('获取用户评论失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 添加收藏
   * @param artifactId 文物ID
   */
  async addFavorite(artifactId: string): Promise<boolean> {
    try {
      // 获取当前用户
      const currentUser = await this.getCurrentUser();
      if (!currentUser) {
        throw new UserServiceError('用户未登录');
      }
      
      // 调用API服务添加收藏
      await this.apiService.addFavorite(currentUser.id, artifactId);
      
      return true;
    } catch (error) {
      console.error('添加收藏失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 取消收藏
   * @param artifactId 文物ID
   */
  async removeFavorite(artifactId: string): Promise<boolean> {
    try {
      // 获取当前用户
      const currentUser = await this.getCurrentUser();
      if (!currentUser) {
        throw new UserServiceError('用户未登录');
      }
      
      // 调用API服务取消收藏
      await this.apiService.removeFavorite(currentUser.id, artifactId);
      
      return true;
    } catch (error) {
      console.error('取消收藏失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户收藏
   * @param userId 用户ID，如果不提供则获取当前用户的收藏
   */
  async getFavorites(userId?: string): Promise<string[]> {
    try {
      // 如果未提供用户ID，获取当前用户
      if (!userId) {
        const currentUser = await this.getCurrentUser();
        if (!currentUser) {
          throw new UserServiceError('用户未登录');
        }
        userId = currentUser.id;
      }
      
      // 调用API服务获取用户收藏
      const artifacts = await this.apiService.getUserFavorites(userId);
      
      // 返回文物ID列表
      return artifacts.map(artifact => artifact.id);
    } catch (error) {
      console.error('获取用户收藏失败:', error);
      throw new UserServiceError(error instanceof Error ? error.message : String(error));
    }
  }
} 