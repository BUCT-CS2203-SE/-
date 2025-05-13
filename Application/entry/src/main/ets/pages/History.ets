import router from '@ohos.router';
import { UserBrowseService } from '../services/UserBrowseService';
import { BrowseItem } from '../model/BrowseModel';
import { UserService } from '../services/UserService';
import { RelicInfo } from '../model/UserModel';
import prompt from '@ohos.prompt';

@Entry
@Component
struct History {
  @State historyList: BrowseItem[] = [];
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;
  
  private browseService: UserBrowseService = new UserBrowseService();
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
          await this.loadUserBrowses(currentUser.id);
        }
      } else {
        this.historyList = [];
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
      this.isLoggedIn = false;
      this.historyList = [];
      prompt.showToast({ message: '检查登录状态失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async loadUserBrowses(userId: string) {
    this.isLoading = true;
    try {
      const browses = await this.browseService.getUserBrowses(userId);
      if (Array.isArray(browses)) {
        this.historyList = browses;
        console.info('加载浏览历史成功，数量:', browses.length);
      } else {
        console.error('加载浏览历史失败: 响应数据格式错误');
        this.historyList = [];
        prompt.showToast({ message: '加载浏览历史失败' });
      }
    } catch (error) {
      console.error('加载浏览历史失败:', error);
      this.historyList = [];
      prompt.showToast({ message: '加载浏览历史失败' });
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  HistoryItemCard(item: BrowseItem) {
    Column() {
      // 时间显示
      Text(new Date(item.browse_time).toLocaleString())
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      // 文物卡片
      Row() {
        Image(this.getImageUrl(item.relic))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .backgroundColor('#F5F5F5')
          .onError(() => {
            console.error(`图片加载失败: ${item.relic.photos?.[0]?.photo_url}`);
          })
        
        Column() {
          Text(item.relic.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text(item.relic.era)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
          
          Text(item.relic.museum)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .onClick(() => {
        router.pushUrl({
          url: 'pages/ArtifactDetail',
          params: { artifactId: item.relic.relic_id.toString() }
        });
      })
    }
    .margin({ bottom: 16 })
  }

  /**
   * 获取文物图片URL
   * @param relic 文物信息
   * @returns 图片资源
   */
  private getImageUrl(relic: RelicInfo): Resource | string {
    if (relic.photos && relic.photos.length > 0) {
      return relic.photos[0].photo_url;
    }
    return $r('app.media.cultural_heritage_logo');
  }

  @Builder
  LoadingBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#8B1A1A')
      
      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.no_result'))
        .width(120)
        .height(120)
        .margin({ top: 100, bottom: 16 })
      
      Text(this.isLoggedIn ? '暂无浏览记录' : '请先登录')
        .fontSize(16)
        .fontColor('#999999')
      
      if (!this.isLoggedIn) {
        Button('去登录')
          .width(120)
          .height(40)
          .backgroundColor('#8B1A1A')
          .fontColor('#FFFFFF')
          .margin({ top: 16 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Login' });
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
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
        
        Text('浏览历史')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 清空历史按钮
        if (this.isLoggedIn && this.historyList.length > 0) {
          Image($r('app.media.error'))
            .width(24)
            .height(24)
            .fillColor('#666666')
            .onClick(() => {
              AlertDialog.show({
                title: '确认清空',
                message: '是否清空所有浏览历史？',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '确认',
                  action: async () => {
                    try {
                      const currentUser = await this.userService.getCurrentUser();
                      if (currentUser) {
                        await this.browseService.clearBrowses(currentUser.id);
                        this.historyList = [];
                        prompt.showToast({ message: '浏览历史已清空' });
                      }
                    } catch (error) {
                      console.error('清空浏览历史失败:', error);
                      prompt.showToast({ message: '清空浏览历史失败' });
                    }
                  }
                }
              })
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 历史记录列表
      if (this.isLoading) {
        this.LoadingBuilder()
      } else if (!this.isLoggedIn || this.historyList.length === 0) {
        this.EmptyStateBuilder()
      } else {
        List() {
          ForEach(this.historyList, (item: BrowseItem) => {
            ListItem() {
              this.HistoryItemCard(item)
            }
          })
        }
        .width('90%')
        .layoutWeight(1)
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 