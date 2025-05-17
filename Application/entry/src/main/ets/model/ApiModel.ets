/**
 * API响应数据接口
 */
export interface ApiResponse<T> {
  code?: number;
  message?: string;
  data?: T;
} 