import { Artifact } from '../model/ArtifactModel';
import { Constants } from '../common/constants/Constants';
import { importObject, ArtifactService as CloudArtifactService, ArtifactData, CommentData } from 'cloud_objects';

// 定义华为云数据库相关接口
interface CloudDBZone {
  collection(name: string): CloudDBCollection;
  openCloudDBZone(name: string): void;
}

interface CloudDBCollection {
  where(condition: string, value: string | number): CloudDBCollection;
  or(): CloudDBCollection;
  orderBy(field: string, order: 'asc' | 'desc'): CloudDBCollection;
  skip(count: number): CloudDBCollection;
  limit(count: number): CloudDBCollection;
  get(): Promise<CloudDBResult | CommentDBResult>;
}

interface CloudDBResult {
  data: ArtifactData[];
}

interface CommentDBResult {
  data: CommentData[];
}

interface CloudDB {
  openCloudDBZone(name: string): void;
  collection(name: string): CloudDBCollection;
}

interface AGConnect {
  cloudDB(): CloudDB;
}

// 扩展 ArtifactData 接口
interface ExtendedArtifactData extends ArtifactData {
  width?: number;
  height?: number;
}

// 定义云对象响应接口
interface CloudServiceResponse {
  artifacts: ExtendedArtifactData[];
}

// 定义云服务请求参数接口
interface ArtifactListParams {
  categoryId?: number;
  page: number;
  pageSize: number;
}

// 定义云服务接口
interface CloudArtifactServiceInterface {
  getArtifactList(params: ArtifactListParams): Promise<CloudServiceResponse>;
  getArtifactDetail(id: string): Promise<ExtendedArtifactData>;
  searchArtifacts(keyword: string): Promise<ExtendedArtifactData[]>;
  getArtifactComments(artifactId: string): Promise<CommentData[]>;
}

/**
 * API响应数据结构
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * 文物服务类，用于处理文物相关的业务逻辑
 */
export class ArtifactService {
  private cloudService: CloudArtifactServiceInterface = importObject(CloudArtifactService) as CloudArtifactServiceInterface;
  private agcDb: CloudDB | null = null;
  
  // 模拟数据，作为云服务调用失败时的兜底
  private mockArtifacts: Artifact[] = [
    new Artifact(
      '1',
      '青铜鼎',
      '春秋战国',
      '中国国家博物馆',
      '青铜鼎是中国古代青铜礼器，是中国古代政治权力和社会地位的象征。这件青铜鼎形制宏大，纹饰精美，是春秋战国时期的代表性器物。',
      'https://example.com/artifact1.jpg',
      1,
      'https://example.com/detail1',
      150,
      42
    ),
    new Artifact(
      '2',
      '唐三彩马',
      '唐代',
      '陕西历史博物馆',
      '唐三彩是唐代特有的彩釉陶器，以黄、绿、白三色为主。这件唐三彩马栩栩如生，展现了唐代陶瓷工艺的高超水平。',
      'https://example.com/artifact2.jpg',
      2,
      'https://example.com/detail2',
      230,
      56
    ),
    new Artifact(
      '3',
      '清明上河图',
      '北宋',
      '故宫博物院',
      '《清明上河图》是北宋张择端创作的作品，全卷长528.7厘米，宽24.8厘米，描绘了北宋京城汴梁的繁华景象。',
      'https://example.com/artifact3.jpg',
      3,
      'https://example.com/detail3',
      500,
      120
    ),
    new Artifact(
      '4',
      '莫高窟壁画',
      '魏晋至元代',
      '敦煌研究院',
      '敦煌莫高窟是中国石窟艺术的瑰宝，现存洞窟492个，壁画面积45000多平方米，是世界上规模最大的佛教艺术宝库。',
      'https://example.com/artifact4.jpg',
      4,
      'https://example.com/detail4',
      320,
      87
    ),
    new Artifact(
      '5',
      '越王勾践剑',
      '春秋晚期',
      '湖北省博物馆',
      '越王勾践剑是中国出土的最著名的青铜剑之一，保存完好，锋利无比，是中国古代冶金、铸造和制剑技术的杰出代表。',
      'https://example.com/artifact5.jpg',
      1,
      'https://example.com/detail5',
      410,
      93
    )
  ];
  
  constructor() {
    try {
      // 初始化AGC云数据库
      const agconnect = globalThis.agconnect as AGConnect;
      if (agconnect && agconnect.cloudDB) {
        this.agcDb = agconnect.cloudDB();
        // 打开云数据库区域
        if (this.agcDb && this.agcDb.openCloudDBZone) {
          this.agcDb.openCloudDBZone('Museum');
          console.info('AGC云数据库初始化成功');
        } else {
          console.warn('AGC云数据库初始化部分失败: openCloudDBZone 方法不可用');
        }
      } else {
        console.warn('AGC云数据库初始化失败: cloudDB 不可用');
      }
    } catch (err) {
      console.error('初始化失败:', err instanceof Error ? err.message : String(err));
    }
  }

  /**
   * 获取文物列表
   * @param categoryId 类别ID，可选
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getArtifactList(categoryId?: number, page: number = 1, pageSize: number = 10): Promise<Artifact[]> {
    try {
      if (this.agcDb) {
        const query = this.agcDb.collection('Artifact');
        if (categoryId !== undefined) {
          query.where('categoryId == ?', categoryId);
        }
        
        const startIndex = (page - 1) * pageSize;
        query.skip(startIndex).limit(pageSize);
        
        const result = await query.get();
        if (result && result.data && result.data.length > 0) {
          const artifactData = (result as CloudDBResult).data;
          return artifactData.map(item => this.convertToArtifact(item as ExtendedArtifactData));
        }
      }
      
      try {
        const result = await this.cloudService.getArtifactList({
          categoryId: categoryId,
          page: page,
          pageSize: pageSize
        });
        return this.convertToArtifacts(result.artifacts);
      } catch (cloudErr) {
        console.warn('云对象获取文物列表失败，使用模拟数据:', cloudErr instanceof Error ? cloudErr.message : String(cloudErr));
      }
      
      console.info('使用模拟数据（文物列表）');
      let filteredArtifacts = this.mockArtifacts;
      if (categoryId !== undefined) {
        filteredArtifacts = filteredArtifacts.filter(item => item.categoryId === categoryId);
      }
      const startIdx = (page - 1) * pageSize;
      return filteredArtifacts.slice(startIdx, startIdx + pageSize);
    } catch (err) {
      console.error('获取文物列表失败:', err instanceof Error ? err.message : String(err));
      return this.mockArtifacts;
    }
  }
  
  /**
   * 获取文物详情
   * @param id 文物ID
   */
  async getArtifactDetail(id: string): Promise<Artifact> {
    try {
      if (this.agcDb) {
        // 使用AGC云数据库查询
        const query = this.agcDb.collection('Artifact').where('id == ?', id);
        const result = await query.get();
        if (result && result.data && result.data.length > 0) {
          return this.convertToArtifact(result.data[0] as ExtendedArtifactData);
        }
      }
      
      // 尝试使用云对象
      try {
        const artifactData = await this.cloudService.getArtifactDetail(id);
        return this.convertToArtifact(artifactData as ExtendedArtifactData);
      } catch (cloudErr) {
        console.warn('云对象获取文物详情失败，使用模拟数据:', cloudErr);
      }
      
      // 兜底返回模拟数据
      console.info('使用模拟数据（文物详情）');
      const mockArtifact = this.mockArtifacts.find(item => item.id === id);
      if (mockArtifact) {
        return mockArtifact;
      }
      return this.mockArtifacts[0];
    } catch (err) {
      console.error('获取文物详情失败:', err);
      // 返回模拟数据作为兜底方案
      return this.mockArtifacts[0];
    }
  }
  
  /**
   * 搜索文物
   * @param keyword 搜索关键词
   */
  async searchByKeyword(keyword: string): Promise<Artifact[]> {
    try {
      if (this.agcDb) {
        // 使用AGC云数据库搜索
        const query = this.agcDb.collection('Artifact')
          .where('name like ?', `%${keyword}%`)
          .or()
          .where('description like ?', `%${keyword}%`)
          .or()
          .where('museum like ?', `%${keyword}%`)
          .or()
          .where('era like ?', `%${keyword}%`);
        
        const result = await query.get();
        if (result && result.data && result.data.length > 0) {
          const artifactData = (result as CloudDBResult).data;
          return artifactData.map(item => this.convertToArtifact(item as ExtendedArtifactData));
        }
      }
      
      // 尝试使用云对象
      try {
        const artifacts = await this.cloudService.searchArtifacts(keyword);
        return this.convertToArtifacts(artifacts);
      } catch (cloudErr) {
        console.warn('云对象搜索文物失败，使用模拟数据:', cloudErr instanceof Error ? cloudErr.message : String(cloudErr));
      }
      
      // 兜底返回模拟数据
      console.info('使用模拟数据（文物搜索）');
      return this.mockArtifacts.filter(item => 
        item.name.includes(keyword) || 
        item.description.includes(keyword) || 
        item.museum.includes(keyword) || 
        item.era.includes(keyword)
      );
    } catch (err) {
      console.error('搜索文物失败:', err instanceof Error ? err.message : String(err));
      // 返回模拟数据作为兜底方案
      return this.mockArtifacts;
    }
  }
  
  /**
   * 图片搜索文物
   * @param imageData 图片数据（Base64编码）
   */
  async searchByImage(imageData: string): Promise<Artifact[]> {
    // 暂不支持图片搜索，使用模拟数据
    return this.getArtifactList(undefined, 1, 3);
  }

  /**
   * 获取文物评论
   */
  async getArtifactComments(artifactId: string): Promise<CommentData[]> {
    try {
      if (this.agcDb) {
        const query = this.agcDb.collection('Comment')
          .where('artifactId == ?', artifactId)
          .orderBy('createTimestamp', 'desc');
        
        const result = await query.get();
        if (result && result.data && Array.isArray(result.data) && result.data.length > 0) {
          return (result as CommentDBResult).data;
        }
      }
      
      // 尝试使用云对象
      try {
        return await this.cloudService.getArtifactComments(artifactId);
      } catch (cloudErr) {
        console.warn('云对象获取文物评论失败，使用模拟数据:', cloudErr instanceof Error ? cloudErr.message : String(cloudErr));
      }
      
      // 返回模拟数据
      const currentDate = new Date();
      return [
        {
          id: '1',
          artifactId: artifactId,
          userId: 'user1',
          username: '文物爱好者',
          avatarUrl: 'https://example.com/avatar1.jpg',
          content: '这件文物保存非常完好，令人惊叹！',
          createTime: currentDate.toISOString(),
          createTimestamp: currentDate
        }
      ];
    } catch (err) {
      console.error('获取文物评论失败:', err instanceof Error ? err.message : String(err));
      return [];
    }
  }
  
  /**
   * 将数据库对象转换为Artifact对象
   */
  private convertToArtifact(data: ExtendedArtifactData): Artifact {
    return new Artifact(
      data.id,
      data.name,
      data.era,
      data.museum,
      data.description,
      data.imageUrl,
      data.categoryId,
      data.detailUrl,
      data.width ?? 0,
      data.height ?? 0
    );
  }
  
  /**
   * 将数据库对象数组转换为Artifact对象数组
   */
  private convertToArtifacts(data: ExtendedArtifactData[]): Artifact[] {
    return data.map(item => this.convertToArtifact(item));
  }

  /**
   * 将时间戳转换为Date对象
   */
  private convertTimestampToDate(timestamp: number): Date {
    return new Date(timestamp);
  }
} 