import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import media from '@ohos.multimedia.media';
import fileIO from '@ohos.fileio';
import image from '@ohos.multimedia.image';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';
import camera from '@ohos.multimedia.camera';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

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
  
  aboutToAppear() {
    // 应用启动时请求必要的权限
    this.requestPermissions();
  }
  
  async requestPermissions() {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      
      // 定义要申请的权限列表
      const permissions = [
        'ohos.permission.CAMERA',
        'ohos.permission.READ_MEDIA',
        'ohos.permission.WRITE_MEDIA',
        'ohos.permission.MEDIA_LOCATION',
        'ohos.permission.READ_MEDIA_IMAGES'
      ];
      
      // 逐个检查并申请权限
      for (const permission of permissions) {
        const result = await atManager.requestPermissionsFromUser(this.context, [permission]);
        
        // 检查权限授予结果
        if (result.authResults[0] !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          console.info(`权限 ${permission} 未授予`);
        }
      }
    } catch (err) {
      console.error(`请求权限失败: ${(err as ErrorWithMessage).message}`);
    }
  }
  
  async checkCameraPermission(): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.checkAccessToken(
        this.context.applicationInfo.accessTokenId,
        'ohos.permission.CAMERA'
      );
      
      return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      console.error(`检查相机权限失败: ${(err as ErrorWithMessage).message}`);
      return false;
    }
  }
  
  async takePhoto() {
    try {
      // 检查相机权限
      const hasCameraPermission = await this.checkCameraPermission();
      
      if (!hasCameraPermission) {
        this.errorMsg = '无法访问相机，请在系统设置中授予相机权限';
        prompt.showToast({ message: this.errorMsg });
        return;
      }
      
      // 获取相机设备
      const cameraManager = camera.getCameraManager(this.context);
      
      if (!cameraManager) {
        this.errorMsg = '无法获取相机管理器';
        prompt.showToast({ message: this.errorMsg });
        return;
      }
      
      // 获取相机列表
      const cameraArray = await cameraManager.getCameras();
      
      if (cameraArray && cameraArray.length > 0) {
        try {
          // 优先使用后置相机（如果存在）
          let cameraId = cameraArray[0].cameraId;
          
          // 检查是否有后置相机
          for (const cam of cameraArray) {
            if (cam.position === camera.CameraPosition.CAMERA_POSITION_BACK) {
              cameraId = cam.cameraId;
              break;
            }
          }
          
          // 创建相机输入
          const cameraInput = await cameraManager.createCameraInput(cameraId);
          
          if (!cameraInput) {
            throw new Error('无法创建相机输入');
          }
          
          // 创建预览输出
          const previewOutput = await camera.createPreviewOutput(cameraInput);
          
          if (!previewOutput) {
            // 释放资源
            await cameraInput.close();
            throw new Error('无法创建预览输出');
          }
          
          // 创建照片输出
          const photoOutput = await camera.createPhotoOutput(cameraInput);
          
          if (!photoOutput) {
            // 释放资源
            await previewOutput.release();
            await cameraInput.close();
            throw new Error('无法创建照片输出');
          }
          
          try {
            // 启动相机
            await cameraInput.open();
            
            // 启动预览
            await previewOutput.start();
            
            // 设置拍照参数
            const photoSettings = {
              quality: camera.QualityLevel.HIGH,
              rotation: camera.ImageRotation.ROTATION_0
            };
            
            // 拍照
            const photoData = await photoOutput.capture(photoSettings);
            
            if (!photoData || !photoData.buffer) {
              throw new Error('拍照未返回有效数据');
            }
            
            // 保存照片到应用缓存目录
            const appContext = this.context;
            const cacheDir = appContext.cacheDir;
            const fileName = `image_${Date.now()}.jpg`;
            const filePath = `${cacheDir}/${fileName}`;
            
            try {
              // 写入文件
              const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
              await fs.write(file.fd, photoData.buffer);
              await fs.close(file.fd);
              
              // 设置图片URI
              this.imageUri = `file://${filePath}`;
              
              // 执行图片搜索
              this.searchByImage();
            } catch (fileErr) {
              throw new Error(`保存照片失败: ${(fileErr as ErrorWithMessage).message}`);
            }
          } catch (camErr) {
            throw new Error(`相机操作失败: ${(camErr as ErrorWithMessage).message}`);
          } finally {
            // 确保资源总是被释放
            try {
              if (photoOutput) await photoOutput.release();
              if (previewOutput) await previewOutput.release();
              if (cameraInput) await cameraInput.close();
            } catch (releaseErr) {
              console.error(`释放相机资源失败: ${(releaseErr as ErrorWithMessage).message}`);
            }
          }
        } catch (camErr) {
          throw new Error(`相机操作失败: ${(camErr as ErrorWithMessage).message}`);
        }
      } else {
        this.errorMsg = '未找到可用的相机设备';
        prompt.showToast({ message: this.errorMsg });
      }
    } catch (err) {
      this.errorMsg = `拍照失败: ${(err as ErrorWithMessage).message}`;
      prompt.showToast({ message: this.errorMsg });
    }
  }
  
  async selectFromGallery() {
    try {
      // 检查文件读取权限
      const atManager = abilityAccessCtrl.createAtManager();
      const hasPermission = await atManager.checkAccessToken(
        this.context.applicationInfo.accessTokenId,
        'ohos.permission.READ_MEDIA_IMAGES'
      );
      
      if (hasPermission !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        this.errorMsg = '无法访问相册，请在系统设置中授予读取媒体权限';
        prompt.showToast({ message: this.errorMsg });
        return;
      }
      
      // 创建文件选择器
      const photoPicker = new picker.PhotoViewPicker();
      
      // 设置选择器选项
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;
      
      // 显示选择器
      const photoSelectResult = await photoPicker.select(options);
      
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        // 获取选中图片的URI
        this.imageUri = photoSelectResult.photoUris[0];
        
        // 执行图片搜索
        this.searchByImage();
      } else {
        prompt.showToast({ message: '未选择图片' });
      }
    } catch (err) {
      this.errorMsg = `选择图片失败: ${(err as ErrorWithMessage).message}`;
      prompt.showToast({ message: this.errorMsg });
    }
  }
  
  async searchByImage() {
    if (!this.imageUri) {
      prompt.showToast({ message: '请先选择或拍摄图片' });
      return;
    }
    
    this.isLoading = true;
    
    try {
      // 读取图片数据
      const imageSource = await image.createImageSource(this.imageUri);
      
      if (!imageSource) {
        throw new Error('无法创建图片源');
      }
      
      try {
        // 获取图像信息
        const imageInfo = await imageSource.getImageInfo();
        
        // 创建图像包装器
        const imagePackage = await imageSource.createImagePackage();
        
        if (!imagePackage) {
          throw new Error('无法创建图像包');
        }
        
        // 获取图像像素映射
        const pixelMap = await imagePackage.getPixelMap();
        
        if (!pixelMap) {
          throw new Error('无法获取图像像素映射');
        }
        
        try {
          // 将图像数据转换为Base64字符串
          const buffer = await pixelMap.getPixelBytes();
          const base64Data = buffer.toString('base64');
          
          if (!base64Data) {
            throw new Error('无法转换图像数据为Base64格式');
          }
          
          // 调用服务进行图像搜索
          this.artifactService.searchByImage(base64Data)
            .then((artifacts) => {
              this.searchResults = artifacts;
              this.isLoading = false;
              
              if (artifacts.length === 0) {
                prompt.showToast({ message: '未找到匹配的文物' });
              }
            })
            .catch((err: ErrorWithMessage) => {
              this.errorMsg = `搜索失败: ${err.message}`;
              this.isLoading = false;
              prompt.showToast({ message: this.errorMsg });
            });
        } finally {
          // 释放像素映射资源
          if (pixelMap) {
            pixelMap.release();
          }
        }
      } finally {
        // 释放图像源资源
        if (imageSource) {
          imageSource.release();
        }
      }
    } catch (err) {
      this.errorMsg = `处理图片失败: ${(err as ErrorWithMessage).message}`;
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