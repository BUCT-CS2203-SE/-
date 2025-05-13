/**
 * 应用常量定义
 */

/**
 * 标签类型定义
 */
export interface TabItem {
  id: number;
  name: string;
  icon: string;
}

/**
 * 文物分类类型定义
 */
export interface CategoryItem {
  id: number;
  name: string;
}

export class Constants {
  /**
   * 应用名称
   */
  static readonly APP_NAME: string = '掌上博物馆';
  
  /**
   * API基础URL
   */
  static readonly BASE_URL: string = 'http://your-api-server.com/api';
  
  /**
   * 首页Tab配置
   */
  static readonly HOME_TABS: TabItem[] = [
    { id: 0, name: '首页', icon: 'home' },
    { id: 1, name: '文物', icon: 'museum' },
    { id: 2, name: '搜索', icon: 'search' },
    { id: 3, name: '我的', icon: 'person' }
  ];

  /**
   * 文物分类
   */
  static readonly ARTIFACT_CATEGORIES: CategoryItem[] = [
    { id: 1, name: '陶瓷器' },
    { id: 2, name: '玉器' },
    { id: 3, name: '青铜器' },
    { id: 4, name: '书画' },
    { id: 5, name: '雕塑' }
  ];
  /**
   * Deepseek API 设置
   */
  static readonly DEEPSEEK_MODEL: string = 'deepseek-chat';
  static readonly DEEPSEEK_API_URL: string = 'https://api.deepseek.com/chat/completions';
  static readonly DEEPSEEK_API_KEY: string = 'sk-9acc0ab06bca4b4c9eea01753f635739';
} 