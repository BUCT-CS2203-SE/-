/**
 * 帖子服务类，用于处理帖子相关的API请求
 */
import http from '@ohos.net.http';
import { Constants } from '../common/constants/Constants';
import { Post, PostResponse, LikeResponse, FavoriteResponse } from '../model/PostModel';
import { ApiResponse } from '../model/ApiModel';
import { Comment } from '../model/PostModel';

// 定义响应数据类型
interface PostResponseData {
  data: Post;
}

interface PostResponseDataWithOptional {
  data?: Post;
}

interface LikeResponseData {
  data: LikeResponse;
}

interface FavoriteResponseData {
  data: FavoriteResponse;
}

export class PostService {
  /**
   * 获取帖子列表（分页）
   * @param page 页码
   * @param pageSize 每页数量
   * @param keyword 搜索关键词（可选）
   */
  static async getPosts(page: number = 1, pageSize: number = 10, keyword?: string): Promise<PostResponse> {
    try {
      const httpRequest = http.createHttp();
      let url = `${Constants.BASE_URL}/posts?page=${page}&pageSize=${pageSize}`;
      
      if (keyword) {
        url += `&keyword=${encodeURIComponent(keyword)}`;
      }
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      } else {
        console.error(`获取帖子列表失败: ${response.responseCode}`);
        return {
          total: 0,
          currentPage: page,
          pageSize: pageSize,
          data: []
        };
      }
    } catch (error) {
      const err = error as Error;
      console.error(`获取帖子列表异常: ${err.message}`);
      return {
        total: 0,
        currentPage: page,
        pageSize: pageSize,
        data: []
      };
    }
  }
  
  /**
   * 获取单个帖子详情
   * @param postId 帖子ID
   */
  static async getPostById(postId: string): Promise<Post | null> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      } else {
        console.error(`获取帖子详情失败: ${response.responseCode}`);
        return null;
      }
    } catch (error) {
      const err = error as Error;
      console.error(`获取帖子详情异常: ${err.message}`);
      return null;
    }
  }
  
  /**
   * 创建新帖子
   * @param postData 帖子数据
   */
  static async createPost(postData: Partial<Post>): Promise<ApiResponse<Post>> {
    try {
      console.info('[DEBUG] 开始创建帖子，URL:', `${Constants.BASE_URL}/posts`);
      
      // 确保数据格式符合数据库要求
      const validatedData: Partial<Post> = {
        post_id: postData.post_id,
        content: postData.content || '',
        post_img_url: postData.post_img_url || '',
        likes: 0,
        is_favorited: 0,
        user_id: postData.user_id,
        nickname: postData.nickname || '用户',
        img_url: postData.img_url || '/common/images/default_avatar.png',
        create_time: postData.create_time,
        create_timestamp: postData.create_timestamp
      };
      
      console.info('[DEBUG] 帖子数据:', JSON.stringify(validatedData));
      
      const httpRequest = http.createHttp();
      
      // 设置重试次数
      const maxRetries = 3;
      let currentRetry = 0;
      let lastError: Error | null = null;
      
      while (currentRetry < maxRetries) {
        try {
          console.info(`[DEBUG] 尝试发送请求，第${currentRetry + 1}次尝试`);
          
          // 重要：确保URL格式正确
          let baseUrl = Constants.BASE_URL;
          if (baseUrl.endsWith('/')) {
            baseUrl = baseUrl.slice(0, -1);
          }
          const url = `${baseUrl}/posts`;
          console.info(`[DEBUG] 当前使用的API URL: ${url}`);
          
          // 创建请求
          const response = await httpRequest.request(url, {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // 确保不使用缓存
              'Cache-Control': 'no-cache, no-store',
              // 添加请求标识
              'X-Request-ID': `${Date.now()}-${Math.random().toString(36).substring(2, 15)}`
            },
            connectTimeout: 15000, // 连接超时15秒
            readTimeout: 15000,    // 读取超时15秒
            extraData: JSON.stringify(validatedData)
          });
          
          console.info('[DEBUG] 服务器响应码:', response.responseCode);
          console.info('[DEBUG] 响应数据:', response.result ? response.result.toString().substring(0, 100) + '...' : 'null');
          
          // 处理响应
          if (response.responseCode === 201 || response.responseCode === 200) {
            // 成功创建 - 处理200或201都可接受
            let responseData: PostResponseData | PostResponseDataWithOptional | Post;
            try {
              responseData = JSON.parse(response.result as string) as PostResponseData;
            } catch (e) {
              console.error('[DEBUG] 解析响应数据失败:', e);
              // 如果解析失败，尝试直接使用原始数据
              return {
                code: 0,
                message: '帖子发布成功',
                data: validatedData as Post // 使用提交的数据作为返回值
              };
            }
            
            console.info('[DEBUG] 解析后的响应数据:', JSON.stringify(responseData).substring(0, 100) + '...');
            
            // 如果有data字段使用data，否则使用整个响应
            return {
              code: 0,
              message: '帖子发布成功',
              data: responseData.data || (responseData as PostResponseDataWithOptional)?.data || (responseData as Post)
            };
          } else if (response.responseCode >= 500 || response.responseCode === 0) {
            // 服务器内部错误或连接失败
            console.error(`[DEBUG] 服务器错误或连接失败: ${response.responseCode}`);
            lastError = new Error(`服务器错误或连接失败: ${response.responseCode}`);
            currentRetry++;
            
            if (currentRetry < maxRetries) {
              // 等待一段时间后重试，逐渐增加等待时间
              const waitTime = 1000 * currentRetry;
              console.info(`[DEBUG] 等待${waitTime}毫秒后重试...`);
              await new Promise<void>(resolve => setTimeout(resolve, waitTime));
            }
          } else if (response.responseCode === 404) {
            // API路径不正确
            console.error(`[DEBUG] API路径不正确: ${url}`);
            return {
              code: 404,
              message: `API路径不正确: ${url}`
            };
          } else {
            // 其他错误状态码，不需要重试
            console.error(`[DEBUG] 服务器返回错误: ${response.responseCode}`);
            return {
              code: response.responseCode,
              message: `服务器返回错误: ${response.responseCode}`
            };
          }
        } catch (error) {
          const err = error as Error;
          console.error(`[DEBUG] 第${currentRetry + 1}次请求失败:`, err.message);
          
          // 检查是否为特定错误类型
          if (err.message.includes('timeout') || err.message.includes('超时')) {
            console.info('[DEBUG] 检测到超时错误，准备重试');
          } else if (err.message.includes('connect')) {
            console.info('[DEBUG] 检测到连接错误，准备重试');
          }
          
          lastError = err;
          currentRetry++;
          
          if (currentRetry < maxRetries) {
            // 等待一段时间后重试，逐渐增加等待时间
            const waitTime = 1000 * currentRetry;
            console.info(`[DEBUG] 等待${waitTime}毫秒后重试...`);
            await new Promise<void>(resolve => setTimeout(resolve, waitTime));
          }
        } finally {
          // 确保在每次尝试后都关闭HTTP请求
          if (httpRequest) {
            try {
              httpRequest.destroy();
              console.info('[DEBUG] HTTP请求已关闭');
            } catch (e) {
              console.error('[DEBUG] 关闭HTTP请求失败:', e instanceof Error ? e.message : String(e));
            }
          }
        }
      }
      
      // 所有重试都失败了
      return {
        code: 500,
        message: `帖子发布异常: ${lastError?.message || '未知错误'}`
      };
    } catch (error) {
      const err = error as Error;
      console.error('[DEBUG] 帖子发布异常:', err.message);
      return {
        code: 500,
        message: `帖子发布异常: ${err.message}`
      };
    } finally {
      console.info('[DEBUG] 帖子发布请求完成');
    }
  }
  
  /**
   * 更新帖子点赞数
   * @param postId 帖子ID
   */
  static async likePost(postId: string): Promise<ApiResponse<LikeResponse>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}/likes`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        const responseData = JSON.parse(response.result as string) as LikeResponseData;
        return {
          code: 0,
          message: '点赞成功',
          data: responseData.data
        };
      } else {
        return {
          code: response.responseCode,
          message: `点赞失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const err = error as Error;
      return {
        code: 500,
        message: `点赞异常: ${err.message}`
      };
    }
  }
  
  /**
   * 取消帖子点赞
   * @param postId 帖子ID
   */
  static async unlikePost(postId: string): Promise<ApiResponse<LikeResponse>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}/unlike`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        const responseData = JSON.parse(response.result as string) as LikeResponseData;
        return {
          code: 0,
          message: '取消点赞成功',
          data: responseData.data
        };
      } else {
        return {
          code: response.responseCode,
          message: `取消点赞失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const err = error as Error;
      return {
        code: 500,
        message: `取消点赞异常: ${err.message}`
      };
    }
  }
  
  /**
   * 更新帖子收藏状态
   * @param postId 帖子ID
   * @param isFavorited 是否收藏
   */
  static async updateFavorite(postId: string, isFavorited: boolean): Promise<ApiResponse<FavoriteResponse>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}/favorite`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ is_favorited: isFavorited ? 1 : 0 })
      });
      
      if (response.responseCode === 200) {
        const responseData = JSON.parse(response.result as string) as FavoriteResponseData;
        return {
          code: 0,
          message: isFavorited ? '收藏成功' : '取消收藏成功',
          data: responseData.data
        };
      } else {
        return {
          code: response.responseCode,
          message: `${isFavorited ? '收藏' : '取消收藏'}失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const err = error as Error;
      return {
        code: 500,
        message: `${isFavorited ? '收藏' : '取消收藏'}异常: ${err.message}`
      };
    }
  }
  
  /**
   * 获取帖子评论
   * @param postId 帖子ID
   */
  static async getComments(postId: string): Promise<ApiResponse<Comment[]>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}/comments`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        const comments = JSON.parse(response.result as string) as Comment[];
        return {
          code: 0,
          message: '获取评论成功',
          data: comments
        };
      } else {
        return {
          code: response.responseCode,
          message: `获取评论失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const err = error as Error;
      return {
        code: 500,
        message: `获取评论异常: ${err.message}`
      };
    }
  }
  
  /**
   * 删除帖子
   * @param postId 帖子ID
   */
  static async deletePost(postId: string): Promise<ApiResponse<null>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts/${postId}`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        return {
          code: 0,
          message: '删除帖子成功'
        };
      } else {
        return {
          code: response.responseCode,
          message: `删除帖子失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const err = error as Error;
      return {
        code: 500,
        message: `删除帖子异常: ${err.message}`
      };
    }
  }
}

export default new PostService(); 