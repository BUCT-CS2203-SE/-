import { ApiService } from './ApiService';
import { Artifact } from '../model/ArtifactModel';
import { RelicInfo } from '../model/UserModel';
import { BrowseItem, BrowseRequestData } from '../model/BrowseModel';
import http from '@ohos.net.http';

/**
 * 文物图片接口
 */
interface RelicPhoto {
  photo_id: number;
  photo_url: string;
}

/**
 * 浏览记录响应接口
 */
interface BrowseResponse {
  message: string;
  data: BrowseItem[];
}

/**
 * 浏览记录JSON数据接口
 */
export interface BrowseItemJson {
  browse_id: number;
  user_id: number;
  relic_id: number;
  browse_time: string;
  relic: RelicInfo;
}

/**
 * 浏览记录数据接口
 */
export interface BrowseItemData {
  browse_id: number;
  user_id: number;
  relic_id: number;
  browse_time: string;
  relic: RelicInfo;
}

/**
 * 浏览记录请求数据JSON接口
 */
export interface BrowseRequestDataJson {
  user_id: number;
  relic_id: number;
}

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

export class UserBrowseService {
  private apiService: ApiService = new ApiService();

  /**
   * 获取用户浏览历史
   * @param userId 用户ID
   */
  async getUserBrowses(userId: string): Promise<BrowseItem[]> {
    try {
      const response = await this.apiService.getUserBrowses(userId);
      if (!response || !Array.isArray(response)) {
        console.error('获取用户浏览历史失败: 响应数据格式错误');
        return [];
      }
      return response;
    } catch (error) {
      console.error('获取用户浏览历史失败:', error);
      return [];
    }
  }

  /**
   * 获取用户最近浏览记录
   * @param userId 用户ID
   * @param limit 返回记录数量
   */
  async getRecentBrowses(userId: string, limit: number = 10): Promise<BrowseItem[]> {
    try {
      const response = await this.apiService.getRecentBrowses(userId, limit);
      if (!response || !Array.isArray(response)) {
        console.error('获取最近浏览记录失败: 响应数据格式错误');
        return [];
      }
      return response;
    } catch (error) {
      console.error('获取最近浏览记录失败:', error);
      return [];
    }
  }

  /**
   * 添加浏览记录
   * @param userId 用户ID
   * @param relicId 文物ID
   */
  async addBrowse(userId: string, relicId: string): Promise<void> {
    try {
      console.info('开始创建浏览记录请求数据，用户ID:', userId, '文物ID:', relicId);
      const requestData = new BrowseRequestData(
        Number(userId),
        Number(relicId)
      );
      console.info('浏览记录请求数据:', JSON.stringify(requestData.toJson()));
      await this.apiService.addBrowse(requestData);
      console.info('浏览记录添加成功');
    } catch (error) {
      console.error('添加浏览记录失败:', error);
      throw new Error(error instanceof Error ? error.message : String(error));
    }
  }

  /**
   * 清空用户浏览历史
   * @param userId 用户ID
   */
  async clearBrowses(userId: string): Promise<void> {
    try {
      await this.apiService.clearBrowses(userId);
    } catch (error) {
      console.error('清空浏览历史失败:', error);
      throw new Error(error instanceof Error ? error.message : String(error));
    }
  }

  /**
   * 删除单条浏览记录
   * @param browseId 浏览记录ID
   */
  async deleteBrowse(browseId: string): Promise<void> {
    try {
      await this.apiService.deleteBrowse(browseId);
    } catch (error) {
      console.error('删除浏览记录失败:', error);
      throw new Error(error instanceof Error ? error.message : String(error));
    }
  }
} 