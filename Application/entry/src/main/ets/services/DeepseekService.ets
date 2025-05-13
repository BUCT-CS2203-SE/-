/**
 * DeepseekService.ets
 * 用于处理与Deepseek API的通信，实现图像识别功能
 */

import http from '@ohos.net.http';
import { Constants } from '../common/constants/Constants';

/**
 * Deepseek API 错误类
 */
class DeepseekApiError extends Error {
  statusCode: number;

  constructor(message: string, statusCode: number = 0) {
    super(message);
    this.statusCode = statusCode;
  }
}

/**
 * Deepseek API 请求消息接口
 */
interface DeepseekRequest {
  model: string;
  messages: DeepseekMessage[];
  stream: boolean;
  max_tokens: number;
}

/**
 * Deepseek API 消息接口
 */
interface DeepseekMessage {
  role: string;
  content: string;
}

/**
 * Deepseek API 响应接口
 */
interface DeepseekResponse {
  choices: Array<Choice>;
}

/**
 * Deepseek API 响应选择项
 */
interface Choice {
  message: Message;
}

/**
 * Deepseek API 响应消息
 */
interface Message {
  content: string;
}

/**
 * Deepseek API服务类
 */
export class DeepseekService {
  /**
   * 识别图片内容，提取关键词
   * @param imageBase64 Base64编码的图片数据
   * @returns 返回识别出的关键词数组
   */
  async recognizeImage(imageBase64: string): Promise<string[]> {
    // 创建HTTP请求客户端
    let httpRequest = http.createHttp();

    try {
      console.info('开始调用Deepseek API识别图片');

      // 构建请求消息体
      const requestBody: DeepseekRequest = {
        model: Constants.DEEPSEEK_MODEL,
        messages: [
          {
            role: 'system',
            content: '你是一个专业的图像识别助手，擅长从图片中识别出中国文物和古董（如青铜器，瓷器，钱币，玉器各种书画等）。请提取出5个关键词，这些关键词应该包含图像中的文物名称、年代、类型、特征等信息。返回格式为逗号分隔的关键词列表，不要有额外的解释。'
          },
          {
            role: 'user',
            content: `以下是一张base64格式编码图片，请转换为jpg类型的图片后，分析图中的文物内容并提取关键词：[data:image/jpeg;base64,${imageBase64}]`
          }
        ],
        stream: false,
        max_tokens: 1000
      };

      // 发送POST请求
      let response = await httpRequest.request(
        Constants.DEEPSEEK_API_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${Constants.DEEPSEEK_API_KEY}`
          },
          extraData: JSON.stringify(requestBody),
          connectTimeout: 60000,  // 设置60秒的连接超时时间
          readTimeout: 60000      // 设置60秒的读取超时时间
        }
      );

      // 检查响应状态
      if (response.responseCode !== 200) {
        throw new DeepseekApiError(`API请求失败: ${response.responseCode}，响应内容: ${response.result.toString()}`, response.responseCode);
      }

      // 解析响应数据
      const responseData: DeepseekResponse = JSON.parse(response.result.toString());
      const content: string = responseData.choices[0].message.content;

      // 将响应内容拆分为关键词数组
      const keywords: string[] = content.split(',').map((keyword: string): string => keyword.trim());

      console.info(`图片识别完成，识别出关键词: ${keywords.join(', ')}`);
      return keywords;
    } catch (err) {
      console.error('调用Deepseek API识别图片失败:', err instanceof Error ? err.message : String(err));
      throw new DeepseekApiError('图片识别失败', err instanceof DeepseekApiError ? err.statusCode : 0);
    } finally {
      // 释放HTTP客户端资源
      httpRequest.destroy();
    }
  }
}