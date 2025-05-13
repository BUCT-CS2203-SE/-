/**
 * API服务类，用于处理与后端的通信
 */
import http from '@ohos.net.http';
import { Artifact } from '../model/ArtifactModel';
import { User, UserRelicComment, RelicInfo } from '../model/UserModel';

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
 * HTTP头部接口
 */
interface HttpHeader {
  'Content-Type': string;
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
 * 通用响应接口
 */
interface GenericResponse {
  message: string;
}

/**
 * 文物图片接口
 */
interface ArtifactPhoto {
  photo_id: number;
  relic_id: number;
  photo_url: string;
}

/**
 * 文物响应接口
 */
interface ArtifactResponse {
  message: string;
  data: Array<ArtifactData>;
  total?: number;
  currentPage?: number;
  pageSize?: number;
}

/**
 * 文物数据接口
 */
interface ArtifactData {
  relic_id: number;
  name: string;
  type: number;
  era: string;
  museum: string;
  description: string;
  spare_id: number;
  photos?: Array<ArtifactPhoto>;
}

/**
 * 通用记录接口
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
  user_id?: number;
  nickname?: string;
  gender?: number;
  phone?: string;
  email?: string;
  img_url?: string;
  spare?: string;
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
 * 评论响应数据接口
 */
interface CommentResponseData {
  relic_comment_id: number;
  relic_id: number;
  user_id: string;
  comment: string;
  comment_time: string;
}

/**
 * 评论响应接口
 */
interface CommentResponse {
  message: string;
  data: CommentResponseData;
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
 * 登录响应接口
 */
interface LoginResponse {
  message: string;
  user: User;
}

/**
 * 注册请求数据接口
 */
interface RegisterData {
  phone: string;
  password: string;
  email: string;
  nickname?: string;
  gender?: number;
  img_url?: string;
}

/**
 * 登录请求数据接口
 */
interface LoginData {
  phone: string;
  password: string;
}

/**
 * 用户信息更新数据接口
 */
interface UpdateUserData {
  nickname?: string;
  gender?: number;
  email?: string;
  img_url?: string;
  spare?: string;
}

/**
 * 请求数据接口
 */
interface RequestDataInterface {
  username?: string;
  password?: string;
  email?: string;
  userId?: string;
  artifactId?: string;
  content?: string;
  avatarUrl?: string;
  isVerified?: boolean;
}

/**
 * 请求数据构造类
 */
class RequestData {
  private data: RequestDataInterface = {};
  
  /**
   * 设置用户名
   */
  setUsername(value: string): void {
    this.data.username = value;
  }
  
  /**
   * 设置密码
   */
  setPassword(value: string): void {
    this.data.password = value;
  }
  
  /**
   * 设置邮箱
   */
  setEmail(value: string): void {
    this.data.email = value;
  }
  
  /**
   * 设置用户ID
   */
  setUserId(value: string): void {
    this.data.userId = value;
  }
  
  /**
   * 设置文物ID
   */
  setArtifactId(value: string): void {
    this.data.artifactId = value;
  }
  
  /**
   * 设置内容
   */
  setContent(value: string): void {
    this.data.content = value;
  }
  
  /**
   * 设置头像URL
   */
  setAvatarUrl(value: string): void {
    this.data.avatarUrl = value;
  }
  
  /**
   * 设置是否验证
   */
  setIsVerified(value: boolean): void {
    this.data.isVerified = value;
  }
  
  /**
   * 转换为请求数据
   */
  toRecord(): RequestDataInterface {
    return this.data;
  }
}

/**
 * 默认HTTP头部
 */
const DEFAULT_HEADER: HttpHeader = {
  'Content-Type': 'application/json'
};

/**
 * API服务类
 */
interface GeneratedTypeLiteralInterface_1 {
  message: string;
}

interface UpdateUserResponse {
  message: string;
}

/**
 * 注册响应接口
 */
interface RegisterResponse {
  user: User;
  message: string;
    }

/**
 * 文物评论响应接口
 */
interface RelicCommentResponse {
  relic_comment_id: number;
  relic_id: number;
  user_id: number;
  comment: string;
  comment_time: string;
}

/**
 * 收藏文物数据接口
 */
interface FavoriteRelicData {
  relic_id: number;
  name: string;
  type: number;
  era: string;
  museum: string;
  description: string;
  spare_id: number;
  photos: Array<FavoritePhoto>;
}

/**
 * 收藏文物图片接口
 */
interface FavoritePhoto {
  photo_id: number;
  relic_id: number;
  photo_url: string;
}

/**
 * 收藏响应数据接口
 */
interface FavoriteResponse {
  fav_id: number;
  user_id: number;
  relic_id: number;
  relic: FavoriteRelicData;
}

/**
 * 收藏状态响应接口
 */
interface IsFavoriteResponse {
  isFavorite: boolean;
}

/**
 * API服务类
 */
export class ApiService {
  private readonly BASE_URL: string = 'http://localhost:3000/api';
  private readonly TIMEOUT: number = 10000;
  
  constructor() {
    console.info(`API服务初始化，BASE_URL: ${this.BASE_URL}`);
  }
  
  /**
   * 发送HTTP请求
   */
  private async sendRequest<T>(url: string, options: HttpRequestOptions): Promise<T> {
    let httpRequest = http.createHttp();
    try {
      console.info(`发送请求到: ${url}`);
      console.info(`请求选项: ${JSON.stringify(options)}`);
      
      let response = await httpRequest.request(url, options);
      console.info(`收到响应: ${response.result}`);
      
      if (response.responseCode === 200 || response.responseCode === 201) {
        const result = JSON.parse(response.result as string) as T;
        console.info(`解析响应数据: ${JSON.stringify(result)}`);
        return result;
      } else {
        console.error(`HTTP错误: ${response.responseCode}, 响应: ${response.result}`);
        throw new ApiError(`HTTP错误: ${response.responseCode}`);
      }
    } catch (error) {
      console.error(`请求失败: ${error instanceof Error ? error.message : String(error)}`);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    } finally {
      httpRequest.destroy();
    }
  }
  
  /**
   * 创建HTTP请求选项
   */
  private createRequestOptions(method: http.RequestMethod, extraData?: string): HttpRequestOptions {
    return {
      method: method,
      header: DEFAULT_HEADER,
      readTimeout: this.TIMEOUT,
      connectTimeout: this.TIMEOUT,
      extraData: extraData
    };
  }
  
  /**
   * 获取文物列表
   * @param type 类型ID
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getArtifactList(type?: number, page: number = 1, pageSize: number = 10): Promise<Artifact[]> {
    try {
      let url = `${this.BASE_URL}/artifacts?page=${page}&pageSize=${pageSize}`;
      if (type !== undefined) {
        url += `&type=${type}`;
      }
      
      const response = await this.sendRequest<ArtifactResponse>(
        url,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为Artifact对象
      return response.data.map(item => new Artifact(
        item.relic_id.toString(),
        item.name,
        item.era,
        item.museum,
        item.description,
        item.photos?.[0]?.photo_url || '', // 使用第一张图片作为主图
        item.type,
        '', // detailUrl
        0,  // likes
        0,  // comments
        item.photos?.map(photo => photo.photo_url) || [] // 所有图片URL
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
      const response = await this.sendRequest<ArtifactData>(
        `${this.BASE_URL}/artifacts/${id}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为Artifact对象
      return new Artifact(
        response.relic_id.toString(),
        response.name,
        response.era,
        response.museum,
        response.description,
        response.photos?.[0]?.photo_url || '', // 使用第一张图片作为主图
        response.type,
        '', // detailUrl
        0,  // likes
        0,  // comments
        response.photos?.map(photo => photo.photo_url) || [] // 所有图片URL
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
      const response = await this.sendRequest<ArtifactResponse>(
        `${this.BASE_URL}/artifacts?keyword=${encodeURIComponent(keyword)}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为Artifact对象数组
      return response.data.map(item => new Artifact(
        item.relic_id.toString(),
        item.name,
        item.era,
        item.museum,
        item.description,
        item.photos?.[0]?.photo_url || '', // 使用第一张图片作为主图
        item.type,
        '', // detailUrl
        0,  // likes
        0,  // comments
        item.photos?.map(photo => photo.photo_url) || [] // 所有图片URL
      ));
    } catch (error) {
      console.error(`搜索文物失败: ${keyword}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取文物评论
   * @param relicId 文物ID
   */
  async getArtifactComments(relicId: string): Promise<UserRelicComment[]> {
    try {
      const response = await this.sendRequest<Array<RelicCommentResponse>>(
        `${this.BASE_URL}/relic-comments/relic/${relicId}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为UserRelicComment对象数组
      return response.map(item => new UserRelicComment(
        item.relic_comment_id.toString(),
        item.relic_id.toString(),
        item.user_id.toString(),
        item.comment,
        item.comment_time
      ));
    } catch (error) {
      console.error(`获取文物评论失败: ${relicId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 用户登录
   */
  async login(phone: string, password: string): Promise<LoginResponse> {
    const url = `${this.BASE_URL}/users/login`;
    console.info(`准备发送登录请求到: ${url}`);
    
    const options = this.createRequestOptions(
      http.RequestMethod.POST,
      JSON.stringify({ phone, password })
    );
    console.info('登录请求选项:', JSON.stringify(options));
    
    try {
      const response = await this.sendRequest<LoginResponse>(url, options);
      console.info('登录响应:', JSON.stringify(response));
      return response;
    } catch (error) {
      console.error('登录请求失败:', error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 用户注册
   */
  async register(phone: string, password: string, email: string, nickname?: string): Promise<RegisterResponse> {
    const url = `${this.BASE_URL}/users/register`;
    const data: RegisterData = {
      phone,
      password,
      email,
      nickname
    };
    
    console.info(`准备注册数据: ${JSON.stringify(data)}`);
    
    const options = this.createRequestOptions(
      http.RequestMethod.POST,
      JSON.stringify(data)
    );
    
    try {
      // 直接接收用户数据
      const userData = await this.sendRequest<UserData>(url, options);
      console.info(`注册响应: ${JSON.stringify(userData)}`);
      
      // 将后端返回的用户数据转换为User对象
      const userId = userData.user_id?.toString() || '';
      const user = new User(
        userId,
        userData.nickname?.toString() || '',
        userData.img_url?.toString() || '',
        userData.email?.toString() || '',
        userData.isVerified ?? false,
        []
      );
      
      return {
        user: user,
        message: '注册成功，请登录'
      };
    } catch (error) {
      console.error(`注册失败: ${error instanceof Error ? error.message : String(error)}`);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 获取用户信息
   * @param userId 用户ID
   */
  async getUserInfo(userId: string): Promise<User> {
    try {
      const userData = await this.sendRequest<UserData>(`/users/${userId}`, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
        readTimeout: this.TIMEOUT,
        connectTimeout: this.TIMEOUT
      });
      
      // 将API返回的数据转换为User对象
      const id = userData.user_id?.toString() || '';
      return new User(
        id,
        userData.nickname?.toString() || '',
        userData.img_url?.toString() || '',
        userData.email?.toString() || '',
        userData.isVerified ?? false,
        []
      );
    } catch (error) {
      console.error(`获取用户信息失败: ${userId}`, error);
      throw new ApiError(error instanceof Error ? error.message : String(error));
    }
  }
  
  /**
   * 更新用户信息
   */
  async updateUserInfo(userId: number, userData: UpdateUserData): Promise<boolean> {
    const url = `${this.BASE_URL}/users/${userId}`;
    const options = this.createRequestOptions(
      http.RequestMethod.PUT,
      JSON.stringify(userData)
    );
    
    const response = await this.sendRequest<UpdateUserResponse>(url, options);
    return response.message === "用户信息更新成功。";
  }
  
  /**
   * 添加评论
   * @param relicId 文物ID
   * @param userId 用户ID
   * @param content 评论内容
   */
  async addComment(relicId: string, userId: string, content: string): Promise<UserRelicComment> {
    try {
      const response = await this.sendRequest<CommentResponse>(
        `${this.BASE_URL}/relic-comments`,
        this.createRequestOptions(
          http.RequestMethod.POST,
          JSON.stringify({
            relic_id: relicId,
            user_id: userId,
            comment: content
          })
        )
      );
      
      // 将API返回的数据转换为UserRelicComment对象
      return new UserRelicComment(
        response.data.relic_comment_id.toString(),
        response.data.relic_id.toString(),
        response.data.user_id,
        response.data.comment,
        response.data.comment_time
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
  async getUserComments(userId: string): Promise<UserRelicComment[]> {
    try {
      const response = await this.sendRequest<Array<RelicCommentResponse>>(
        `${this.BASE_URL}/relic-comments/user/${userId}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为UserRelicComment对象数组
      return response.map(item => new UserRelicComment(
        item.relic_comment_id.toString(),
        item.relic_id.toString(),
        item.user_id.toString(),
        item.comment,
        item.comment_time
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
      
      await this.sendRequest<GenericResponse>(
        `${this.BASE_URL}/relic-favorites`,
        this.createRequestOptions(
          http.RequestMethod.POST,
          JSON.stringify({
            user_id: userId,
            relic_id: artifactId
          })
        )
      );
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
      await this.sendRequest<GenericResponse>(
        `${this.BASE_URL}/relic-favorites/${userId}/${artifactId}`,
        this.createRequestOptions(http.RequestMethod.DELETE)
      );
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
      const response = await this.sendRequest<Array<FavoriteResponse>>(
        `${this.BASE_URL}/relic-favorites/user/${userId}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      
      // 将API返回的数据转换为Artifact对象数组
      return response.map(item => {
        const relic = item.relic;
        const imageUrl = relic.photos && relic.photos.length > 0 ? relic.photos[0].photo_url : '';
        return new Artifact(
          relic.relic_id.toString(),
          relic.name,
          relic.era,
          relic.museum,
          relic.description,
          imageUrl, // 使用photos数组中的第一张图片URL
          relic.type,
        '', // detailUrl
          0, // likes
          0, // comments
          relic.photos?.map(photo => photo.photo_url) || [] // 所有图片URL
        );
      });
    } catch (error) {
      console.error('获取用户收藏失败:', error);
      throw new ApiError('获取用户收藏失败', error.statusCode || 500);
    }
  }

  /**
   * 删除评论
   * @param commentId 评论ID
   */
  async deleteComment(commentId: string): Promise<boolean> {
    try {
      const response = await this.sendRequest<CommentResponse>(
        `${this.BASE_URL}/relic-comments/${commentId}`,
        this.createRequestOptions(http.RequestMethod.DELETE)
      );
      return response.message === '评论删除成功！';
    } catch (error) {
      console.error(`删除评论失败: ${error}`);
      return false;
    }
  }

  /**
   * 判断用户是否收藏了某个文物
   */
  async isFavorite(userId: string, artifactId: string): Promise<boolean> {
    try {
      const response = await this.sendRequest<IsFavoriteResponse>(
        `${this.BASE_URL}/relic-favorites/user/${userId}/${artifactId}`,
        this.createRequestOptions(http.RequestMethod.GET)
      );
      return response.isFavorite;
    } catch (error) {
      console.error('查询收藏状态失败:', error);
      return false;
    }
  }
} 