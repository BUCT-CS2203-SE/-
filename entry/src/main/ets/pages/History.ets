import router from '@ohos.router';

interface HistoryItem {
  id: number;
  name: string;
  dynasty: string;
  museum: string;
  imageUrl: Resource;
  viewTime: string;
}

@Entry
@Component
struct History {
  @State historyList: HistoryItem[] = [
    {
      id: 1,
      name: '青花瓷瓶',
      dynasty: '明朝',
      museum: '故宫博物院',
      imageUrl: $r('app.media.cultural_heritage_logo'),
      viewTime: '2024-03-20 15:30'
    },
    {
      id: 2,
      name: '金缕玉衣',
      dynasty: '汉朝',
      museum: '南京博物院',
      imageUrl: $r('app.media.cultural_heritage_logo'),
      viewTime: '2024-03-20 14:20'
    }
  ];

  @Builder
  HistoryItemCard(item: HistoryItem) {
    Column() {
      // 时间显示
      Text(item.viewTime)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      // 文物卡片
      Row() {
        Image(item.imageUrl)
          .width(100)
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
        
        Column() {
          Text(item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text(item.dynasty)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
          
          Text(item.museum)
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
          params: { id: item.id }
        });
      })
    }
    .margin({ bottom: 16 })
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
                action: () => {
                  this.historyList = [];
                }
              }
            })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 历史记录列表
      if (this.historyList.length > 0) {
        List() {
          ForEach(this.historyList, (item: HistoryItem) => {
            ListItem() {
              this.HistoryItemCard(item)
            }
          })
        }
        .width('90%')
        .layoutWeight(1)
        .margin({ top: 16 })
      } else {
        // 空状态展示
        Column() {
          Image($r('app.media.no_result'))
            .width(120)
            .height(120)
            .margin({ top: 100, bottom: 16 })
          
          Text('暂无浏览记录')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 