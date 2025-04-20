import { Artifact } from '../model/ArtifactModel';
import { Constants } from '../common/constants/Constants';
import http from '@ohos.net.http';

/**
 * API响应数据结构
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * 文物数据结构
 */
interface ArtifactData {
  id: string;
  name: string;
  era: string;
  museum: string;
  description: string;
  imageUrl: string;
  categoryId: number;
  detailUrl: string;
  likes: number;
  comments: number;
}

/**
 * 文物服务类
 */
export class ArtifactService {
  /**
   * 获取文物列表
   * @param categoryId 类别ID，可选
   * @param page 页码
   * @param pageSize 每页数量
   */
  getArtifactList(categoryId?: number, page: number = 1, pageSize: number = 10): Promise<Artifact[]> {
    return new Promise((resolve, reject) => {
      // 构建请求URL
      let url = `${Constants.BASE_URL}/artifacts?page=${page}&pageSize=${pageSize}`;
      if (categoryId !== undefined) {
        url += `&categoryId=${categoryId}`;
      }
      
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<ArtifactData[]>;
              const artifacts: Artifact[] = responseData.data.map((item: ArtifactData) => {
                return new Artifact(
                  item.id,
                  item.name,
                  item.era,
                  item.museum,
                  item.description,
                  item.imageUrl,
                  item.categoryId,
                  item.detailUrl,
                  item.likes,
                  item.comments
                );
              });
              resolve(artifacts);
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
   * 获取文物详情
   * @param id 文物ID
   */
  getArtifactDetail(id: string): Promise<Artifact> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/artifacts/${id}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<ArtifactData>;
              const item = responseData.data;
              const artifact = new Artifact(
                item.id,
                item.name,
                item.era,
                item.museum,
                item.description,
                item.imageUrl,
                item.categoryId,
                item.detailUrl,
                item.likes,
                item.comments
              );
              resolve(artifact);
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
   * 搜索文物
   * @param keyword 搜索关键词
   */
  searchArtifacts(keyword: string): Promise<Artifact[]> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/artifacts/search?keyword=${encodeURIComponent(keyword)}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<ArtifactData[]>;
              const artifacts: Artifact[] = responseData.data.map((item: ArtifactData) => {
                return new Artifact(
                  item.id,
                  item.name,
                  item.era,
                  item.museum,
                  item.description,
                  item.imageUrl,
                  item.categoryId,
                  item.detailUrl,
                  item.likes,
                  item.comments
                );
              });
              resolve(artifacts);
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
   * 图片搜索文物
   * @param imageData 图片数据（Base64编码）
   */
  searchByImage(imageData: string): Promise<Artifact[]> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      httpRequest.request(
        `${Constants.BASE_URL}/artifacts/searchByImage`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            imageData: imageData
          })
        },
        (err, data) => {
          if (!err) {
            // 解析响应数据
            try {
              const responseData = JSON.parse(data.result.toString()) as ApiResponse<ArtifactData[]>;
              const artifacts: Artifact[] = responseData.data.map((item: ArtifactData) => {
                return new Artifact(
                  item.id,
                  item.name,
                  item.era,
                  item.museum,
                  item.description,
                  item.imageUrl,
                  item.categoryId,
                  item.detailUrl,
                  item.likes,
                  item.comments
                );
              });
              resolve(artifacts);
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
} 