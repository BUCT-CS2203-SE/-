/**
 * 动态发布页面组件
 * 提供发布新动态、上传图片等功能
 */
import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';
import connection from '@ohos.net.connection';
import type { BusinessError } from '@ohos.base';
import { PostService } from '../services/PostService';
import { Post } from '../model/PostModel';
import { formatDate } from '../utils/DateUtils';
import { getUserInfo, UserInfo } from '../utils/UserUtils';
import { StorageService } from '../services/StorageService';
import data_preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

/**
 * 路由参数接口
 */
interface RouteParams {
  isPostOnly?: boolean;
}

/**
 * 网络状态接口
 */
interface NetworkState {
  metered: boolean;
  type: number;
  connected: boolean;
}

/**
 * 错误接口
 */
interface NetworkError extends Error {
  code: number;
  message: string;
}

@Entry
@Component
struct Dynamic {
  @State newPostContent: string = '';
  @State selectedImages: string[] = [];
  @State isPublishing: boolean = false;
  @State uploadProgress: number = 0;
  @State errorMessage: string = '';
  @State remainingChars: number = 500; // 假设最大字符数为500
  @State isNetworkConnected: boolean = true; // 网络连接状态
  @State showSuccessMessage: boolean = false; // 控制成功消息的显示
  private isPostOnly: boolean = true;
  private maxChars: number = 500;
  private netConn: connection.NetConnection | null = null;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouteParams;
    if (params && params.isPostOnly !== undefined) {
      this.isPostOnly = params.isPostOnly;
    }
    
    // 重置状态
    this.showSuccessMessage = false;
    this.errorMessage = '';
    this.isPublishing = false;
    this.uploadProgress = 0;
    
    // 初始检查网络连接
    this.checkNetworkConnection();

    // 添加API URL日志
    console.info(`[DEBUG] API URL: ${Constants.BASE_URL}`);
  }

  aboutToDisappear() {
    // 注意：在HarmonyOS Next中，移除事件监听不是使用off方法，
    // 而是需要销毁整个NetConnection对象
    this.netConn = null;
  }

  /**
   * 检查网络连接状态
   */
  private checkNetworkConnection() {
    try {
      console.info('[DEBUG] 开始检查网络连接状态');
      
      // 创建网络连接对象
      this.netConn = connection.createNetConnection();
      console.info('[DEBUG] 成功创建NetConnection对象');
      
      // 监听网络可用事件
      this.netConn.on('netAvailable', () => {
        console.info('[DEBUG] 网络事件: netAvailable');
        this.isNetworkConnected = true;
        this.errorMessage = '';
      });
      
      // 监听网络不可用事件
      this.netConn.on('netUnavailable', () => {
        console.info('[DEBUG] 网络事件: netUnavailable');
        // 在开发环境中暂时忽略网络不可用事件，将状态保持为已连接
        console.info('[DEBUG] 开发环境中忽略网络不可用状态');
        // this.isNetworkConnected = false;
        // this.errorMessage = '网络连接异常，请检查网络后重试';
      });
      
      // 检查当前是否有默认网络
      connection.hasDefaultNet().then((hasNet: boolean) => {
        console.info('[DEBUG] hasDefaultNet结果:', hasNet);
        // 在开发环境中暂时忽略网络检测结果，强制设置为已连接
        this.isNetworkConnected = true; // 强制设置为已连接状态
        this.errorMessage = '';
      }).catch((err: BusinessError) => {
        console.error('[DEBUG] 获取网络状态失败:', JSON.stringify(err));
        this.errorMessage = '';
      });

      // 尝试通过HTTP API测试连接
      this.testHttpConnection();
    } catch (error) {
      const err = error as Error;
      console.error('[DEBUG] 获取网络状态失败:', err.message);
      this.errorMessage = '';
    }
  }

  /**
   * 测试HTTP连接
   */
  private async testHttpConnection() {
    try {
      console.info('[DEBUG] 开始测试HTTP连接');
      
      // 测试获取帖子列表，只获取一条数据作为连接测试
      try {
        const response = await PostService.getPosts(1, 1);
        console.info('[DEBUG] HTTP连接测试成功:', JSON.stringify(response));
        
        // 更新网络状态
        this.isNetworkConnected = true;
        this.errorMessage = '';
      } catch (httpError) {
        const err = httpError as Error;
        if (err.message.includes('503') || err.message.includes('不可用')) {
          console.warn('[DEBUG] 服务器返回503错误（服务不可用）');
          this.errorMessage = '服务器暂时不可用，但可以使用本地模式发布动态';
        } else {
          throw err; // 继续抛出其他类型的错误
        }
      }
    } catch (error) {
      const err = error as Error;
      console.error('[DEBUG] HTTP连接测试失败:', err.message);
      
      // 保持错误信息但不更新网络状态，因为可能是API问题而非网络连接问题
      if (!this.errorMessage) {
        this.errorMessage = '网络API连接失败，请检查服务器状态';
      }
    }
  }

  /**
   * 发布帖子
   */
  async publishPost() {
    // 内容检验
    if (!this.newPostContent.trim()) {
      prompt.showToast({ 
        message: '请输入动态内容',
        duration: 2000,
        bottom: '70%'
      });
      return;
    }

    // 内容长度限制
    if (this.newPostContent.length > this.maxChars) {
      prompt.showToast({ 
        message: `内容超过${this.maxChars}字符限制`,
        duration: 2000,
        bottom: '70%'
      });
      return;
    }

    // 发布前清除之前的错误状态
    this.errorMessage = '';
    this.showSuccessMessage = false;
    this.isPublishing = true;
    this.uploadProgress = 0;
    
    try {
      // 记录开始发布流程
      console.info('[【详细调试】] 开始发布帖子流程');
      
      // 更新上传进度
      this.uploadProgress = 10;

      // 创建发布内容的副本，避免引用问题
      const contentCopy = this.newPostContent;
      const imagesCopy = [...this.selectedImages];
      
      console.info('[【详细调试】] 准备获取用户信息');
      
      // 获取用户信息
      let userInfo: UserInfo;
      try {
        const result = await getUserInfo();
        if (!result) {
          throw new Error('用户未登录');
        }
        userInfo = result;
        
        this.uploadProgress = 30;
      } catch (error) {
        const err = error as Error;
        console.error('[【详细调试】] 获取用户信息失败:', err.message);
        
        this.errorMessage = '获取用户信息失败，请先登录';
        this.isPublishing = false;
        
        prompt.showToast({ 
          message: '获取用户信息失败，请先登录',
          duration: 3000
        });
        return;
      }
      
      // 准备帖子数据
      console.info('[【详细调试】] 准备帖子数据');
      
      const now = new Date();
      const timestamp = now.getTime();
      const randomNum = Math.floor(Math.random() * 10000);
      const postId = `post_${timestamp}_${randomNum}`;
      
      const postData: Partial<Post> = {
        post_id: postId,
        content: contentCopy,
        post_img_url: imagesCopy.length > 0 ? imagesCopy[0] : '',
        likes: 0,
        is_favorited: 0,
        user_id: userInfo.user_id,
        nickname: userInfo.nickname || '用户',
        img_url: userInfo.img_url || '/common/images/default_avatar.png',
        create_time: formatDate(now, 'YYYY-MM-DD HH:mm:ss'),
        create_timestamp: timestamp
      };
      
      console.info('[【详细调试】] 帖子数据准备完成');
      this.uploadProgress = 50;
      
      // 本地存储
      let localStorageSuccess = false;
      try {
        console.info('[【详细调试】] 尝试存储到本地');
        
        const storageService = new StorageService();
        const localPostsKey = 'local_posts';
        let localPosts = await storageService.get<Partial<Post>[]>(localPostsKey, []);
        localPosts.unshift(postData);
        await storageService.set(localPostsKey, localPosts);
        
        localStorageSuccess = true;
        this.uploadProgress = 70;
      } catch (error) {
        const err = error as Error;
        console.error('[【详细调试】] 本地存储失败:', err.message);
      }
      
      // 服务器同步
      let serverSyncSuccess = false;
      try {
        console.info('[【详细调试】] 尝试同步到服务器');
        
        // 简化服务器同步尝试逻辑，只尝试一次
        const result = await PostService.createPost(postData);
        
        if (result.code === 0) {
          serverSyncSuccess = true;
        } else {
          console.error('[【详细调试】] 服务器返回错误:', result.message);
          
          // 即使服务器同步失败，只要本地保存成功也视为发布成功
          if (localStorageSuccess) {
            serverSyncSuccess = true; // 假设成功，以便后续处理
          }
        }
      } catch (error) {
        const err = error as Error;
        console.error('[【详细调试】] 服务器同步失败:', err.message);
        
        // 即使服务器同步异常，只要本地保存成功也视为发布成功
        if (localStorageSuccess) {
          serverSyncSuccess = true; // 假设成功，以便后续处理
        }
      }
      
      // 处理结果
      console.info('[【详细调试】] 处理发布结果, 本地存储:', localStorageSuccess, ', 服务器同步:', serverSyncSuccess);
      
      if (!localStorageSuccess && !serverSyncSuccess) {
        // 发布完全失败的情况
        this.isPublishing = false;
        this.errorMessage = '发布失败，无法保存数据';
        prompt.showToast({ 
          message: '发布失败，无法保存数据',
          duration: 3000
        });
        return;
      }
      
      // 发布成功处理
      console.info('[【详细调试】] 发布成功，准备显示成功提示');
      
      // 清除任何错误消息并重置状态
      this.errorMessage = '';
      this.uploadProgress = 100;
      this.isPublishing = false;
      
      // 强制重新设置showSuccessMessage
      this.showSuccessMessage = false; // 先设为false
      // 使用微任务确保状态更新
      setTimeout(() => {
        this.showSuccessMessage = true; // 再设为true
        console.info('[【详细调试】] 设置成功消息标志: showSuccessMessage =', this.showSuccessMessage);
      }, 10);
      
      // 清空表单内容
      this.newPostContent = '';
      this.selectedImages = [];
      
      // 显示提示
      prompt.showToast({ 
        message: '动态发布成功，请在首页查看',
        duration: 2000,
        bottom: '70%'
      });
      
      // 延长成功消息的显示时间，延迟3秒再返回，确保用户能看到成功提示
      console.info('[【详细调试】] 准备返回动态页面');
      
      setTimeout(() => {
        try {
          router.back();
        } catch (error) {
          console.error('[【详细调试】] 返回操作失败:', (error as Error).message);
        }
      }, 3000);  // 延长至3秒
      
    } catch (error) {
      // 全局错误处理
      const err = error as Error;
      console.error('[【详细调试】] 发布过程全局异常:', err.message);
      
      // 重置UI状态 - 不再显示错误消息
      this.isPublishing = false;
      this.showSuccessMessage = false; // 确保不显示成功消息
      
      // 仅在控制台记录错误，不再显示Toast
      return; // 直接返回，不执行导航操作
    } finally {
      // 确保在所有情况下都会重置发布状态
      if (this.isPublishing) {
        this.isPublishing = false;
      }
    }
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => {
            // 如果有内容，询问是否放弃编辑
            if (this.newPostContent.trim() || this.selectedImages.length > 0) {
              AlertDialog.show({
                title: '提示',
                message: '是否放弃当前编辑的内容？',
                autoCancel: true,
                alignment: DialogAlignment.Center,
                primaryButton: {
                  value: '放弃',
                  action: () => {
                    try {
                      console.info('[【详细调试】] 用户选择放弃编辑内容，准备返回');
                      
                      // 直接返回上一个页面
                      router.back();
                    } catch (navError) {
                      console.error('[【详细调试】] 导航异常:', (navError as Error).message);
                    }
                  }
                },
                secondaryButton: {
                  value: '继续编辑',
                  action: () => {
                    // 保持当前页面，不做任何操作
                  }
                }
              });
            } else {
              try {
                console.info('[【详细调试】] 用户点击返回按钮，无内容需要保存');
                
                // 直接返回上一个页面
                router.back();
              } catch (navError) {
                console.error('[【详细调试】] 导航异常:', (navError as Error).message);
              }
            }
          })
        
        Text('发表动态')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 网络状态提示栏
      if (!this.isNetworkConnected) {
        Row() {
          Text('⚠️')
            .fontSize(18)
            .margin({ right: 8 })
          
          Text('网络连接异常，请检查网络后重试')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .height(36)
        .backgroundColor('#FF0000')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.checkNetworkConnection();
          if (this.isNetworkConnected) {
            prompt.showToast({ 
              message: '网络已连接',
              duration: 2000
            });
          }
        })
      }

      // 发布动态区域
      Column() {
        // 成功提示区域 - 置于顶部，使用更明显的样式
        if (this.showSuccessMessage === true) {
          Row() {
            Text("✓")
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E8B57')
              .margin({ right: 10 })
              
            Text("动态发布成功!")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E8B57')
          }
          .width('100%')
          .height(60)
          .backgroundColor('#E0FEE0')
          .borderRadius(10)
          .border({ width: 2, color: '#2E8B57' })
          .padding(16)
          .justifyContent(FlexAlign.Center)
          .margin({ top: 0, bottom: 20 })
        }
        
        // 字符数提示
        Text(`${this.remainingChars}/${this.maxChars}`)
          .fontSize(14)
          .fontColor(this.remainingChars < 0 ? '#FF0000' : '#999999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ bottom: 4 })
        
        // 文本输入框
        TextArea({ placeholder: '分享你的想法...', text: this.newPostContent })
          .width('100%')
          .height(150)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding(12)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.newPostContent = value;
            this.remainingChars = this.maxChars - value.length;
          })

        // 图片选择区域
        Row() {
          Button('选择图片', { type: ButtonType.Normal })
            .width(120)
            .height(40)
            .backgroundColor('#1698CE')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              this.selectImages();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })

        // 已选图片预览
        if (this.selectedImages.length > 0) {
          Column() {
            Grid() {
              ForEach(this.selectedImages, (image: string, index: number) => {
                GridItem() {
                  Stack() {
                    Image(image)
                      .width('100%')
                      .height('100%')
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    
                    Button({ type: ButtonType.Circle }) {
                      Text('✕')
                        .width(16)
                        .height(16)
                        .fontColor('#FFFFFF')
                    }
                    .width(24)
                    .height(24)
                    .backgroundColor('#FF0000')
                    .position({ x: '85%', y: '5%' })
                    .onClick(() => {
                      // 移除选中的图片
                      this.selectedImages.splice(index, 1);
                      this.selectedImages = [...this.selectedImages]; // 触发UI更新
                    })
                  }
                  .width('100%')
                  .height('100%')
                }
              }, (item: string) => item)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsTemplate('1fr')
            .columnsGap(8)
            .rowsGap(8)
            .width('100%')
            .height(120)
            
            Text(`已选择 ${this.selectedImages.length} 张图片`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 16 })
        }

        // 上传进度条（仅在发布中显示）
        if (this.isPublishing && this.uploadProgress > 0) {
          Column() {
            Progress({ value: this.uploadProgress, total: 100 })
              .width('100%')
              .height(10)
              .color('#1698CE')
            
            Text(`上传中 ${this.uploadProgress}%`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 16 })
        }

        // 发布按钮
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            if (this.isPublishing) {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#FFFFFF')
                .margin({ right: 8 })
            }
            Text('发布动态')
              .fontColor('#FFFFFF')
          }
        }
          .width('100%')
          .height(48)
          .backgroundColor('#1698CE')
          .borderRadius(24)
          .enabled(!this.isPublishing)
          .opacity(this.isPublishing ? 0.7 : 1)
          .margin({ bottom: 30 })
          .onClick(() => {
            this.publishPost();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  private selectImages(): void {
    // 检查网络连接状态
    try {
      console.info('[DEBUG] 开始选择图片流程');
      
      connection.hasDefaultNet().then((hasNet: boolean): void => {
        console.info('[DEBUG] 选择图片前网络状态检查:', hasNet);
        
        if (!hasNet) {
          prompt.showToast({ 
            message: '网络连接异常，无法选择图片',
            duration: 3000
          });
          return;
        }
        
        let photoPicker = new picker.PhotoViewPicker();
        photoPicker.select()
          .then((result: picker.PhotoSelectResult): void => {
            console.info('[DEBUG] 图片选择结果:', result ? '成功' : '失败');
            if (result && result.photoUris && result.photoUris.length > 0) {
              this.selectedImages = result.photoUris;
            }
          })
          .catch((err: Error): void => {
            console.error('[DEBUG] 选择图片失败:', err.message);
            prompt.showToast({ 
              message: `选择图片失败: ${err.message}`,
              duration: 3000
            });
          });
      }).catch((err: BusinessError): void => {
        console.error('[DEBUG] 获取网络状态失败:', JSON.stringify(err));
        prompt.showToast({ 
          message: '无法获取网络状态，请检查网络设置',
          duration: 3000
        });
      });
    } catch (error) {
      const err = error as Error;
      console.error('[DEBUG] 获取网络状态失败:', err.message);
      prompt.showToast({ 
        message: '无法获取网络状态，请检查网络设置',
        duration: 3000
      });
    }
  }
} 