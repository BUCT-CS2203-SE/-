import promptAction from '@ohos.promptAction';

export class ToastUtil {
  private static showToast(message: string, duration: number = 2000): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }

  static showSuccess(message: string): void {
    ToastUtil.showToast(message);
  }

  static showError(message: string): void {
    ToastUtil.showToast(message);
  }

  static showWarning(message: string): void {
    ToastUtil.showToast(message);
  }

  static show(message: string, duration: number = 2000): void {
    ToastUtil.showToast(message, duration);
  }
} 