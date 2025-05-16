import router from '@ohos.router';
import prompt from '@ohos.prompt';
import { PostService } from '../services/PostService';
import { CommentService } from '../services/CommentService';
import { Post, Comment } from '../model/PostModel';
import { CommentData } from '../model/CommentModel';
import { formatDate } from '../utils/DateUtils';
import { getUserInfo } from '../utils/UserUtils';

/**
 * 路由参数接口
 */
interface RouteParams {
  postId: string;
}

@Entry
@Component
struct PostDetail {
  @State post: Post | null = null;
  @State comments: Comment[] = [];
  @State isLoading: boolean = true;
  @State isLoadingComments: boolean = false;
  @State commentContent: string = '';
  @State isSubmittingComment: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.postId) {
      this.loadPostDetail(params.postId);
      this.loadComments(params.postId);
    } else {
      prompt.showToast({ message: '参数错误，无法加载帖子' });
      setTimeout(() => {
        router.back();
      }, 1000);
    }
  }

  /**
   * 加载帖子详情
   * @param postId 帖子ID
   */
  async loadPostDetail(postId: string) {
    try {
      this.isLoading = true;
      const postData = await PostService.getPostById(postId);
      if (postData) {
        this.post = postData;
      } else {
        prompt.showToast({ message: '帖子不存在或已被删除' });
        setTimeout(() => {
          router.back();
        }, 1000);
      }
    } catch (error) {
      console.error('加载帖子详情失败:', error);
      prompt.showToast({ message: '加载帖子失败，请稍后重试' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载评论列表
   * @param postId 帖子ID
   */
  async loadComments(postId: string) {
    try {
      this.isLoadingComments = true;
      const result = await PostService.getComments(postId);
      if (result.code === 0 && result.data) {
        this.comments = result.data;
      } else {
        console.error('获取评论列表失败:', result.message);
      }
    } catch (error) {
      console.error('加载评论失败:', error);
    } finally {
      this.isLoadingComments = false;
    }
  }

  /**
   * 发表评论
   */
  async submitComment() {
    if (!this.commentContent.trim()) {
      prompt.showToast({ message: '请输入评论内容' });
      return;
    }

    try {
      this.isSubmittingComment = true;
      const userInfo = await getUserInfo();
      if (!userInfo) {
        prompt.showToast({ message: '请先登录后再评论' });
        this.isSubmittingComment = false;
        return;
      }

      const now = new Date();
      const commentData: CommentData = {
        comment_id: `comment_${now.getTime()}`,
        post_id: this.post?.post_id || '',
        user_id: userInfo.user_id,
        nickname: userInfo.nickname,
        img_url: userInfo.img_url,
        content: this.commentContent,
        create_time: formatDate(now, 'YYYY-MM-DD HH:mm:ss'),
        create_timestamp: now.getTime()
      };

      const result = await CommentService.addComment(commentData);
      if (result.code === 0 && result.data) {
        prompt.showToast({ message: '评论发表成功' });
        this.commentContent = '';
        // 刷新评论列表
        this.loadComments(this.post?.post_id || '');
      } else {
        prompt.showToast({ 
          message: result.message || '评论发表失败，请稍后重试',
          duration: 3000
        });
      }
    } catch (error) {
      console.error('发表评论失败:', error);
      prompt.showToast({ message: '评论发表失败，请稍后重试' });
    } finally {
      this.isSubmittingComment = false;
    }
  }

  /**
   * 点赞/取消点赞
   */
  async toggleLike() {
    if (!this.post) return;
    
    try {
      if (this.post.is_favorited === 1) {
        const result = await PostService.unlikePost(this.post.post_id);
        if (result.code === 0 && result.data) {
          this.post.likes = result.data.likes;
          this.post.is_favorited = 0;
          prompt.showToast({ message: '已取消点赞' });
        } else {
          prompt.showToast({ message: '操作失败，请稍后重试' });
        }
      } else {
        const result = await PostService.likePost(this.post.post_id);
        if (result.code === 0 && result.data) {
          this.post.likes = result.data.likes;
          this.post.is_favorited = 1;
          prompt.showToast({ message: '点赞成功' });
        } else {
          prompt.showToast({ message: '操作失败，请稍后重试' });
        }
      }
    } catch (error) {
      console.error('点赞操作失败:', error);
      prompt.showToast({ message: '操作失败，请稍后重试' });
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
        
        Text('帖子详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1698CE')
          
          Text('正在加载...')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.post) {
        Scroll() {
          Column() {
            // 帖子内容卡片
            Column() {
              // 用户信息和发布时间
              Row() {
                Image(this.post.img_url || $r('app.media.icon'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .margin({ right: 10 })
                
                Column() {
                  Text(this.post.nickname)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  
                  Text(this.post.create_time)
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ bottom: 16 })

              // 帖子内容
              Text(this.post.content)
                .fontSize(16)
                .width('100%')
                .margin({ bottom: 16 })

              // 帖子图片
              if (this.post.post_img_url) {
                Image(this.post.post_img_url)
                  .width('100%')
                  .aspectRatio(1.5)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
                  .margin({ bottom: 16 })
              }

              // 交互数据
              Row() {
                Row() {
                  Text(this.post.is_favorited === 1 ? '♥' : '♡')
                    .fontSize(24)
                    .fontColor(this.post.is_favorited === 1 ? '#FF0000' : '#666666')
                  Text(this.post.likes.toString())
                    .fontSize(14)
                    .margin({ left: 5 })
                }
                .onClick(() => {
                  this.toggleLike();
                })
                .margin({ right: 24 })

                Row() {
                  Text('💬')
                    .fontSize(24)
                  Text(this.comments.length.toString())
                    .fontSize(14)
                    .margin({ left: 5 })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ bottom: 12 })

            // 评论区域
            Column() {
              // 评论标题
              Row() {
                Text('评论')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 12 })
              }
              .width('100%')

              // 评论列表
              if (this.isLoadingComments) {
                Row() {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .color('#1698CE')
                  Text('加载评论中...')
                    .fontSize(14)
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ vertical: 16 })
              } else if (this.comments.length === 0) {
                Text('暂无评论，快来发表第一条评论吧')
                  .fontSize(14)
                  .fontColor('#999999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ vertical: 16 })
              } else {
                Column() {
                  ForEach(this.comments, (comment: Comment) => {
                    Column() {
                      // 评论用户信息
                      Row() {
                        Image(comment.img_url || $r('app.media.icon'))
                          .width(32)
                          .height(32)
                          .borderRadius(16)
                          .margin({ right: 8 })
                        
                        Column() {
                          Text(comment.nickname)
                            .fontSize(14)
                            .fontWeight(FontWeight.Bold)
                          
                          Text(comment.create_time)
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                        .alignItems(HorizontalAlign.Start)
                      }
                      .width('100%')
                      .margin({ bottom: 8 })
                      
                      // 评论内容
                      Text(comment.content)
                        .fontSize(15)
                        .width('100%')
                        .padding({ left: 40 })
                      
                      Divider()
                        .width('100%')
                        .margin({ top: 12, bottom: 12 })
                        .color('#EEEEEE')
                    }
                    .width('100%')
                  })
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          .width('100%')
          .padding(12)
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          Image($r('app.media.no_result'))
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          
          Text('帖子不存在或已被删除')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 评论输入区域
      Row() {
        TextInput({ placeholder: '说点什么...', text: this.commentContent })
          .width('75%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.commentContent = value;
          })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Row() {
            if (this.isSubmittingComment) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#FFFFFF')
                .margin({ right: 5 })
            }
            Text('发送')
              .fontColor('#FFFFFF')
          }
        }
        .width('20%')
        .height(40)
        .backgroundColor('#1698CE')
        .borderRadius(20)
        .enabled(!this.isSubmittingComment)
        .onClick(() => {
          this.submitComment();
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 0.5 }, color: '#EEEEEE' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 