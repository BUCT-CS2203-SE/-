import { Artifact } from '../model/ArtifactModel';
import { Comment } from '../model/UserModel';
import { ArtifactService } from '../services/ArtifactService';
import { UserService } from '../services/UserService';
import { Constants, CategoryItem } from '../common/constants/Constants';
import router from '@ohos.router';
import prompt from '@ohos.prompt';

interface RouterParams {
  artifactId: string;
}

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

@Entry
@Component
struct ArtifactDetail {
  @State artifact: Artifact = new Artifact('', '', '', '', '', '', 1, '', 0, 0);
  @State comments: Comment[] = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';
  @State commentText: string = '';
  @State isLiked: boolean = false;
  @State isFavorite: boolean = false;
  
  private artifactId: string = '';
  private artifactService: ArtifactService = new ArtifactService();
  private userService: UserService = new UserService();
  
  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.artifactId) {
      this.artifactId = params.artifactId;
      this.loadArtifactDetail();
      this.loadComments();
    } else {
      this.errorMsg = '无效的文物ID';
      this.isLoading = false;
    }
  }
  
  loadArtifactDetail() {
    this.isLoading = true;
    this.artifactService.getArtifactDetail(this.artifactId)
      .then((artifact) => {
        this.artifact = artifact;
        this.isLoading = false;
      })
      .catch((err: ErrorWithMessage) => {
        this.errorMsg = `加载文物详情失败: ${err.message}`;
        this.isLoading = false;
      });
  }
  
  loadComments() {
    this.userService.getComments(this.artifactId)
      .then((comments) => {
        this.comments = comments;
      })
      .catch((err: ErrorWithMessage) => {
        console.error(`加载评论失败: ${err.message}`);
      });
  }
  
  submitComment() {
    if (!this.commentText.trim()) {
      prompt.showToast({ message: '评论内容不能为空' });
      return;
    }
    
    this.userService.addComment(this.artifactId, this.commentText)
      .then((success) => {
        if (success) {
          prompt.showToast({ message: '评论成功' });
          this.commentText = '';
          this.loadComments();
        }
      })
      .catch((err: ErrorWithMessage) => {
        prompt.showToast({ message: `评论失败: ${err.message}` });
      });
  }
  
  toggleLike() {
    this.isLiked = !this.isLiked;
    if (this.isLiked) {
      this.artifact.likes++;
      prompt.showToast({ message: '点赞成功' });
    } else {
      this.artifact.likes--;
      prompt.showToast({ message: '取消点赞' });
    }
    // 实际项目中这里应该调用API
  }
  
  toggleFavorite() {
    this.isFavorite = !this.isFavorite;
    prompt.showToast({ message: this.isFavorite ? '收藏成功' : '取消收藏' });
    // 实际项目中这里应该调用API
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
        
        Text('文物详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Image($r('app.media.share'))
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      if (this.isLoading) {
        // 加载中
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#1698CE')
      } else if (this.errorMsg) {
        // 错误信息
        Column() {
          Image($r('app.media.error'))
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          
          Text(this.errorMsg)
            .fontSize(16)
            .fontColor('#FF0000')
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.artifact) {
        // 文物详情
        Scroll() {
          Column() {
            // 文物图片
            Stack() {
              Image(this.artifact.imageUrl || $r('app.media.placeholder'))
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
              
              Row() {
                Text(`${this.artifact.museum}`)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#00000080')
                  .borderRadius(12)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              }
              .position({ x: 10, y: 10 })
            }
            .width('100%')
            .height(300)
            
            // 文物基本信息
            Column() {
              Row() {
                Text(this.artifact.name)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                
                Row() {
                  Image(this.isLiked ? $r('app.media.liked') : $r('app.media.like'))
                    .width(24)
                    .height(24)
                    .margin({ right: 5 })
                    .onClick(() => this.toggleLike())
                    
                  Text(`${this.artifact.likes}`)
                    .fontSize(14)
                    .fontColor('#666666')
                }
              }
              .width('100%')
              .margin({ top: 16 })
              
              Text(`年代: ${this.artifact.era}`)
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 8 })
              
              Text(`分类: ${Constants.ARTIFACT_CATEGORIES.find((c: CategoryItem) => c.id === this.artifact.categoryId)?.name || '未知'}`)
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 8 })
              
              Divider().width('100%').margin({ top: 16, bottom: 16 })
              
              Text('文物介绍')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
              
              Text(this.artifact.description)
                .fontSize(16)
                .margin({ top: 8 })
                .width('100%')
                .textAlign(TextAlign.Start)
              
              Divider().width('100%').margin({ top: 16, bottom: 16 })
              
              // 评论区域
              Row() {
                Text('评论')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                
                Text(`${this.comments.length}条评论`)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              
              // 评论列表
              if (this.comments.length > 0) {
                ForEach(this.comments, (comment: Comment) => {
                  Column() {
                    Row() {
                      Image(comment.avatarUrl || $r('app.media.avatar_default'))
                        .width(40)
                        .height(40)
                        .borderRadius(20)
                      
                      Column() {
                        Text(comment.username)
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                        
                        Text(comment.createTime)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ left: 10 })
                      .layoutWeight(1)
                    }
                    .width('100%')
                    
                    Text(comment.content)
                      .fontSize(16)
                      .margin({ top: 8, left: 50 })
                      .width('100%')
                      .textAlign(TextAlign.Start)
                    
                    Divider().width('100%').margin({ top: 16, bottom: 16 })
                  }
                  .width('100%')
                })
              } else {
                Text('暂无评论')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 16, bottom: 16 })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 16, topRight: 16 })
            .margin({ top: -20 })
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      
      // 底部操作栏
      Row() {
        // 评论输入
        TextInput({ placeholder: '写评论...', text: this.commentText })
          .width('70%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
          .onChange((value) => {
            this.commentText = value;
          })
        
        Blank()
        
        Button('发送', { type: ButtonType.Normal })
          .width(80)
          .height(40)
          .backgroundColor('#1698CE')
          .borderRadius(20)
          .onClick(() => {
            this.submitComment();
          })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
} 