/**
 * 帖子评论数据模型
 */
export interface Comment {
  comment_id: string;
  post_id: string;
  user_id: number;
  nickname: string;
  img_url?: string;
  content: string;
  create_time: string;
  create_timestamp: number;
}

/**
 * 帖子数据模型
 */
export interface Post {
  post_id: string;
  content: string;
  post_img_url?: string;
  likes: number;
  is_favorited: number;
  user_id: number;
  nickname: string;
  img_url?: string;
  create_time: string;
  create_timestamp: number;
  comments?: Comment[];
}

/**
 * 帖子列表响应模型
 */
export interface PostResponse {
  total: number;
  currentPage: number;
  pageSize: number;
  data: Post[];
}

/**
 * 点赞响应
 */
export interface LikeResponse {
  likes: number;
}

/**
 * 收藏响应
 */
export interface FavoriteResponse {
  is_favorited: boolean;
} 