import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';
import { PostService } from '../services/PostService';
import { Post } from '../model/PostModel';
import { formatDate } from '../utils/DateUtils';
import { getUserInfo } from '../utils/UserUtils';

/**
 * 路由参数接口
 */
interface RouteParams {
  isPostOnly?: boolean;
}

@Entry
@Component
struct Dynamic {
  @State newPostContent: string = '';
  @State selectedImages: string[] = [];
  @State isPublishing: boolean = false;
  private isPostOnly: boolean = true;

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouteParams;
    if (params && params.isPostOnly !== undefined) {
      this.isPostOnly = params.isPostOnly;
    }
  }

  async publishPost() {
    if (!this.newPostContent.trim()) {
      prompt.showToast({ message: '请输入动态内容' });
      return;
    }

    try {
      this.isPublishing = true;
      const userInfo = await getUserInfo();
      if (!userInfo) {
        prompt.showToast({ message: '请先登录' });
        this.isPublishing = false;
        return;
      }

      const now = new Date();
      const postData: Partial<Post> = {
        post_id: `post_${now.getTime()}`,
        content: this.newPostContent,
        post_img_url: this.selectedImages.length > 0 ? this.selectedImages[0] : undefined,
        user_id: userInfo.user_id,
        nickname: userInfo.nickname,
        img_url: userInfo.img_url,
        create_time: formatDate(now, 'YYYY-MM-DD HH:mm:ss'),
        create_timestamp: now.getTime(),
        likes: 0,
        is_favorited: 0
      };

      const result = await PostService.createPost(postData);
      if (result.code === 0) {
        prompt.showToast({ message: '发布成功' });
        // 清空内容
        this.newPostContent = '';
        this.selectedImages = [];
        
        // 返回首页并跳转到动态标签
        setTimeout(() => {
          router.back();
        }, 500);
          } else {
        prompt.showToast({ message: result.message || '发布失败' });
      }
    } catch (error) {
      console.error('发布帖子失败:', error);
      prompt.showToast({ message: '发布失败，请稍后重试' });
    } finally {
      this.isPublishing = false;
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
            router.back();
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

      // 发布动态区域
      Column() {
        // 文本输入框
        TextArea({ placeholder: '分享你的想法...', text: this.newPostContent })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding(12)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.newPostContent = value;
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
          Grid() {
            ForEach(this.selectedImages, (image: string) => {
              GridItem() {
                Image(image)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsTemplate('1fr')
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .height(200)
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
            Text('发布')
              .fontColor('#FFFFFF')
          }
        }
          .width('100%')
          .height(40)
          .backgroundColor('#1698CE')
          .borderRadius(20)
        .enabled(!this.isPublishing)
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
    let photoPicker = new picker.PhotoViewPicker();
    photoPicker.select()
      .then((result: picker.PhotoSelectResult) => {
        if (result && result.photoUris && result.photoUris.length > 0) {
          this.selectedImages = result.photoUris;
        }
      })
      .catch((err: Error) => {
        console.error(`选择图片失败: ${err.message}`);
      });
  }
} 