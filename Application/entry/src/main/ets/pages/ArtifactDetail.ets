import { Artifact } from '../model/ArtifactModel';
import { UserRelicComment } from '../model/UserModel';
import { ArtifactService } from '../services/ArtifactService';
import { UserService } from '../services/UserService';
import { Constants, CategoryItem } from '../common/constants/Constants';
import router from '@ohos.router';
import { ToastUtil } from '../utils/ToastUtil';

interface RouterParams {
  artifactId: string;
}

/**
 * 错误处理工具类
 */
class ErrorHandler {
  /**
   * 处理错误并返回错误消息
   */
  static handleError(error: Error): string {
    return error.message;
  }
}

/**
 * 自定义错误类型
 */
class AppError {
  message: string;
  
  constructor(message: string) {
    this.message = message;
  }
  
  toString(): string {
    return this.message;
  }
}

@Entry
@Component
struct ArtifactDetail {
  @State artifact: Artifact = new Artifact('', '', '', '', '', '', 0, '', 0, 0);
  @State comments: UserRelicComment[] = [];
  @State isLoading: boolean = true;
  @State errorMsg: string = '';
  @State commentText: string = '';
  @State isLiked: boolean = false;
  @State currentImageIndex: number = 0;
  
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
  
  async loadArtifactDetail() {
    try {
    this.isLoading = true;
    this.errorMsg = '';
    console.info(`开始加载文物详情，ID: ${this.artifactId}`);
    
      this.artifact = await this.artifactService.getArtifactDetail(this.artifactId);
      this.comments = await this.artifactService.getArtifactComments(this.artifactId);
      
      console.info(`文物详情加载成功: ${JSON.stringify(this.artifact)}`);
        
        // 判断是否为默认数据
      if (this.artifactId !== this.artifact.id) {
        console.warn(`加载了默认数据，请求ID: ${this.artifactId}, 返回ID: ${this.artifact.id}`);
          this.errorMsg = '无法从数据库获取文物详情，显示的是默认数据。请检查后端服务是否正常运行，并确保能连接到云数据库。';
        }
    } catch (error) {
      console.error(`加载文物详情失败: ${error.message}`);
      this.errorMsg = `加载文物详情失败: ${error.message}。请确保后端服务运行在localhost:3000并能连接到云数据库。`;
    } finally {
        this.isLoading = false;
    }
  }
  
  loadComments() {
    this.userService.getComments(this.artifactId)
      .then((comments) => {
        this.comments = comments;
      })
      .catch((error: Error) => {
        console.error(`加载评论失败: ${error.message}`);
      });
  }
  
  submitComment() {
    if (!this.commentText.trim()) {
      ToastUtil.show('评论内容不能为空');
      return;
    }
    
    // 保存当前评论内容用于发送
    const currentComment = this.commentText;
    // 立即清空输入框
    this.commentText = '';
    
    this.userService.addComment(this.artifactId, currentComment)
      .then((comment) => {
        if (comment) {
          ToastUtil.show('评论成功');
        } else {
          ToastUtil.show('评论失败，请重试');
        }
        // 重新获取文物详情
        this.artifactService.getArtifactDetail(this.artifactId)
          .then((artifact) => {
            this.artifact = artifact;
            // 重新获取评论列表
            return this.artifactService.getArtifactComments(this.artifactId);
          })
          .then((comments) => {
            this.comments = comments;
          })
          .catch((error: Error) => {
            console.error('刷新文物详情失败:', error.message);
            ToastUtil.show(`刷新失败: ${error.message}`);
          });
      })
      .catch((error: Error) => {
        console.error('添加评论失败:', error.message);
        ToastUtil.show(`评论失败: ${error.message}`);
        // 即使评论失败，也重新获取文物详情
        this.artifactService.getArtifactDetail(this.artifactId)
          .then((artifact) => {
            this.artifact = artifact;
            // 重新获取评论列表
            return this.artifactService.getArtifactComments(this.artifactId);
          })
          .then((comments) => {
            this.comments = comments;
          })
          .catch((error: Error) => {
            console.error('刷新文物详情失败:', error.message);
            ToastUtil.show(`刷新失败: ${error.message}`);
          });
      });
  }
  
  toggleLike() {
    this.isLiked = !this.isLiked;
    if (this.isLiked) {
      this.artifact.likes++;
      ToastUtil.show('点赞成功');
    } else {
      this.artifact.likes--;
      ToastUtil.show('取消点赞');
    }
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
            // 如果有错误信息但仍显示文物，显示错误提示
            if (this.errorMsg) {
              Text(this.errorMsg)
                .fontSize(14)
                .fontColor('#FF0000')
                .backgroundColor('#FFEEEE')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(8)
                .margin({ bottom: 10 })
            }
            
            // 文物图片轮播
            Stack() {
              Swiper() {
                ForEach(this.artifact.photos, (photoUrl: string) => {
                  Image(photoUrl)
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
                })
              }
              .width('100%')
              .height(300)
              .indicator(true)
              .loop(true)
              .autoPlay(true)
              .interval(3000)
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
                    .margin({ right: 16 })
                }
              }
              .width('100%')
              .margin({ top: 16 })
              
              Text(`年代: ${this.artifact.era}`)
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 8 })
              
              Text(`分类: ${Constants.ARTIFACT_CATEGORIES.find((c: CategoryItem) => c.id === this.artifact.type)?.name || '未知'}`)
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
                ForEach(this.comments, (comment: UserRelicComment) => {
                  Column() {
                    Row() {
                      Image($r('app.media.avatar_default'))
                        .width(24)
                        .height(24)
                        .borderRadius(12)
                        .margin({ right: 8 })
                      
                      Column() {
                        Text(String(comment.user_id))
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                        
                        Text(new Date(comment.comment_time).toLocaleString())
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ left: 10 })
                      .layoutWeight(1)
                    }
                    .width('100%')
                    
                    Text(comment.comment)
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
        TextInput({ 
          placeholder: '写评论...', 
          text: this.commentText 
        })
          .width('70%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
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