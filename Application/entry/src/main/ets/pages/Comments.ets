import router from '@ohos.router';
import { RelicCommentService } from '../services/RelicCommentService';
import { UserRelicComment } from '../model/UserModel';
import { UserService } from '../services/UserService';

interface CommentItem {
  id: string;
  relicId: string;
  content: string;
  time: string;
}

/**
 * 错误接口
 */
interface ErrorWithMessage {
  message: string;
}

function formatDateToYMDHM(dateStr: string): string {
  const date = new Date(dateStr);
  const y = date.getFullYear();
  const m = (date.getMonth() + 1).toString().padStart(2, '0');
  const d = date.getDate().toString().padStart(2, '0');
  const h = date.getHours().toString().padStart(2, '0');
  const min = date.getMinutes().toString().padStart(2, '0');
  return `${y}-${m}-${d} ${h}:${min}`;
}

@Entry
@Component
struct Comments {
  @State commentList: CommentItem[] = [];
  @State currentTab: number = 0; // 0: 藏品, 1: 朋友圈
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;
  
  private commentService: RelicCommentService = new RelicCommentService();
  private userService: UserService = new UserService();

  aboutToAppear() {
    this.checkLoginStatus();
  }

  async checkLoginStatus() {
    try {
      this.isLoggedIn = await this.userService.isLoggedIn();
      if (this.isLoggedIn) {
        const currentUser = await this.userService.getCurrentUser();
        if (currentUser) {
          await this.loadUserComments(currentUser.id);
        }
      } else {
        this.commentList = [];
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
      this.isLoggedIn = false;
      this.commentList = [];
    } finally {
      this.isLoading = false;
    }
  }

  private loadUserComments(userId: string) {
    this.isLoading = true;
    this.commentService.getUserComments(userId)
      .then(comments => {
        const mappedComments: CommentItem[] = comments.map(comment => {
          const item: CommentItem = {
            id: String(comment.relic_comment_id),
            relicId: String(comment.relic_id),
            content: comment.comment || '（无内容）',
            time: formatDateToYMDHM(String(comment.comment_time))
          };
          return item;
        });
        console.info('转换后的评论数据:', JSON.stringify(mappedComments));
        this.commentList = mappedComments;
        this.currentTab = this.currentTab; // 强制触发 UI 刷新
        console.info('评论数:', this.commentList.length);
      })
      .catch((error: ErrorWithMessage) => {
        console.error('加载用户评论失败:', error.message);
        this.commentList = [];
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontColor(this.currentTab === index ? '#8B1A1A' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
      
      if (this.currentTab === index) {
        Row()
          .width(24)
          .height(2)
          .backgroundColor('#8B1A1A')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = index;
    })
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.no_result'))
        .width(120)
        .height(120)
        .margin({ top: 100, bottom: 16 })
      
      Text(this.isLoggedIn ? '暂无评论记录' : '请先登录')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LoadingBuilder() {
    Column() {
      LoadingProgress()
        .width(24)
        .height(24)
        .color('#8B1A1A')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  CommentItemCard(item: CommentItem) {
      Column() {
        // 评论内容
        Text(item.content)
        .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 8 })
            .width('100%')
        .textAlign(TextAlign.Start)
      
      // 评论时间
      Text(item.time)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ArtifactDetail',
        params: {
          artifactId: item.relicId
        }
      });
    })
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text('我的评论')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 导航栏
      Row() {
        Row() {
          this.TabBuilder(0, '藏品')
        }
        .layoutWeight(1)
        
        Row() {
          this.TabBuilder(1, '朋友圈')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(50)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: '#E6E6E6' })

      // 内容区域
      if (this.currentTab === 0) {
        if (this.isLoading) {
          this.LoadingBuilder()
        } else if (this.commentList.length > 0) {
        // 藏品评论列表
          List() {
            ForEach(this.commentList, (item: CommentItem) => {
              ListItem() {
                this.CommentItemCard(item)
              }
            })
          }
          .width('90%')
          .layoutWeight(1)
          .margin({ top: 16 })
        } else {
          this.EmptyStateBuilder()
        }
      } else {
        // 朋友圈评论（暂无记录）
        this.EmptyStateBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 