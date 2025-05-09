import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import media from '@ohos.multimedia.media';
import fileIO from '@ohos.fileio';
import image from '@ohos.multimedia.image';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import camera from '@ohos.multimedia.camera';
import display from '@ohos.display';
import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

@Entry
@Component
struct ImageSearch {
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  @State imageUri: string = '';
  @State errorMsg: string = '';
  
  private artifactService: ArtifactService = new ArtifactService();
  private context = getContext(this) as common.UIAbilityContext;
  
  async checkCameraPermission(): Promise<boolean> {
    try {
      // 检查相机权限
      let atManager = bundleManager.getApplicationInfoManager();
      const grantStatus = await atManager.checkPermission('ohos.permission.CAMERA');
      
      if (grantStatus === bundleManager.GrantStatus.PERMISSION_GRANTED) {
        return true;
      } else {
        // 请求权限
        const requestResult = await atManager.requestPermissionsFromUser(this.context, ['ohos.permission.CAMERA']);
        return requestResult.authResults[0] === 0;
      }
    } catch (err) {
      console.error(`权限检查失败: ${(err as ErrorWithMessage).message}`);
      return false;
    }
  }
  
  async takePhoto() {
    try {
      // 检查相机权限
      const hasPermission = await this.checkCameraPermission();
      if (!hasPermission) {
        this.errorMsg = '无法获取相机权限，请在设置中允许应用使用相机';
        prompt.showToast({ message: this.errorMsg });
        return;
      }
      
      // 获取相机列表
      const cameraManager = camera.getCameraManager(this.context);
      const cameraList = await cameraManager.getCameras();
      
      if (cameraList.length === 0) {
        this.errorMsg = '未检测到相机设备';
        prompt.showToast({ message: this.errorMsg });
        return;
      }
      
      // 使用后置相机
      const cameraInfo = cameraList.find(cam => cam.position === camera.CameraPosition.CAMERA_POSITION_BACK) || cameraList[0];
      const cameraDevice = await cameraManager.createCamera(cameraInfo.cameraId);
      
      // 获取当前显示信息，为创建预览Surface准备
      const defaultDisplay = display.getDefaultDisplaySync();
      const surfaceWidth = defaultDisplay.width;
      const surfaceHeight = defaultDisplay.height;
      
      // 准备输出文件路径
      const mediaLib = mediaLibrary.getMediaLibrary(this.context);
      const publicPath = await mediaLib.getPublicDirectory(mediaLibrary.DirectoryType.DIR_IMAGE);
      const currentTime = new Date().getTime();
      const fileName = `IMAGE_${currentTime}.jpg`;
      const filePath = `${publicPath}/${fileName}`;
      
      // 拍照并保存
      const captureSession = await cameraDevice.createCaptureSession();
      await captureSession.beginConfig();
      
      // 配置预览输出
      const previewOutput = await captureSession.createPreviewOutput(surfaceWidth, surfaceHeight);
      
      // 配置拍照输出
      const photoOutput = await captureSession.createPhotoOutput();
      
      // 完成配置
      await captureSession.commitConfig();
      
      // 开始预览
      await captureSession.start();
      
      // 拍照流程（实际场景应设置一个预览界面和拍照按钮）
      prompt.showToast({ message: '正在拍照...' });
      
      // 设置拍照参数
      const settings = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
        rotation: camera.ImageRotation.ROTATION_0
      };
      
      // 执行拍照
      const captureId = await photoOutput.capture(settings);
      
      // 获取图像数据并保存到文件
      photoOutput.on('captureCompleted', async (outputInfo) => {
        if (outputInfo.captureId === captureId) {
          // 保存图片
          try {
            const imageUri = await this.saveImageToFile(outputInfo.buffer, filePath);
            this.imageUri = imageUri;
            
            // 关闭相机会话
            await captureSession.stop();
            await captureSession.release();
            await cameraDevice.release();
            
            // 进行图像搜索
            this.searchByImage();
          } catch (error) {
            this.errorMsg = `保存图片失败: ${(error as ErrorWithMessage).message}`;
            prompt.showToast({ message: this.errorMsg });
          }
        }
      });
      // 模拟选择图片后的处理
      this.imageUri = 'mock_image_uri';
      this.searchByImage();
    } catch (err) {
      this.errorMsg = `选择图片失败: ${(err as ErrorWithMessage).message}`;
      prompt.showToast({ message: this.errorMsg });
    }
  }
  
  searchByImage() {
    if (!this.imageUri) {
      prompt.showToast({ message: '请先选择或拍摄图片' });
      return;
    }
    
    this.isLoading = true;
    
    // 在实际实现中，应读取图片数据并转为Base64
    // 以下为示例代码，实际项目中需要根据HarmonyOS文件IO实现
    try {
      // 模拟图片数据
      let imageData = 'base64_encoded_image_data';
      
      this.artifactService.searchByImage(imageData)
        .then((artifacts) => {
          this.searchResults = artifacts;
          this.isLoading = false;
        })
        .catch((err: ErrorWithMessage) => {
          this.errorMsg = `搜索失败: ${err.message}`;
          this.isLoading = false;
          prompt.showToast({ message: this.errorMsg });
        });
    } catch (err) {
      this.errorMsg = `读取图片失败: ${(err as ErrorWithMessage).message}`;
      this.isLoading = false;
      prompt.showToast({ message: this.errorMsg });
    }
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
              .onClick(() => {
                this.selectFromGallery();
              })
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
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(15)
            .border({ width: 1, color: '#8B0000' })  // 深红色边框
            .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          } else if (this.searchResults.length > 0) {
            Text('搜索结果')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B0000')  // 深红色
              .alignSelf(ItemAlign.Start)
              .margin({ left: '5%', bottom: 10 })
            
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