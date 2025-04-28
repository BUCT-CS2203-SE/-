import { UserComment } from '../model/UserModel';
import { Constants } from '../common/constants/Constants';
import http from '@ohos.net.http';
import preferences from '@ohos.data.preferences';
import { StorageService } from './StorageService';

/**
 * API响应数据结构
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
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
} 