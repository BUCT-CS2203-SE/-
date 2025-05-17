import { UserComment } from '../model/UserModel';
import { Constants } from '../common/constants/Constants';
import http from '@ohos.net.http';
import preferences from '@ohos.data.preferences';
import { StorageService } from './StorageService';
import { CommentData } from '../model/CommentModel';
import { ApiResponse } from '../model/ApiModel';
import { Comment } from '../model/PostModel';

/**
 * HTTP响应接口
 */
interface HttpResponseData {
  data: CommentData;
}

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

/**
 * 评论服务类
 */
export class CommentService {
  private storageService: StorageService = new StorageService();
  private readonly COMMENTS_KEY = 'comments';

  /**
   * 获取所有评论
   */
  async getAllComments(): Promise<UserComment[]> {
    const comments = await this.storageService.get<UserComment[]>(this.COMMENTS_KEY, []);
    return comments;
  }
  
  /**
   * 保存评论
   * @param comment 评论内容
   */
  async saveComment(comment: UserComment): Promise<void> {
    const comments = await this.getAllComments();
    const index = comments.findIndex(c => c.id === comment.id);
    
    if (index === -1) {
      comments.push(comment);
    } else {
      comments[index] = comment;
    }

    await this.storageService.set(this.COMMENTS_KEY, comments);
  }
  
  /**
   * 获取指定动态的评论
   * @param postId 动态ID
   */
  async getCommentsByPostId(postId: string): Promise<UserComment[]> {
    const comments = await this.getAllComments();
    return comments.filter(comment => comment.artifactId === postId);
  }
  
  /**
   * 删除评论
   * @param commentId 评论ID
   */
  async deleteComment(commentId: string): Promise<void> {
    const comments = await this.getAllComments();
    const filteredComments = comments.filter(comment => comment.id !== commentId);
    await this.storageService.set(this.COMMENTS_KEY, filteredComments);
  }

  /**
   * 获取帖子评论列表
   * @param postId 帖子ID
   */
  static async getCommentsByPostId(postId: string): Promise<Comment[]> {
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
        const responseData = JSON.parse(response.result as string) as Comment[];
        return responseData || [];
      } else {
        console.error(`获取评论失败: ${response.responseCode}`);
        return [];
      }
    } catch (error) {
      const typedError = error as ErrorWithMessage;
      console.error(`获取评论异常: ${typedError.message}`);
      return [];
    }
  }
  
  /**
   * 添加评论
   * @param commentData 评论数据
   */
  static async addComment(commentData: CommentData): Promise<ApiResponse<CommentData>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/comments`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(commentData)
      });
      
      if (response.responseCode === 201) {
        const responseText = response.result as string;
        const parsedResult = JSON.parse(responseText) as HttpResponseData;
        return {
          code: 0,
          message: '评论发布成功',
          data: parsedResult.data
        };
      } else {
        return {
          code: response.responseCode,
          message: `评论发布失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const typedError = error as ErrorWithMessage;
      return {
        code: 500,
        message: `评论发布异常: ${typedError.message}`
      };
    }
  }
  
  /**
   * 删除评论
   * @param commentId 评论ID
   */
  static async deleteComment(commentId: string): Promise<ApiResponse<null>> {
    try {
      const httpRequest = http.createHttp();
      const url = `${Constants.BASE_URL}/comments/${commentId}`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.responseCode === 200) {
        return {
          code: 0,
          message: '评论删除成功',
          data: null
        };
      } else {
        return {
          code: response.responseCode,
          message: `评论删除失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      const typedError = error as ErrorWithMessage;
      return {
        code: 500,
        message: `评论删除异常: ${typedError.message}`
      };
    }
  }
}

export default new CommentService(); 