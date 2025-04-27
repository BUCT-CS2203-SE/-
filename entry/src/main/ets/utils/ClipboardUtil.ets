import pasteboard from '@ohos.pasteboard';

export class ClipboardUtil {
  static async copyText(text: string): Promise<void> {
    const systemPasteboard = pasteboard.getSystemPasteboard();
    const pasteData = pasteboard.createPasteData();
    pasteData.addTextRecord(text);
    await systemPasteboard.setPasteData(pasteData);
  }

  static async getText(): Promise<string> {
    const systemPasteboard = pasteboard.getSystemPasteboard();
    const pasteData = await systemPasteboard.getPasteData();
    return pasteData.getPrimaryText() || '';
  }
} 