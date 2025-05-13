/**
 * 帖子服务类，用于处理帖子相关的API请求
 */
import http from '@ohos.net.http';
import { Constants } from '../common/constants/Constants';
import { Post, PostResponse, LikeResponse, FavoriteResponse } from '../model/PostModel';
import { ApiResponse } from '../model/ApiModel';

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
      console.error(`获取帖子列表异常: ${error.message}`);
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
      console.error(`获取帖子详情异常: ${error.message}`);
      return null;
    }
  }
  
  /**
   * 创建新帖子
   * @param postData 帖子数据
   */
  static async createPost(postData: Partial<Post>): Promise<ApiResponse<Post>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/posts`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(postData)
      });
      
      if (response.responseCode === 201) {
        return {
          code: 0,
          message: '帖子发布成功',
          data: JSON.parse(response.result as string).data
        };
      } else {
        return {
          code: response.responseCode,
          message: `帖子发布失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      return {
        code: 500,
        message: `帖子发布异常: ${error.message}`
      };
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
        return {
          code: 0,
          message: '点赞成功',
          data: JSON.parse(response.result as string).data
        };
      } else {
        return {
          code: response.responseCode,
          message: `点赞失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      return {
        code: 500,
        message: `点赞异常: ${error.message}`
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
        return {
          code: 0,
          message: '取消点赞成功',
          data: JSON.parse(response.result as string).data
        };
      } else {
        return {
          code: response.responseCode,
          message: `取消点赞失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      return {
        code: 500,
        message: `取消点赞异常: ${error.message}`
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
        extraData: JSON.stringify({ is_favorited: isFavorited })
      });
      
      if (response.responseCode === 200) {
        return {
          code: 0,
          message: isFavorited ? '收藏成功' : '取消收藏成功',
          data: JSON.parse(response.result as string).data
        };
      } else {
        return {
          code: response.responseCode,
          message: `${isFavorited ? '收藏' : '取消收藏'}失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      return {
        code: 500,
        message: `${isFavorited ? '收藏' : '取消收藏'}异常: ${error.message}`
      };
    }
  }
}

export default new PostService(); 