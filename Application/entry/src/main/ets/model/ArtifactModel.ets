/**
 * 文物数据模型
 */
export class Artifact {
  /**
   * 文物ID
   */
  id: string;
  
  /**
   * 文物名称
   */
  name: string;
  
  /**
   * 文物时代
   */
  era: string;
  
  /**
   * 文物博物馆
   */
  museum: string;
  
  /**
   * 文物简介
   */
  description: string;
  
  /**
   * 文物图片URL
   */
  imageUrl: string;
  
  /**
   * 文物类型
   * (0-青铜器 1-陶瓷器 2-玉器 3-书画 4-货币 5-石器 6-雕塑 7-其他)
   */
  type: number;
  
  /**
   * 文物详情URL
   */
  detailUrl: string;
  
  /**
   * 点赞数
   */
  likes: number;
  
  /**
   * 评论数
   */
  comments: number;
  
  constructor(id: string, name: string, era: string, museum: string, 
              description: string, imageUrl: string, type: number, 
              detailUrl: string, likes: number = 0, comments: number = 0) {
    this.id = id;
    this.name = name;
    this.era = era;
    this.museum = museum;
    this.description = description;
    this.imageUrl = imageUrl;
    this.type = type;
    this.detailUrl = detailUrl;
    this.likes = likes;
    this.comments = comments;
  }
} 