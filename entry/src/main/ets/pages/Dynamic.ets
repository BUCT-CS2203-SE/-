import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';

@Entry
@Component
struct Dynamic {
  @State posts: Array<Post> = [];
  @State newPostContent: string = '';
  @State showCommentInput: boolean = false;
  @State currentPostId: number = -1;
  @State commentContent: string = '';
  @State favoritePosts: Set<number> = new Set();
  @State selectedImages: string[] = [];

  @Builder
  PostBuilder(post: Post) {
    Column() {
      // 用户信息和发布时间
      Row() {
        // 用户头像
        Image(post.avatarUrl || $r('app.media.icon'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 10 })
        
        Column() {
          // 用户名
          Text(post.username)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          // 发布时间
          Text(post.createTime)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 动态内容
      Text(post.content)
        .fontSize(16)
        .width('100%')
        .margin({ bottom: 10 })

      // 图片展示
      if (post.images && post.images.length > 0) {
        Grid() {
          ForEach(post.images, (image: string) => {
            GridItem() {
              Image(image)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .columnsGap(5)
        .rowsGap(5)
        .width('100%')
        .height(300)
        .margin({ bottom: 10 })
      }

      // 操作栏
      Row() {
        // 点赞按钮
        Row() {
          Text(post.isLiked ? '♥' : '♡')
            .fontSize(20)
            .fontColor(post.isLiked ? '#FF0000' : '#666666')
          Text(post.likes.toString())
            .fontSize(14)
            .margin({ left: 5 })
        }
        .onClick(() => {
          post.isLiked = !post.isLiked;
          post.likes += post.isLiked ? 1 : -1;
        })
        .margin({ right: 20 })

        // 评论按钮
        Row() {
          Text('💬')
            .fontSize(20)
          Text(post.comments.length.toString())
            .fontSize(14)
            .margin({ left: 5 })
        }
        .onClick(() => {
          this.currentPostId = post.id;
          this.showCommentInput = true;
        })
        .margin({ right: 20 })

        // 收藏按钮
        Row() {
          Text(this.favoritePosts.has(post.id) ? '★' : '☆')
            .fontSize(20)
            .fontColor(this.favoritePosts.has(post.id) ? '#FFD700' : '#666666')
        }
        .onClick(() => {
          if (this.favoritePosts.has(post.id)) {
            this.favoritePosts.delete(post.id);
            prompt.showToast({ message: '已取消收藏' });
          } else {
            this.favoritePosts.add(post.id);
            prompt.showToast({ message: '已收藏' });
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 评论列表
      if (post.comments.length > 0) {
        Column() {
          ForEach(post.comments, (comment: Comment) => {
            Row() {
              Text(comment.username)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1698CE')
              Text(comment.content)
                .fontSize(14)
                .margin({ left: 5 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 5 })
          })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F5F5')
        .borderRadius(5)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ bottom: 10 })
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
        Button('发布', { type: ButtonType.Normal })
          .width('100%')
          .height(40)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .onClick(() => {
            if (this.newPostContent.trim()) {
              this.posts.unshift({
                id: this.posts.length + 1,
                username: '当前用户',
                avatarUrl: '',
                content: this.newPostContent,
                createTime: new Date().toLocaleString(),
                likes: 0,
                isLiked: false,
                images: this.selectedImages,
                comments: []
              });
              this.newPostContent = '';
              this.selectedImages = [];
              prompt.showToast({ message: '发布成功' });
              router.back();
            } else {
              prompt.showToast({ message: '请输入动态内容' });
            }
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
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

interface Post {
  id: number;
  username: string;
  avatarUrl: string;
  content: string;
  createTime: string;
  likes: number;
  isLiked: boolean;
  images: string[];
  comments: Array<Comment>;
}

interface Comment {
  username: string;
  content: string;
} 