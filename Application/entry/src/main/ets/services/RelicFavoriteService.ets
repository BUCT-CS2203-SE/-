import { ApiService } from './ApiService';
import { FavoriteItem } from '../model/ArtifactModel';
import { Artifact } from '../model/ArtifactModel';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

export class RelicFavoriteService {
  private apiService: ApiService = new ApiService();

  // 获取用户收藏列表
  async getUserFavorites(userId: string): Promise<FavoriteItem[]> {
    try {
      const favorites = await this.apiService.getUserFavorites(userId);
      // 将API返回的数据转换为FavoriteItem对象数组
      return favorites.map((artifact: Artifact): FavoriteItem => ({
        id: parseInt(artifact.id),
        name: artifact.name,
        era: artifact.era,
        museum: artifact.museum,
        imageUrl: artifact.photos && artifact.photos.length > 0 ? artifact.photos[0] : artifact.imageUrl || '' // 优先使用photos数组中的第一张图片
      }));
    } catch (error) {
      console.error('获取用户收藏失败:', error);
      return [];
    }
  }

  // 添加收藏
  async addFavorite(userId: string, artifactId: string): Promise<void> {
    try {
      await this.apiService.addFavorite(userId, artifactId);
    } catch (error) {
      console.error('添加收藏失败:', error);
      throw new Error(error instanceof Error ? error.message : String(error));
    }
  }

  // 取消收藏
  async removeFavorite(userId: string, artifactId: string): Promise<void> {
    try {
      await this.apiService.removeFavorite(userId, artifactId);
    } catch (error) {
      console.error('取消收藏失败:', error);
      throw new Error(error instanceof Error ? error.message : String(error));
    }
  }

  // 判断用户是否收藏了某个文物
  async isFavorite(userId: string, artifactId: string): Promise<boolean> {
    try {
      const response = await this.apiService.isFavorite(userId, artifactId);
      return response;
    } catch (error) {
      console.error('查询收藏状态失败:', error);
      return false;
    }
  }
} 