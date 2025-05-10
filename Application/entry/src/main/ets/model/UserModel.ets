/**
 * 用户数据模型
 */
export class User {
  /**
   * 用户ID
   */
  id: string;
  
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
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.email = email;
    this.isVerified = isVerified;
    this.favorites = favorites;
  }
}

/**
 * 用户评论模型
 */
export class UserComment {
  /**
   * 评论ID
   */
  id: string;
  
  /**
   * 用户ID
   */
  userId: string;
  
  /**
   * 用户名
   */
  username: string;
  
  /**
   * 用户头像
   */
  avatarUrl: string;
  
  /**
   * 评论内容
   */
  content: string;
  
  /**
   * 评论时间
   */
  createTime: string;
  
  /**
   * 文物ID
   */
  artifactId: string;
  
  constructor(id: string, userId: string, username: string, avatarUrl: string,
              content: string, createTime: string, artifactId: string) {
    this.id = id;
    this.userId = userId;
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.content = content;
    this.createTime = createTime;
    this.artifactId = artifactId;
  }
}

/**
 * 评论数据类型，用于ArtifactService
 */
export type CommentData = UserComment;

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