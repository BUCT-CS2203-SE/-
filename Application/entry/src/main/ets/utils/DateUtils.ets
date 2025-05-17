/**
 * 日期格式化工具类
 */

/**
 * 格式化日期
 * @param date 日期对象
 * @param format 格式模板，如：'YYYY-MM-DD HH:mm:ss'
 * @returns 格式化后的日期字符串
 */
export function formatDate(date: Date, format: string): string {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const hour = date.getHours();
  const minute = date.getMinutes();
  const second = date.getSeconds();

  format = format.replace(/YYYY/g, year.toString());
  format = format.replace(/MM/g, month < 10 ? '0' + month : month.toString());
  format = format.replace(/DD/g, day < 10 ? '0' + day : day.toString());
  format = format.replace(/HH/g, hour < 10 ? '0' + hour : hour.toString());
  format = format.replace(/mm/g, minute < 10 ? '0' + minute : minute.toString());
  format = format.replace(/ss/g, second < 10 ? '0' + second : second.toString());

  return format;
} 