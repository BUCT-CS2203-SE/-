import { User, Comment } from '../model/UserModel';
import { Constants } from '../common/constants/Constants';
import http from '@ohos.net.http';
import preferences from '@ohos.data.preferences';

/**
 * API响应数据结构
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * 用户数据结构
 */
interface UserData {
  id: string;
  username: string;
  avatarUrl: string;
  email: string;
  isVerified: boolean;
  favorites: string[];
}

/**
 * 评论数据结构
 */
interface CommentData {
  id: string;
  userId: string;
  username: string;
  avatarUrl: string;
  content: string;
  createTime: string;
  artifactId: string;
}

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
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
  
  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  login(username: string, password: string): Promise<User> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/users/login`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            username: username,
            password: password
          })
        },
        async (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<UserData>;
              if (responseData.code === 200) {
                const userData = responseData.data;
                const user = new User(
                  userData.id,
                  userData.username,
                  userData.avatarUrl,
                  userData.email,
                  userData.isVerified,
                  userData.favorites
                );
                
                // 保存用户信息至首选项
                await this.saveUserInfo(user);
                
                resolve(user);
              } else {
                reject(`登录失败: ${responseData.message}`);
              }
            } catch (e) {
              reject(`解析数据失败: ${e}`);
            }
          } else {
            reject(`请求失败: ${err.message}`);
          }
          // 关闭HTTP连接
          httpRequest.destroy();
        }
      );
    });
  }
  
  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param email 电子邮箱
   */
  register(username: string, password: string, email: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/users/register`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            username: username,
            password: password,
            email: email
          })
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<boolean>;
              if (responseData.code === 200) {
                resolve(true);
              } else {
                reject(`注册失败: ${responseData.message}`);
              }
            } catch (e) {
              reject(`解析数据失败: ${e}`);
            }
          } else {
            reject(`请求失败: ${err.message}`);
          }
          // 关闭HTTP连接
          httpRequest.destroy();
        }
      );
    });
  }
  
  /**
   * 获取用户信息
   */
  async getUserInfo(): Promise<User | null> {
    try {
      const context = getContext(this);
      // 获取首选项
      const prefs = await preferences.getPreferences(context, UserService.PREFERENCES_NAME);
      // 获取用户信息
      const userInfoStr = await prefs.get(UserService.USER_KEY, '');
      if (userInfoStr) {
        return JSON.parse(userInfoStr.toString());
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
      throw new Error(`保存用户信息失败: ${(err as ErrorWithMessage).message}`);
    }
  }
  
  /**
   * 登出
   */
  async logout(): Promise<void> {
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
    } catch (err) {
      console.error(`登出失败: ${(err as ErrorWithMessage).message}`);
      throw new Error(`登出失败: ${(err as ErrorWithMessage).message}`);
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
   * 获取文物评论
   * @param artifactId 文物ID
   */
  getComments(artifactId: string): Promise<Comment[]> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/comments?artifactId=${artifactId}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<CommentData[]>;
              const comments: Comment[] = responseData.data.map((item: CommentData) => {
                return new Comment(
                  item.id,
                  item.userId,
                  item.username,
                  item.avatarUrl,
                  item.content,
                  item.createTime,
                  item.artifactId
                );
              });
              resolve(comments);
            } catch (e) {
              reject(`解析数据失败: ${e}`);
            }
          } else {
            reject(`请求失败: ${err.message}`);
          }
          // 关闭HTTP连接
          httpRequest.destroy();
        }
      );
    });
  }
  
  /**
   * 添加评论
   * @param artifactId 文物ID
   * @param content 评论内容
   */
  addComment(artifactId: string, content: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      this.getUserInfo().then(user => {
        if (!user) {
          reject('用户未登录');
          return;
        }
        
        let httpRequest = http.createHttp();
        httpRequest.request(
          `${Constants.BASE_URL}/comments`,
          {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': 'application/json'
            },
            extraData: JSON.stringify({
              artifactId: artifactId,
              content: content,
              userId: user.id
            })
          },
          (err, data) => {
            if (!err) {
              // 解析响应数据
              try {
                const responseData = JSON.parse(data.result.toString()) as ApiResponse<boolean>;
                if (responseData.code === 200) {
                  resolve(true);
                } else {
                  reject(`添加评论失败: ${responseData.message}`);
                }
              } catch (e) {
                reject(`解析数据失败: ${e}`);
              }
            } else {
              reject(`请求失败: ${err.message}`);
            }
            // 关闭HTTP连接
            httpRequest.destroy();
          }
        );
      }).catch((err: ErrorWithMessage) => {
        reject(`获取用户信息失败: ${err.message}`);
      });
    });
  }
} 