/**
 * 用户数据模型
 */
export class User {
  /**
   * 用户ID
   */
  id: string;
  
  /**
   * 用户ID（后端返回）
   */
  user_id: string;
  
  /**
   * 用户名
   */
  username: string;
  
  /**
   * 头像URL
   */
  avatarUrl: string;
  
  /**
   * 电子邮箱
   */
  email: string;
  
  /**
   * 是否已认证
   */
  isVerified: boolean;
  
  /**
   * 收藏的文物ID列表
   */
  favorites: string[];
  
  constructor(id: string, username: string, avatarUrl: string = '', 
              email: string = '', isVerified: boolean = false, favorites: string[] = []) {
    this.id = id;
    this.user_id = id;
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.email = email;
    this.isVerified = isVerified;
    this.favorites = favorites;
  }
}

/**
 * 文物信息接口
 */
export interface RelicInfo {
  relic_id: number;
  name: string;
  type: number;
  era: string;
  museum: string;
  description: string;
  spare_id: number;
}

/**
 * 用户文物评论模型
 */
export class UserRelicComment {
  /**
   * 评论ID
   */
  relic_comment_id: string | number;
  
  /**
   * 文物ID
   */
  relic_id: string | number;
  
  /**
   * 用户ID
   */
  user_id: string | number;
  
  /**
   * 评论内容
   */
  comment: string;
  
  /**
   * 评论时间
   */
  comment_time: string | number;
  
  /**
   * 关联的文物信息
   */
  relic?: RelicInfo;
  
  constructor(relic_comment_id: string | number, relic_id: string | number, user_id: string | number,
              comment: string, comment_time: string | number, relic?: RelicInfo) {
    this.relic_comment_id = relic_comment_id;
    this.relic_id = relic_id;
    this.user_id = user_id;
    this.comment = comment;
    this.comment_time = comment_time;
    this.relic = relic;
  }
}

/**
 * 评论数据类型，用于ArtifactService
 */
export type CommentData = UserRelicComment;

/**
 * 用户评论接口
 */
export interface UserComment {
  id: string;
  artifactId: string;
  userId: string;
  username: string;
  content: string;
  timestamp: number;
  avatarUrl?: string;
}

/**
 * 评论接口
 */
export interface Comment {
  id: string;          // 评论ID
  postId: number;      // 所属动态ID
  userId: string;      // 评论用户ID
  username: string;    // 评论用户名
  content: string;     // 评论内容
  createTime: string;  // 评论时间
}

/**
 * 动态接口
 */
export interface Post {
  id: number;          // 动态ID
  userId: string;      // 发布用户ID
  username: string;    // 发布用户名
  avatarUrl: string;   // 用户头像
  content: string;     // 动态内容
  createTime: string;  // 发布时间
  likes: number;       // 点赞数
  isLiked: boolean;    // 是否已点赞
  images: string[];    // 图片列表
  comments: Comment[]; // 评论列表
} 