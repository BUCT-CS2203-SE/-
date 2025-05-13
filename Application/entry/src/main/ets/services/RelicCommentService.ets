import { UserRelicComment } from '../model/UserModel';
import { ApiService } from './ApiService';

/**
 * 文物评论服务类
 */
export class RelicCommentService {
  private apiService: ApiService = new ApiService();

  /**
   * 获取文物评论
   * @param relicId 文物ID
   */
  async getRelicComments(relicId: string): Promise<UserRelicComment[]> {
    try {
      return await this.apiService.getArtifactComments(relicId);
    } catch (error) {
      console.error(`获取文物评论失败: ${error}`);
      return [];
    }
  }

  /**
   * 获取用户评论
   * @param userId 用户ID
   */
  async getUserComments(userId: string): Promise<UserRelicComment[]> {
    try {
      return await this.apiService.getUserComments(userId);
    } catch (error) {
      console.error(`获取用户评论失败: ${error}`);
      return [];
    }
  }

  /**
   * 添加评论
   * @param relicId 文物ID
   * @param userId 用户ID
   * @param content 评论内容
   */
  async addComment(relicId: string, userId: string, content: string): Promise<UserRelicComment | null> {
    try {
      return await this.apiService.addComment(relicId, userId, content);
    } catch (error) {
      console.error(`添加评论失败: ${error}`);
      return null;
    }
  }

  /**
   * 删除评论
   * @param commentId 评论ID
   */
  async deleteComment(commentId: string): Promise<boolean> {
    try {
      return await this.apiService.deleteComment(commentId);
    } catch (error) {
      console.error(`删除评论失败: ${error}`);
      return false;
    }
  }
} 