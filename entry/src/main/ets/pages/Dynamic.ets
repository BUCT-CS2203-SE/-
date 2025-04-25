import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';

@Entry
@Component
struct Dynamic {
  @State posts: Array<Post> = [];
  @State newPostContent: string = '';
  @State showCommentInput: boolean = false;
  @State currentPostId: number = -1;
  @State commentContent: string = '';

  @Builder
  PostBuilder(post: Post) {
    Column() {
      // 用户信息
      Row() {
        Text(post.username)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 动态内容
      Text(post.content)
        .fontSize(16)
        .width('100%')
        .margin({ bottom: 10 })

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
      // 发布动态区域
      Row() {
        TextInput({ placeholder: '分享你的想法...', text: this.newPostContent })
          .width('80%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
            this.newPostContent = value;
          })
        
        Button('发布', { type: ButtonType.Normal })
          .width('15%')
          .height(40)
          .backgroundColor('#1698CE')
          .margin({ left: 10 })
          .onClick(() => {
            if (this.newPostContent.trim()) {
              this.posts.unshift({
                id: this.posts.length + 1,
                username: '当前用户',
                content: this.newPostContent,
                likes: 0,
                isLiked: false,
                comments: []
              });
              this.newPostContent = '';
            }
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 动态列表
      List({ space: 10 }) {
        ForEach(this.posts, (post: Post) => {
          ListItem() {
            this.PostBuilder(post)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)

      // 评论输入框
      if (this.showCommentInput) {
        Row() {
          TextInput({ placeholder: '输入评论...', text: this.commentContent })
            .width('80%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .padding({ left: 15, right: 15 })
            .onChange((value: string) => {
              this.commentContent = value;
            })
          
          Button('发送', { type: ButtonType.Normal })
            .width('15%')
            .height(40)
            .backgroundColor('#1698CE')
            .margin({ left: 10 })
            .onClick(() => {
              if (this.commentContent.trim()) {
                const post = this.posts.find(p => p.id === this.currentPostId);
                if (post) {
                  post.comments.push({
                    username: '当前用户',
                    content: this.commentContent
                  });
                }
                this.commentContent = '';
                this.showCommentInput = false;
              }
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}

interface Post {
  id: number;
  username: string;
  content: string;
  likes: number;
  isLiked: boolean;
  comments: Array<Comment>;
}

interface Comment {
  username: string;
  content: string;
} 