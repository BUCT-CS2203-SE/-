import { RelicInfo } from './UserModel';

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
 * 浏览记录项类
 */
export class BrowseItem {
  public browse_id: number;
  public user_id: number;
  public relic_id: number;
  public browse_time: string;
  public relic: RelicInfo;

  constructor(browse_id: number, user_id: number, relic_id: number, browse_time: string, relic: RelicInfo) {
    this.browse_id = browse_id;
    this.user_id = user_id;
    this.relic_id = relic_id;
    this.browse_time = browse_time;
    this.relic = relic;
  }

  /**
   * 从JSON对象创建BrowseItem实例
   */
  static fromJson(json: BrowseItemJson): BrowseItem {
    return new BrowseItem(
      json.browse_id,
      json.user_id,
      json.relic_id,
      json.browse_time,
      json.relic
    );
  }
}

/**
 * 浏览记录请求数据JSON接口
 */
export interface BrowseRequestDataJson {
  user_id: number;
  relic_id: number;
}

/**
 * 浏览记录请求数据类
 */
export class BrowseRequestData {
  public user_id: number;
  public relic_id: number;

  constructor(user_id: number, relic_id: number) {
    this.user_id = user_id;
    this.relic_id = relic_id;
  }

  /**
   * 转换为JSON对象
   */
  toJson(): BrowseRequestDataJson {
    return {
      user_id: this.user_id,
      relic_id: this.relic_id
    };
  }
}

/**
 * 浏览记录响应接口
 */
export interface BrowseResponse {
  message: string;
  data: BrowseItemJson[];
} 