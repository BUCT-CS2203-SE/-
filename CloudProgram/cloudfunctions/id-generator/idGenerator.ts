/// <reference types="node" />

import * as crypto from 'crypto';

/**
 * ID生成器云函数，提供各种ID生成策略
 */
export class IdGenerator {
  /**
   * 生成随机UUID
   */
  randomUUID() {
    const uuid = crypto.randomUUID();
    console.info(`Generate random UUID: ${uuid}`);
    return { "uuid": uuid };
  }

  /**
   * 生成基于时间戳的ID
   */
  timestampID() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    const id = `${timestamp}${random}`;
    console.info(`Generate timestamp ID: ${id}`);
    return { "id": id };
  }

  /**
   * 生成指定前缀的ID
   */
  prefixedID(params: { prefix: string }) {
    const { prefix } = params;
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    const id = `${prefix}_${timestamp}_${random}`;
    console.info(`Generate prefixed ID: ${id}`);
    return { "id": id };
  }

  /**
   * 生成短ID（适用于URL缩短等场景）
   */
  shortID() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let id = '';
    for (let i = 0; i < 8; i++) {
      id += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    console.info(`Generate short ID: ${id}`);
    return { "id": id };
  }

  /**
   * 生成特定业务的ID
   */
  businessID(params: { type: string }) {
    const { type } = params;
    const typeMap: { [key: string]: string } = {
      'artifact': 'ART',
      'museum': 'MUS',
      'user': 'USR',
      'event': 'EVT',
      'comment': 'CMT'
    };

    const prefix = typeMap[type] || 'GEN';
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    const id = `${prefix}_${timestamp}_${random}`;
    console.info(`Generate business ID for ${type}: ${id}`);
    return { "id": id };
  }
}
