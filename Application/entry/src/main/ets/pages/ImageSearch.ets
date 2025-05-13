import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import camera from '@ohos.multimedia.camera';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { DeepseekService } from '../services/DeepseekService';
import fileIo from '@ohos.fileio';
import picker from '@ohos.file.picker';
import fileAccess from '@ohos.file.fs';
import uri from '@ohos.uri';
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

/**
 * 相机选项接口
 */
interface CameraOptions {
  position: camera.CameraPosition;
}

/**
 * 相机结果接口
 */
interface CameraResult {
  uri: string;
}

/**
 * 图片选择选项接口
 */
interface PhotoPickerOptions {
  MIMEType: string;
  maxSelectNumber: number;
}

/**
 * 图片选择结果接口
 */
interface PhotoPickerResult {
  photoUris: string[];
}

// 文件句柄接口
interface FileHandle {
  fd: number;
}

@Entry
@Component
struct ImageSearch {
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  @State imageUri: string = '';
  @State imagePath: string = '';
  @State errorMsg: string = '';
  @State searchKeywords: string[] = [];
  @State imageBase64: string = '';

  private artifactService: ArtifactService = new ArtifactService();
  private deepseekService: DeepseekService = new DeepseekService();

  // 获取应用上下文
  private context = getContext(this) as common.UIAbilityContext;

  async takePhoto() {
    try {
      // 调用相机API拍照
      const cameraOptions: CameraOptions = {
        position: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 使用系统相机拍照
      const photoPicker = new picker.PhotoViewPicker();

      // 使用系统选择器拍照
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result && result.photoUris && result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
        this.processImage();
      } else {
        this.errorMsg = '拍照失败，请重试';
        promptAction.showToast({ message: this.errorMsg });
      }
    } catch (err) {
      const error = err as Error;
      this.errorMsg = `拍照失败: ${error.message}`;
      promptAction.showToast({ message: this.errorMsg });
      console.error(this.errorMsg);
    }
  }

  async selectFromGallery() {
    try {
      // 创建媒体库选择器
      const photoPicker = new picker.PhotoViewPicker();

      // 设置选择器参数（单选图片）
      const photoSelectParam: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };

      // 显示选择器
      const result = await photoPicker.select(photoSelectParam);

      if (result && result.photoUris && result.photoUris.length > 0) {
        this.imageUri = result.photoUris[0];
        this.processImage();
      } else {
        this.errorMsg = '未选择任何图片';
        promptAction.showToast({ message: this.errorMsg });
      }
    } catch (err) {
      const error = err as Error;
      this.errorMsg = `选择图片失败: ${error.message}`;
      promptAction.showToast({ message: this.errorMsg });
      console.error(this.errorMsg);
    }
  }

  // 处理图片并搜索
  processImage() {
    this.isLoading = true;
    this.searchResults = [];
    this.searchKeywords = [];

    try {
      console.info('选中的图片路径:', this.imageUri);

      // 使用文件管理API处理图片
      (async () => {
        try {
          let imageBase64: string = '';
          
          // 读取图片文件并转换为Base64
          try {
            // 打开文件并读取内容
            const resultPhoto = fileAccess.openSync(this.imageUri, fileAccess.OpenMode.READ_ONLY);
            const fileTemp = fileAccess.openSync(getContext(this).filesDir + '/temp_image.jpg', fileAccess.OpenMode.READ_WRITE | fileAccess.OpenMode.CREATE);
            const tempPath: string = fileTemp.path;
            
            // 复制文件内容
            fileAccess.copyFileSync(resultPhoto.fd, fileTemp.fd);
            
            // 关闭文件
            fileAccess.closeSync(resultPhoto);
            fileAccess.closeSync(fileTemp);
            
            // 读取文件内容为ArrayBuffer
            const fileStat = fileAccess.statSync(tempPath);
            const fileSize = fileStat.size;
            const fileData = new ArrayBuffer(fileSize);
            const file = fileAccess.openSync(tempPath, fileAccess.OpenMode.READ_ONLY);
            fileAccess.readSync(file.fd, fileData);
            fileAccess.closeSync(file);
            
            // 转换为Base64
            imageBase64 = this.arrayBufferToBase64(fileData);
            console.info('成功读取图片并转换为Base64');
          } catch (fileError) {
            console.error('文件操作失败:', fileError);
            throw new Error('文件读取失败');
          }

          // 使用base64数据
          Promise.all([
            this.deepseekService.recognizeImage(imageBase64)
              .then((keywords: string[]) => {
                this.searchKeywords = keywords;
              })
              .catch((err: Error) => {
                console.error('获取关键词失败:', err instanceof Error ? err.message : String(err));
                this.searchKeywords = ['青花瓷器'];
              }),

            this.artifactService.searchByImage(imageBase64)
              .then((artifacts: Artifact[]) => {
                this.searchResults = artifacts;
                if (artifacts.length === 0) {
                  promptAction.showToast({ message: '未找到相关文物' });
                }
              })
              .catch((err: Error) => {
                this.errorMsg = `搜索失败: ${err.message}`;
                promptAction.showToast({ message: this.errorMsg });
              })
          ]).finally(() => {
            this.isLoading = false;
          });
        } catch (error) {
          const processError = error as Error;
          this.errorMsg = `读取图片失败: ${processError.message}`;
          this.isLoading = false;
          promptAction.showToast({ message: this.errorMsg });
          console.error('图片处理错误:', processError);
        }
      })();
    } catch (err) {
      const mainError = err as Error;
      this.errorMsg = `处理图片失败: ${mainError.message}`;
      this.isLoading = false;
      promptAction.showToast({ message: this.errorMsg });
      console.error('图片处理主错误:', mainError);
    }
  }

  // 修改ArrayBuffer转Base64方法，使用更标准的方式
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    let binary = '';
    
    // 使用for循环构建字符串
    for (let i = 0; i < uint8Array.length; i++) {
      binary += String.fromCharCode(uint8Array[i]);
    }
    
    return binary;
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.background2'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.1)

      Column() {
        // 顶部栏
        Row() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .fillColor('#8B0000')  // 深红色
            .onClick(() => {
              router.back();
            })

          Text('图片搜索文物')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8B0000')  // 深红色
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Blank().width(24)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius({ bottomLeft: 15, bottomRight: 15 })
        .shadow({ radius: 5, color: '#8B0000', offsetX: 0, offsetY: 2 })

        // 内容区域
        Column() {
          // 图片预览区域
          Column() {
            if (this.imageUri) {
              Image(this.imageUri)
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
                .borderRadius(15)
                .border({ width: 1, color: '#8B0000' })  // 深红色边框
                .shadow({ radius: 5, color: '#8B0000', offsetX: 0, offsetY: 2 })
            } else {
              Column() {
                Image($r('app.media.photo'))
                  .width(100)
                  .height(100)
                  .fillColor('#8B0000')  // 深红色
                  .margin({ bottom: 16 })

                Text('请选择或拍摄一张图片')
                  .fontSize(16)
                  .fontColor('#8B0000')  // 深红色
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(15)
              .border({ width: 1, color: '#8B0000' })  // 深红色边框
              .shadow({ radius: 5, color: '#8B0000', offsetX: 0, offsetY: 2 })
            }
          }
          .width('90%')
          .margin({ top: 20, bottom: 20 })

          // 按钮区域
          Row() {
            Button('拍照', { type: ButtonType.Normal })
              .width(150)
              .height(50)
              .backgroundColor('#8B0000')  // 深红色
              .fontColor('#FFFFFF')
              .borderRadius(25)
              .margin({ right: 10 })
              .onClick(() => {
                this.takePhoto();
              })

            Button('从相册选择', { type: ButtonType.Normal })
              .width(150)
              .height(50)
              .backgroundColor('#8B0000')  // 深红色
              .fontColor('#FFFFFF')
              .borderRadius(25)
              .margin({ right: 10 })
              .onClick(() => {
                this.selectFromGallery();
              })

            // 新增本地图片测试按钮

          }
          .width('90%')
          .margin({ bottom: 20 })

          // 搜索结果
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color('#8B0000')  // 深红色
                .margin({ bottom: 20 })

              Text('正在搜索中...')
                .fontSize(18)
                .fontColor('#8B0000')  // 深红色
                .margin({ bottom: 10 })

              Text('请稍候，我们正在为您查找相关文物')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('90%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .border({ width: 1, color: '#8B0000' })  // 深红色边框
            .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          } else if (this.searchResults.length > 0) {
            Column() {
              // 关键词显示
              if (this.searchKeywords.length > 0) {
                Row() {
                  Text('识别关键词: ')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#8B0000')  // 深红色

                  Text(this.searchKeywords.join(', '))
                    .fontSize(16)
                    .fontColor('#666666')
                }
                .width('100%')
                .padding(10)
                .margin({ bottom: 10 })
                .backgroundColor('#FFFFFF')
                .borderRadius(10)
                .border({ width: 1, color: '#8B0000' })
              }

              Text('搜索结果')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8B0000')  // 深红色
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 10 })

              List({ space: 10 }) {
                ForEach(this.searchResults, (artifact: Artifact) => {
                  ListItem() {
                    Row() {
                      Image(artifact.imageUrl || $r('app.media.placeholder'))
                        .width(100)
                        .height(100)
                        .borderRadius(10)
                        .objectFit(ImageFit.Cover)
                        .border({ width: 1, color: '#8B0000' })  // 深红色边框

                      Column() {
                        Text(artifact.name)
                          .fontSize(18)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#8B0000')  // 深红色

                        Text(artifact.era)
                          .fontSize(14)
                          .fontColor('#666666')
                          .margin({ top: 5 })

                        Text(artifact.museum)
                          .fontSize(14)
                          .fontColor('#666666')
                          .margin({ top: 5 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ left: 15 })
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding(15)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(15)
                    .border({ width: 1, color: '#8B0000' })  // 深红色边框
                    .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/ArtifactDetail',
                        params: { artifactId: artifact.id }
                      });
                    })
                  }
                })
              }
              .width('100%')
              .layoutWeight(1)
            }
            .width('90%')
          } else if (this.imageUri) {
            Column() {
              Image($r('app.media.no_result'))
                .width(100)
                .height(100)
                .fillColor('#8B0000')  // 深红色
                .margin({ bottom: 16 })

              Text('抱歉，未找到相关文物')
                .fontSize(18)
                .fontColor('#8B0000')  // 深红色
                .margin({ bottom: 10 })

              Text('请尝试使用其他图片进行搜索')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('90%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .border({ width: 1, color: '#8B0000' })  // 深红色边框
            .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF5F5')  // 浅红色背景
  }
} 