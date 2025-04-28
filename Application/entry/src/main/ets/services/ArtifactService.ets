import { Artifact } from '../model/ArtifactModel';
import { Constants } from '../common/constants/Constants';
import { importObject, ArtifactService as CloudArtifactService, ArtifactData, CommentData } from 'cloud_objects';
import '@agconnect/api';
import '@agconnect/database';

// 导入AGConnect SDK
try {
  var agconnect = require('@agconnect/api');
  require('@agconnect/database');
} catch (e) {
  console.error('加载 AGConnect SDK 失败:', e);
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
  private cloudService: CloudArtifactService;
  private agcDb: any; // AGC云数据库客户端
  
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
      // 导入云对象
      this.cloudService = importObject(CloudArtifactService);
      
      // 初始化AGC云数据库
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
      console.error('初始化失败:', err);
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
        // 使用AGC云数据库查询
        const query = this.agcDb.collection('Artifact');
        if (categoryId !== undefined) {
          query.where('categoryId == ?', categoryId);
        }
        
        // 设置分页
        const startIndex = (page - 1) * pageSize;
        query.skip(startIndex).limit(pageSize);
        
        // 执行查询
        const result = await query.get();
        if (result && result.data && result.data.length > 0) {
          return result.data.map(item => this.convertToArtifact(item));
        }
      }
      
      // 尝试使用云对象
      try {
        const result = await this.cloudService.getArtifactList({
          categoryId: categoryId,
          page: page,
          pageSize: pageSize
        });
        return this.convertToArtifacts(result.artifacts);
      } catch (cloudErr) {
        console.warn('云对象获取文物列表失败，使用模拟数据:', cloudErr);
      }
      
      // 兜底返回模拟数据
      console.info('使用模拟数据（文物列表）');
      let filteredArtifacts = this.mockArtifacts;
      if (categoryId !== undefined) {
        filteredArtifacts = filteredArtifacts.filter(item => item.categoryId === categoryId);
      }
      const startIdx = (page - 1) * pageSize;
      return filteredArtifacts.slice(startIdx, startIdx + pageSize);
    } catch (err) {
      console.error('获取文物列表失败:', err);
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（文物列表）');
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
          return this.convertToArtifact(result.data[0]);
        }
      }
      
      // 尝试使用云对象
      try {
        const artifactData = await this.cloudService.getArtifactDetail(id);
        return this.convertToArtifact(artifactData);
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
          return result.data.map(item => this.convertToArtifact(item));
        }
      }
      
      // 尝试使用云对象
      try {
        const artifacts = await this.cloudService.searchArtifacts(keyword);
        return this.convertToArtifacts(artifacts);
      } catch (cloudErr) {
        console.warn('云对象搜索文物失败，使用模拟数据:', cloudErr);
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
      console.error('搜索文物失败:', err);
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
   * @param artifactId 文物ID
   */
  async getArtifactComments(artifactId: string): Promise<CommentData[]> {
    try {
      if (this.agcDb) {
        // 使用AGC云数据库查询
        const query = this.agcDb.collection('Comment')
          .where('artifactId == ?', artifactId)
          .orderBy('createTimestamp', 'desc');
        
        const result = await query.get();
        if (result && result.data && result.data.length > 0) {
          return result.data;
        }
      }
      
      // 尝试使用云对象
      try {
        return await this.cloudService.getArtifactComments(artifactId);
      } catch (cloudErr) {
        console.warn('云对象获取文物评论失败，使用模拟数据:', cloudErr);
      }
      
      // 兜底返回模拟数据
      console.info('使用模拟数据（文物评论）');
      return [
        {
          id: '1',
          artifactId: artifactId,
          userId: 'user1',
          username: '文物爱好者',
          avatarUrl: 'https://example.com/avatar1.jpg',
          content: '这件文物保存非常完好，令人惊叹！',
          createTime: '2023-10-15 14:30:25',
          createTimestamp: 1697370625000
        },
        {
          id: '2',
          artifactId: artifactId,
          userId: 'user2',
          username: '历史研究者',
          avatarUrl: 'https://example.com/avatar2.jpg',
          content: '从工艺上看，这件文物代表了当时最高的制作水平。',
          createTime: '2023-10-14 09:15:40',
          createTimestamp: 1697265340000
        }
      ];
    } catch (err) {
      console.error('获取文物评论失败:', err);
      // 返回模拟数据作为兜底方案
      return [
        {
          id: '1',
          artifactId: artifactId,
          userId: 'user1',
          username: '文物爱好者',
          avatarUrl: 'https://example.com/avatar1.jpg',
          content: '这件文物保存非常完好，令人惊叹！',
          createTime: '2023-10-15 14:30:25',
          createTimestamp: 1697370625000
        }
      ];
    }
  }
  
  /**
   * 将云对象数据转换为应用模型
   */
  private convertToArtifact(item: ArtifactData): Artifact {
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
  }
  
  /**
   * 将云对象数据数组转换为应用模型数组
   */
  private convertToArtifacts(items: ArtifactData[]): Artifact[] {
    return items.map(item => this.convertToArtifact(item));
  }
} 