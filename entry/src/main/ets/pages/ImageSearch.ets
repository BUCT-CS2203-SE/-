import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import media from '@ohos.multimedia.media';
import fileIO from '@ohos.fileio';
import image from '@ohos.multimedia.image';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { camera, cameraPicker } from '@kit.CameraKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

/**
 * 检测结果接口
 */
interface DetectionResult {
  label: string;
  score: number;
  left: number;
  top: number;
  right: number;
  bottom: number;
}

// 模拟的对象检测结果
const mockDetectionCategories = [
  '瓷器', '玉器', '青铜器', '书画', '陶器', '金银器', '钱币', '雕塑',
  '家具', '石刻', '织绣', '漆器', '竹木牙角器', '文房四宝'
];

@Entry
@Component
struct ImageSearch {
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  @State imageUri: string = '';
  @State errorMsg: string = '';
  @State detectionResults: DetectionResult[] = [];
  @State showDetectionResults: boolean = false;

  private artifactService: ArtifactService = new ArtifactService();

  async takePhoto() {
    try {
      // 调用相机API拍照
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };

      // 调用相机拍照
      let result: cameraPicker.PickerResult = await cameraPicker.pick(
        getContext(),
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      );

      if (result.resultCode === 0) {
        this.imageUri = result.resultUri;
        this.simulateObjectDetection();
      } else {
        this.errorMsg = '拍照失败，请重试';
        promptAction.showToast({ message: this.errorMsg });
      }
    } catch (err) {
      this.errorMsg = `拍照失败: ${(err as ErrorWithMessage).message}`;
      promptAction.showToast({ message: this.errorMsg });
    }
  }

  async selectFromGallery() {
    try {
      // 使用photoAccessHelper从相册选择图片
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
      photoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        this.imageUri = photoSelectResult.photoUris[0];
        this.simulateObjectDetection();
      } else {
        this.errorMsg = '未选择任何图片';
        promptAction.showToast({ message: this.errorMsg });
      }
    } catch (err) {
      this.errorMsg = `选择图片失败: ${(err as ErrorWithMessage).message}`;
      promptAction.showToast({ message: this.errorMsg });
    }
  }

  // 由于无法找到 @ohos/ai_engine 包，我们使用模拟数据来模拟对象检测功能
  async simulateObjectDetection() {
    if (!this.imageUri) {
      promptAction.showToast({ message: '请先选择或拍摄图片' });
      return;
    }

    this.isLoading = true;
    this.showDetectionResults = true;

    try {
      // 读取图片文件基本信息，但不进行实际检测
      const file = fileIo.openSync(this.imageUri, fileIo.OpenMode.READ_ONLY);
      const fileSize = fileIo.statSync(file.fd).size;
      fileIo.closeSync(file);

      // 延迟模拟处理时间
      await new Promise<void>(resolve => setTimeout(resolve, 1500));

      // 生成1-3个随机检测结果
      const numResults = Math.floor(Math.random() * 3) + 1;
      this.detectionResults = [];

      for (let i = 0; i < numResults; i++) {
        // 随机选择一个类别
        const categoryIndex = Math.floor(Math.random() * mockDetectionCategories.length);
        const category = mockDetectionCategories[categoryIndex];

        // 生成随机位置和大小
        const width = 200 + Math.floor(Math.random() * 100);
        const height = 100 + Math.floor(Math.random() * 100);
        const left = Math.floor(Math.random() * (300 - width));
        const top = Math.floor(Math.random() * (300 - height));

        // 生成随机置信度 0.7-0.99
        const confidence = 0.7 + Math.random() * 0.29;

        this.detectionResults.push({
          label: category,
          score: confidence,
          left: left,
          top: top,
          right: left + width,
          bottom: top + height
        });
      }

      if (this.detectionResults.length > 0) {
        // 根据检测到的对象搜索相关文物
        const keywords = this.detectionResults.map(result => result.label).join(' ');
        this.searchByKeywords(keywords);
      } else {
        this.searchResults = [];
        this.isLoading = false;
        promptAction.showToast({ message: '未检测到可识别的对象' });
      }
    } catch (err) {
      this.errorMsg = `图像处理失败: ${(err as ErrorWithMessage).message}`;
      this.isLoading = false;
      this.detectionResults = [];
      promptAction.showToast({ message: this.errorMsg });
    }
  }

  // 根据关键词搜索文物
  async searchByKeywords(keywords: string) {
    try {
      this.artifactService.searchByKeyword(keywords)
        .then((artifacts) => {
          this.searchResults = artifacts;
          this.isLoading = false;
        })
        .catch((err: ErrorWithMessage) => {
          this.errorMsg = `搜索失败: ${err.message}`;
          this.isLoading = false;
          promptAction.showToast({ message: this.errorMsg });
        });
    } catch (err) {
      this.errorMsg = `搜索失败: ${(err as ErrorWithMessage).message}`;
      this.isLoading = false;
      promptAction.showToast({ message: this.errorMsg });
    }
  }

  // 原始的图像搜索方法，保留备用
  async searchByImage() {
    if (!this.imageUri) {
      promptAction.showToast({ message: '请先选择或拍摄图片' });
      return;
    }

    this.isLoading = true;

    try {
      // 读取图片文件并转为Base64
      const file = fileIo.openSync(this.imageUri, fileIo.OpenMode.READ_ONLY);
      const fileSize = fileIo.statSync(file.fd).size;
      const buffer = new ArrayBuffer(fileSize);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      // 将图片数据转为Base64格式
      const base64Data = this.arrayBufferToBase64(buffer);

      this.artifactService.searchByImage(base64Data)
        .then((artifacts) => {
          this.searchResults = artifacts;
          this.isLoading = false;
        })
        .catch((err: ErrorWithMessage) => {
          this.errorMsg = `搜索失败: ${err.message}`;
          this.isLoading = false;
          promptAction.showToast({ message: this.errorMsg });
        });
    } catch (err) {
      this.errorMsg = `读取图片失败: ${(err as ErrorWithMessage).message}`;
      this.isLoading = false;
      promptAction.showToast({ message: this.errorMsg });
    }
  }

  // ArrayBuffer转Base64
  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    const binary = bytes.reduce((acc, byte) => acc + String.fromCharCode(byte), '');
    const base64 = (binary);
    return base64;
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

          Text('智能文物识别')
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
          Stack() {
            if (this.imageUri) {
              Image(this.imageUri)
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
                .borderRadius(15)
                .border({ width: 1, color: '#8B0000' })  // 深红色边框
                .shadow({ radius: 5, color: '#8B0000', offsetX: 0, offsetY: 2 })

              // 显示检测框
              if (this.showDetectionResults && this.detectionResults.length > 0) {
                ForEach(this.detectionResults, (result: DetectionResult) => {
                  Column() {
                    // 检测框
                    Rect()
                      .width(result.right - result.left)
                      .height(result.bottom - result.top)
                      .stroke('#FF0000')
                      .strokeWidth(2)
                      .fill('transparent')

                    // 标签
                    Text(`${result.label} ${(result.score * 100).toFixed(0)}%`)
                      .fontSize(12)
                      .backgroundColor('#FF0000')
                      .fontColor('#FFFFFF')
                      .padding(4)
                  }
                  .position({
                    x: result.left,
                    y: result.top
                  })
                })
              }
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
          .height(300)
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
              .onClick(() => {
                this.selectFromGallery();
              })
          }
          .width('90%')
          .margin({ bottom: 20 })

          // 检测结果和搜索结果
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color('#8B0000')  // 深红色
                .margin({ bottom: 20 })

              Text('正在识别中...')
                .fontSize(18)
                .fontColor('#8B0000')  // 深红色
                .margin({ bottom: 10 })

              Text('请稍候，我们正在识别图片中的物体')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .border({ width: 1, color: '#8B0000' })  // 深红色边框
            .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          } else if (this.detectionResults.length > 0) {
            Column() {
              // 检测结果列表
              Text('图像识别结果')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#8B0000')  // 深红色
                .margin({ bottom: 10 })

              List() {
                ForEach(this.detectionResults, (result: DetectionResult) => {
                  ListItem() {
                    Row() {
                      Text(result.label)
                        .fontSize(16)
                        .fontColor('#333333')
                        .layoutWeight(1)

                      Text(`${(result.score * 100).toFixed(0)}%`)
                        .fontSize(16)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(10)
                  }
                })
              }
              .width('90%')
              .height(120)
              .margin({ bottom: 15 })

              // 相关文物
              if (this.searchResults.length > 0) {
                Text('相关文物')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#8B0000')  // 深红色
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
                .width('90%')
                .layoutWeight(1)
              } else {
                Column() {
                  Image($r('app.media.no_result'))
                    .width(80)
                    .height(80)
                    .fillColor('#8B0000')  // 深红色
                    .margin({ bottom: 16 })

                  Text('未找到相关文物')
                    .fontSize(16)
                    .fontColor('#8B0000')  // 深红色
                    .margin({ bottom: 10 })

                  Text('我们正在丰富文物库，敬请期待')
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .width('90%')
                .height(200)
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
            .layoutWeight(1)
          } else if (this.imageUri) {
            Column() {
              Image($r('app.media.no_result'))
                .width(100)
                .height(100)
                .fillColor('#8B0000')  // 深红色
                .margin({ bottom: 16 })

              Text('未识别到物体')
                .fontSize(18)
                .fontColor('#8B0000')  // 深红色
                .margin({ bottom: 10 })

              Text('请尝试拍摄清晰的图片或从不同角度拍摄')
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
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