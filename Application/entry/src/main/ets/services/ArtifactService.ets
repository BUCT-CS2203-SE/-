import { Artifact } from '../model/ArtifactModel';
import { Constants } from '../common/constants/Constants';
import { ApiService } from './ApiService';
import { UserRelicComment } from '../model/UserModel';

/**
 * 文物服务错误类
 */
class ArtifactServiceError extends Error {
  constructor(message: string) {
    super(message);
  }
}

/**
 * 轮播图数据接口
 */
export interface Banner {
  id: number;
  title: string;
  imageUrl: string;
  linkType: number;
  linkId: string;
}

/**
 * 分类数据接口
 */
export interface Category {
  id: number;
  name: string;
}

/**
 * 文物服务类，用于处理文物相关的业务逻辑
 */
export class ArtifactService {
  private apiService: ApiService = new ApiService();
  
  // 模拟数据，作为API调用失败时的兜底
  private mockArtifacts: Artifact[] = [
    new Artifact(
      '1',
      '青铜鼎',
      '春秋战国',
      '中国国家博物馆',
      '青铜鼎是中国古代青铜礼器，是中国古代政治权力和社会地位的象征。这件青铜鼎形制宏大，纹饰精美，是春秋战国时期的代表性器物。',
      'https://example.com/artifact1.jpg',
      0, // 青铜器
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
      1, // 陶瓷器
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
      3, // 书画
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
      3, // 书画
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
      0, // 青铜器
      'https://example.com/detail5',
      410,
      93
    )
  ];
  
  // 模拟轮播图数据
  private mockBanners: Banner[] = [
    {
      id: 1,
      title: '清明上河图',
      imageUrl: 'https://www.chinavid.com/wp-content/uploads/2020/02/29/qing-ming-shang-he-tu-gao-qing-tu-185gb-7-686x640.jpg',
      linkType: 0,
      linkId: '1'
    },
    {
      id: 2,
      title: '商后母戊鼎',
      imageUrl: 'https://img2.baidu.com/it/u=3256878326,2145691044&fm=253&fmt=auto&app=138&f=JPEG?w=475&h=591',
      linkType: 0,
      linkId: '2'
    },
    {
      id: 3,
      title: '玉龙',
      imageUrl: 'https://img2.baidu.com/it/u=917862778,2071639640&fm=253&fmt=auto?w=800&h=975',
      linkType: 0,
      linkId: '3'
    }
  ];
  
  // 模拟分类数据
  private mockCategories: Category[] = [
    { id: 0, name: '青铜器' },
    { id: 1, name: '陶瓷器' },
    { id: 2, name: '玉器' },
    { id: 3, name: '书画' },
    { id: 6, name: '雕塑' }
  ];
  
  constructor() {
    console.info('ArtifactService 构造函数开始执行');
    console.info('初始化 API 服务');
  }

  /**
   * 获取文物列表
   * @param type 文物类型，可选
   * @param page 页码
   * @param pageSize 每页数量
   */
  async getArtifactList(type?: number, page: number = 1, pageSize: number = 10): Promise<Artifact[]> {
    try {
      console.info(`开始获取文物列表，类型: ${type}, 页码: ${page}, 每页数量: ${pageSize}`);
      
      // 调用API服务获取文物列表
      const artifacts = await this.apiService.getArtifactList(type, page, pageSize);
      console.info(`成功获取文物列表，数量: ${artifacts.length}`);
      return artifacts;
    } catch (err) {
      console.error('获取文物列表失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（文物列表）');
      let filteredArtifacts = this.mockArtifacts;
      if (type !== undefined) {
        filteredArtifacts = filteredArtifacts.filter(item => item.type === type);
      }
      const startIdx = (page - 1) * pageSize;
      return filteredArtifacts.slice(startIdx, startIdx + pageSize);
    }
  }
  
  /**
   * 获取文物详情
   * @param id 文物ID
   */
  async getArtifactDetail(id: string): Promise<Artifact> {
    try {
      console.info(`开始获取文物详情，ID: ${id}`);
      
      // 调用API服务获取文物详情
      const artifact = await this.apiService.getArtifactDetail(id);
      console.info(`成功获取文物详情: ${artifact.name}`);
      return artifact;
    } catch (err) {
      console.error('获取文物详情失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（文物详情）');
      const mockArtifact = this.mockArtifacts.find(item => item.id === id);
      if (mockArtifact) {
        return mockArtifact;
      }
      return this.mockArtifacts[0];
    }
  }
  
  /**
   * 搜索文物
   * @param keyword 搜索关键词
   */
  async searchByKeyword(keyword: string): Promise<Artifact[]> {
    try {
      console.info(`开始搜索文物，关键词: ${keyword}`);
      
      // 调用API服务搜索文物
      const artifacts = await this.apiService.searchArtifacts(keyword);
      console.info(`成功搜索文物，数量: ${artifacts.length}`);
      return artifacts;
    } catch (err) {
      console.error('搜索文物失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（文物搜索）');
      return this.mockArtifacts.filter(item => 
        item.name.includes(keyword) || 
        item.description.includes(keyword) || 
        item.museum.includes(keyword) || 
        item.era.includes(keyword)
      );
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
  async getArtifactComments(artifactId: string): Promise<UserRelicComment[]> {
    try {
      console.info(`开始获取文物评论，ID: ${artifactId}`);
      
      // 调用API服务获取文物评论
      const comments = await this.apiService.getArtifactComments(artifactId);
      console.info(`成功获取文物评论，数量: ${comments.length}`);
      return comments;
    } catch (err) {
      console.error('获取文物评论失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      const currentDate = new Date();
      const mockComment = new UserRelicComment(
        '1',
        artifactId,
        'user1',
        '这件文物保存非常完好，令人惊叹！',
        currentDate.toISOString()
      );
      
      return [mockComment];
    }
  }

  /**
   * 获取轮播图数据
   */
  async getBanners(): Promise<Banner[]> {
    try {
      console.info('开始获取轮播图数据');
      
      // 调用API服务获取轮播图数据
      const bannerDataList = await this.apiService.getBanners();
      
      // 转换API返回的数据为Banner对象
      const banners = bannerDataList.map(item => {
        const banner: Banner = {
          id: item.banner_id,
          title: item.title,
          imageUrl: item.image_url,
          linkType: item.link_type,
          linkId: item.link_id
        };
        return banner;
      });
      
      console.info(`成功获取轮播图数据，数量: ${banners.length}`);
      return banners;
    } catch (err) {
      console.error('获取轮播图数据失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（轮播图）');
      return this.mockBanners;
    }
  }
  
  /**
   * 获取文物分类数据
   */
  async getCategories(): Promise<Category[]> {
    try {
      console.info('开始获取文物分类数据');
      
      // 调用API服务获取分类数据
      const categoryDataList = await this.apiService.getCategories();
      
      // 转换API返回的数据为Category对象
      const categories = categoryDataList.map(item => {
        const category: Category = {
          id: item.category_id,
          name: item.category_name
        };
        return category;
      });
      
      console.info(`成功获取文物分类数据，数量: ${categories.length}`);
      return categories;
    } catch (err) {
      console.error('获取文物分类数据失败:', err instanceof Error ? err.message : String(err));
      
      // 返回模拟数据作为兜底方案
      console.info('使用模拟数据（文物分类）');
      return this.mockCategories;
    }
  }
} 