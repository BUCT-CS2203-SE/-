import { UserComment, Post } from '../model/UserModel';
import { CommentService } from '../services/CommentService';
import { UserService } from '../services/UserService';

@Component
export struct CommentComponent {
  @State post: Post;
  @State comments: UserComment[] = [];
  @State newComment: string = '';
  @State isCommenting: boolean = false;
  private commentService: CommentService = new CommentService();
  private userService: UserService = new UserService();

  aboutToAppear() {
    this.loadComments();
  }

  private async loadComments() {
    const allComments = await this.commentService.getAllComments();
    this.comments = allComments.filter(comment => comment.artifactId === this.post.id);
  }

  private async handleAddComment() {
    if (!this.newComment.trim()) {
      return;
    }

    const currentUser = await this.userService.getCurrentUser();
    if (!currentUser) {
      return;
    }

    const newComment: UserComment = new UserComment(
      Date.now().toString(),
      currentUser.id,
      currentUser.username,
      currentUser.avatarUrl,
      this.newComment,
      new Date().toISOString(),
      this.post.id.toString()
    );

    await this.commentService.saveComment(newComment);
    this.comments = [...this.comments, newComment];
    this.newComment = '';
    this.isCommenting = false;
  }

  private async handleLikeComment(comment: UserComment) {
    // Note: Like functionality needs to be implemented in UserComment class
    // This is just a placeholder for now
    const updatedComment = new UserComment(
      comment.id,
      comment.userId,
      comment.username,
      comment.avatarUrl,
      comment.content,
      comment.createTime,
      comment.artifactId
    );

    await this.commentService.saveComment(updatedComment);
    this.comments = this.comments.map(c => 
      c.id === comment.id ? updatedComment : c
    );
  }

  build() {
    Column() {
      // 评论列表
      List() {
        ForEach(this.comments, (comment: UserComment) => {
          ListItem() {
            Column() {
              Row() {
                Text(comment.username)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                Text(comment.createTime)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 8 })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              Text(comment.content)
                .fontSize(14)
                .margin({ top: 4, bottom: 4 })

              // Note: Like functionality needs to be implemented
              // This is just a placeholder for now
              Row() {
                Image($r('app.media.ic_like'))
                  .width(16)
                  .height(16)
                  .margin({ right: 4 })
                Text('0')
                  .fontSize(12)
                  .fontColor('#999')
              }
              .onClick(() => this.handleLikeComment(comment))
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
        })
      }
      .width('100%')
      .height(200)
      .margin({ top: 12 })

      // 添加评论
      if (this.isCommenting) {
        Column() {
          TextArea({
            placeholder: '写下你的评论...',
            text: this.newComment
          })
            .width('100%')
            .height(100)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(8)
            .onChange((value: string) => {
              this.newComment = value;
            })

          Row() {
            Button('取消')
              .onClick(() => {
                this.isCommenting = false;
                this.newComment = '';
              })
            Button('发送')
              .margin({ left: 8 })
              .onClick(() => this.handleAddComment())
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .margin({ top: 8 })
        }
        .width('100%')
        .margin({ top: 12 })
      } else {
        Button('添加评论')
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            this.isCommenting = true;
          })
      }
    }
    .width('100%')
    .padding(16)
  }
} 