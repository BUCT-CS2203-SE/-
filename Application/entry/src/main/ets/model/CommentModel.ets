/**
 * 评论数据模型
 */
export interface CommentData {
  comment_id: string;
  post_id: string;
  user_id: number;
  nickname: string;
  img_url?: string;
  content: string;
  create_time: string;
  create_timestamp: number;
} 