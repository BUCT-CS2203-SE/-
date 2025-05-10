/**
 * API服务类，用于处理与后端的通信
 */
import http from '@ohos.net.http';
import { Artifact } from '../model/ArtifactModel';
import { UserComment, User } from '../model/UserModel';

/**
 * API响应数据结构
 */
interface ApiResponse<T> {
  code?: number;
  message?: string;
  data?: T;
}

/**
 * API错误类
 */
class ApiError extends Error {
  statusCode: number;
  
  constructor(message: string, statusCode: number = 0) {
    super(message);
    this.statusCode = statusCode;
  }
}

/**
 * HTTP头部类
 */
class HttpHeader {
  'Content-Type': string = 'application/json';
}

/**
 * HTTP请求参数接口
 */
interface HttpRequestOptions {
  method: http.RequestMethod;
  header: HttpHeader;
  readTimeout: number;
  connectTimeout: number;
  extraData?: string;
}

/**
 * 文物响应接口
 */
interface ArtifactResponse {
  artifacts: Array<Record<string, string | number | boolean>>;
  totalCount: number;
}

/**
 * 通用记录类型
 */
interface GenericRecord {
  relic_id?: number;
  name?: string;
  era?: string;
  museum?: string;
  description?: string;
  type?: number;
  id?: string;
  userId?: string;
  username?: string;
  avatarUrl?: string;
  content?: string;
  createTime?: string;
  artifactId?: string;
  email?: string;
  isVerified?: boolean;
  abilityPrevAccessTime?: number;
  abilityInFgTotalTime?: number;
}

/**
 * 用户数据接口
 */
interface UserData {
  id?: string;
  username?: string;
  avatarUrl?: string;
  email?: string;
  isVerified?: boolean;
}

/**
 * 评论数据接口
 */
interface CommentData {
  id?: string;
  userId?: string;
  username?: string;
  avatarUrl?: string;
  content?: string;
  createTime?: string;
  artifactId?: string;
}

/**
 * 收藏数据接口
 */
interface FavoriteData {
  userId: string;
  artifactId: string;
}

/**
 * 评论请求数据接口
 */
interface CommentRequestData {
  userId: string;
  artifactId: string;
  content: string;
}

/**
 * 注册请求数据接口
 */
interface RegisterData {
  username: string;
  password: string;
  email?: string;
}

/**
 * 登录请求数据接口
 */
interface LoginData {
  username: string;
  password: string;
}

/**
 * 用户信息更新数据接口
 */
interface UpdateUserData {
  username?: string;
  email?: string;
  avatarUrl?: string;
  isVerified?: boolean;
}

/**
 * 请求数据构造类
 */
class RequestData {
  // 使用固定的属性而不是索引签名
  username: string = '';
  password: string = '';
  email: string = '';
  userId: string = '';
  artifactId: string = '';
  content: string = '';
  avatarUrl: string = '';
  isVerified: boolean = false;
  
  private hasUsername: boolean = false;
  private hasPassword: boolean = false;
  private hasEmail: boolean = false;
  private hasUserId: boolean = false;
  private hasArtifactId: boolean = false;
  private hasContent: boolean = false;
  private hasAvatarUrl: boolean = false;
  private hasIsVerified: boolean = false;
  
  /**
   * 设置用户名
   */
  setUsername(value: string): void {
    this.username = value;
    this.hasUsername = true;
  }
  
  /**
   * 设置密码
   */
  setPassword(value: string): void {
    this.password = value;
    this.hasPassword = true;
  }
  
  /**
   * 设置邮箱
   */
  setEmail(value: string): void {
    this.email = value;
    this.hasEmail = true;
  }
  
  /**
   * 设置用户ID
   */
  setUserId(value: string): void {
    this.userId = value;
    this.hasUserId = true;
  }
  
  /**
   * 设置文物ID
   */
  setArtifactId(value: string): void {
    this.artifactId = value;
    this.hasArtifactId = true;
  }
  
  /**
   * 设置内容
   */
  setContent(value: string): void {
    this.content = value;
    this.hasContent = true;
  }
  
  /**
   * 设置头像URL
   */
  setAvatarUrl(value: string): void {
    this.avatarUrl = value;
    this.hasAvatarUrl = true;
  }
  
  /**
   * A设置是否验证
   */
  setIsVerified(value: boolean): void {
    this.isVerified = value;
    this.hasIsVerified = true;
  }
  
  /**
   * 转换为Record类型
   */
  toRecord(): Record<string, string | number | boolean> {
    const result: Record<string, string | number | boolean> = {};
    
    if (this.hasUsername) result['username'] = this.username;
    if (this.hasPassword) result['password'] = this.password;
    if (this.hasEmail) result['email'] = this.email;
    if (this.hasUserId) result['userId'] = this.userId;
    if (this.hasArtifactId) result['artifactId'] = this.artifactId;
    if (this.hasContent) result['content'] = this.content;
    if (this.hasAvatarUrl) result['avatarUrl'] = this.avatarUrl;
    if (this.hasIsVerified) result['isVerified'] = this.isVerified;
    
    return result;
  }
}

/**
 * API服务类
 */
export class ApiService {
  // API基础URL
  private baseUrl: string = 'http://localhost:3000/api';
  
  /**
   * 构造函数
   */
  constructor() {
    // 在实际应用中，这里可以添加初始化逻辑
  }
  
  /**
   * 发送GET请求
   * @param url 请求URL
   */
  private async get<T>(url: string): Promise<T> {
    try {
      const httpRequest = http.createHttp();
      const headerObj = new HttpHeader();
      
      const options: HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: headerObj,
        readTimeout: 60000,
        connectTimeout: 60000
      };
      
      const response = await httpRequest.request(
        this.baseUrl + url,
        options
      );
      
      httpRequest.destroy();
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result.toString()) as T;
      } else {
        throw new ApiError(`请求失败: ${response.responseCode}`, response.responseCode);
      }
    } catch (error) {
      console.error(`GET请求错误: ${url}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 发送POST请求
   * @param url 请求URL
   * @param data 请求数据
   */
  private async post<T>(url: string, data: Record<string, string | number | boolean>): Promise<T> {
    try {
      const httpRequest = http.createHttp();
      const headerObj = new HttpHeader();
      
      const options: HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headerObj,
        extraData: JSON.stringify(data),
        readTimeout: 60000,
        connectTimeout: 60000
      };
      
      const response = await httpRequest.request(
        this.baseUrl + url,
        options
      );
      
      httpRequest.destroy();
      
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result.toString()) as T;
      } else {
        throw new ApiError(`请求失败: ${response.responseCode}`, response.responseCode);
      }
    } catch (error) {
      console.error(`POST请求错误: ${url}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 发送PUT请求
   * @param url 请求URL
   * @param data 请求数据
   */
  private async put<T>(url: string, data: Record<string, string | number | boolean>): Promise<T> {
    try {
      const httpRequest = http.createHttp();
      const headerObj = new HttpHeader();
      
      const options: HttpRequestOptions = {
        method: http.RequestMethod.PUT,
        header: headerObj,
        extraData: JSON.stringify(data),
        readTimeout: 60000,
        connectTimeout: 60000
      };
      
      const response = await httpRequest.request(
        this.baseUrl + url,
        options
      );
      
      httpRequest.destroy();
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result.toString()) as T;
      } else {
        throw new ApiError(`请求失败: ${response.responseCode}`, response.responseCode);
      }
    } catch (error) {
      console.error(`PUT请求错误: ${url}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 发送DELETE请求
   * @param url 请求URL
   */
  private async delete<T>(url: string): Promise<T> {
    try {
      const httpRequest = http.createHttp();
      const headerObj = new HttpHeader();
      
      const options: HttpRequestOptions = {
        method: http.RequestMethod.DELETE,
        header: headerObj,
        readTimeout: 60000,
        connectTimeout: 60000
      };
      
      const response = await httpRequest.request(
        this.baseUrl + url,
        options
      );
      
      httpRequest.destroy();
      
      if (response.responseCode === 200 || response.responseCode === 204) {
        return JSON.parse(response.result.toString()) as T;
      } else {
        throw new ApiError(`请求失败: ${response.responseCode}`, response.responseCode);
      }
    } catch (error) {
      console.error(`DELETE请求错误: ${url}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取文物列表
   * @param type 类型ID
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getArtifactList(type?: number, page: number = 1, pageSize: number = 10): Promise<Artifact[]> {
    try {
      let url = `/artifacts?page=${page}&pageSize=${pageSize}`;
      if (type !== undefined) {
        url += `&type=${type}`;
      }
      
      const response = await this.get<ArtifactResponse>(url);
      
      // 将API返回的数据转换为Artifact对象
      return response.artifacts.map(item => new Artifact(
        item.relic_id?.toString() || '',
        item.name?.toString() || '',
        item.era?.toString() || '',
        item.museum?.toString() || '',
        item.description?.toString() || '',
        '', // 原来的imageUrl，现在没有了
        typeof item.type === 'number' ? item.type : 7,
        '', // 原来的detailUrl，现在没有了
        0,  // 原来的likes，现在没有了
        0   // 原来的comments，现在没有了
      ));
    } catch (error) {
      console.error('获取文物列表失败:', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取文物详情
   * @param id 文物ID
   */
  async getArtifactDetail(id: string): Promise<Artifact> {
    try {
      const item = await this.get<GenericRecord>(`/artifacts/${id}`);
      
      // 将API返回的数据转换为Artifact对象
      return new Artifact(
        item.relic_id?.toString() || '',
        item.name?.toString() || '',
        item.era?.toString() || '',
        item.museum?.toString() || '',
        item.description?.toString() || '',
        '', // 原来的imageUrl，现在没有了
        typeof item.type === 'number' ? item.type : 7,
        '', // 原来的detailUrl，现在没有了
        0,  // 原来的likes，现在没有了
        0   // 原来的comments，现在没有了
      );
    } catch (error) {
      console.error(`获取文物详情失败: ${id}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 搜索文物
   * @param keyword 搜索关键词
   */
  async searchArtifacts(keyword: string): Promise<Artifact[]> {
    try {
      const items = await this.get<Array<GenericRecord>>(`/artifacts/search?keyword=${encodeURIComponent(keyword)}`);
      
      // 将API返回的数据转换为Artifact对象数组
      return items.map(item => new Artifact(
        item.relic_id?.toString() || '',
        item.name?.toString() || '',
        item.era?.toString() || '',
        item.museum?.toString() || '',
        item.description?.toString() || '',
        '', // 原来的imageUrl，现在没有了
        typeof item.type === 'number' ? item.type : 7,
        '', // 原来的detailUrl，现在没有了
        0,  // 原来的likes，现在没有了
        0   // 原来的comments，现在没有了
      ));
    } catch (error) {
      console.error(`搜索文物失败: ${keyword}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取文物评论
   * @param artifactId 文物ID
   */
  async getArtifactComments(artifactId: string): Promise<UserComment[]> {
    try {
      const items = await this.get<Array<CommentData>>(`/artifacts/${artifactId}/comments`);
      
      // 将API返回的数据转换为UserComment对象数组
      return items.map(item => new UserComment(
        item.id?.toString() || '',
        item.userId?.toString() || '',
        item.username?.toString() || '',
        item.avatarUrl?.toString() || '',
        item.content?.toString() || '',
        item.createTime?.toString() || '',
        item.artifactId?.toString() || ''
      ));
    } catch (error) {
      console.error(`获取文物评论失败: ${artifactId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param email 电子邮箱
   */
  async register(username: string, password: string, email?: string): Promise<User> {
    try {
      // 创建请求数据
      const registerData = new RequestData();
      registerData.setUsername(username);
      registerData.setPassword(password);
      if (email) {
        registerData.setEmail(email);
      }
      
      const userData = await this.post<UserData>('/users/register', registerData.toRecord());
      
      // 将API返回的数据转换为User对象
      return new User(
        userData.id?.toString() || '',
        userData.username?.toString() || '',
        userData.avatarUrl?.toString() || '',
        userData.email?.toString() || '',
        Boolean(userData.isVerified),
        []
      );
    } catch (error) {
      console.error('用户注册失败', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<User> {
    try {
      // 创建请求数据
      const loginData = new RequestData();
      loginData.setUsername(username);
      loginData.setPassword(password);
      
      const userData = await this.post<UserData>('/users/login', loginData.toRecord());
      
      // 将API返回的数据转换为User对象
      return new User(
        userData.id?.toString() || '',
        userData.username?.toString() || '',
        userData.avatarUrl?.toString() || '',
        userData.email?.toString() || '',
        Boolean(userData.isVerified),
        []
      );
    } catch (error) {
      console.error('用户登录失败', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户信息
   * @param userId 用户ID
   */
  async getUserInfo(userId: string): Promise<User> {
    try {
      const userData = await this.get<UserData>(`/users/${userId}`);
      
      // 将API返回的数据转换为User对象
      return new User(
        userData.id?.toString() || '',
        userData.username?.toString() || '',
        userData.avatarUrl?.toString() || '',
        userData.email?.toString() || '',
        Boolean(userData.isVerified),
        []
      );
    } catch (error) {
      console.error(`获取用户信息失败: ${userId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 更新用户信息
   * @param userId 用户ID
   * @param userData 用户数据
   */
  async updateUserInfo(userId: string, userData: Partial<User>): Promise<void> {
    try {
      // 创建请求数据
      const updateData = new RequestData();
      if (userData.username) updateData.setUsername(userData.username);
      if (userData.email) updateData.setEmail(userData.email);
      if (userData.avatarUrl) updateData.setAvatarUrl(userData.avatarUrl);
      if (userData.isVerified !== undefined) updateData.setIsVerified(userData.isVerified);
      
      await this.put<Record<string, string>>(`/users/${userId}`, updateData.toRecord());
    } catch (error) {
      console.error(`更新用户信息失败: ${userId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 添加评论
   * @param artifactId 文物ID
   * @param userId 用户ID
   * @param content 评论内容
   */
  async addComment(artifactId: string, userId: string, content: string): Promise<UserComment> {
    try {
      // 创建请求数据
      const commentData = new RequestData();
      commentData.setArtifactId(artifactId);
      commentData.setUserId(userId);
      commentData.setContent(content);
      
      const responseData = await this.post<CommentData>('/users/comments', commentData.toRecord());
      
      // 将API返回的数据转换为UserComment对象
      return new UserComment(
        responseData.id?.toString() || '',
        responseData.userId?.toString() || '',
        responseData.username?.toString() || '',
        responseData.avatarUrl?.toString() || '',
        responseData.content?.toString() || '',
        responseData.createTime?.toString() || '',
        responseData.artifactId?.toString() || ''
      );
    } catch (error) {
      console.error('添加评论失败', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户评论
   * @param userId 用户ID
   */
  async getUserComments(userId: string): Promise<UserComment[]> {
    try {
      const items = await this.get<Array<CommentData>>(`/users/${userId}/comments`);
      
      // 将API返回的数据转换为UserComment对象数组
      return items.map(item => new UserComment(
        item.id?.toString() || '',
        item.userId?.toString() || '',
        item.username?.toString() || '',
        item.avatarUrl?.toString() || '',
        item.content?.toString() || '',
        item.createTime?.toString() || '',
        item.artifactId?.toString() || ''
      ));
    } catch (error) {
      console.error(`获取用户评论失败: ${userId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 添加收藏
   * @param userId 用户ID
   * @param artifactId 文物ID
   */
  async addFavorite(userId: string, artifactId: string): Promise<void> {
    try {
      // 创建请求数据
      const favoriteData = new RequestData();
      favoriteData.setUserId(userId);
      favoriteData.setArtifactId(artifactId);
      
      await this.post<Record<string, string>>('/users/favorites', favoriteData.toRecord());
    } catch (error) {
      console.error('添加收藏失败', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 取消收藏
   * @param userId 用户ID
   * @param artifactId 文物ID
   */
  async removeFavorite(userId: string, artifactId: string): Promise<void> {
    try {
      await this.delete<Record<string, string>>(`/users/${userId}/favorites/${artifactId}`);
    } catch (error) {
      console.error('取消收藏失败', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户收藏
   * @param userId 用户ID
   */
  async getUserFavorites(userId: string): Promise<Artifact[]> {
    try {
      const items = await this.get<Array<GenericRecord>>(`/users/${userId}/favorites`);
      
      // 将API返回的数据转换为Artifact对象数组
      return items.map(item => new Artifact(
        item.id?.toString() || '',
        item.name?.toString() || '',
        item.era?.toString() || '',
        item.museum?.toString() || '',
        item.description?.toString() || '',
        '', // 原来的imageUrl，现在没有了
        typeof item.type === 'number' ? item.type : 7,
        '', // 原来的detailUrl，现在没有了
        0,  // 原来的likes，现在没有了
        0   // 原来的comments，现在没有了
      ));
    } catch (error) {
      console.error(`获取用户收藏失败: ${userId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
} 