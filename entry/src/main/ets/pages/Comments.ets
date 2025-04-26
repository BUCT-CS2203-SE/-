import router from '@ohos.router';

interface CommentItem {
  id: number;
  artifactName: string;
  content: string;
  imageUrl?: Resource;
  commentTime: string;
}

@Entry
@Component
struct Comments {
  @State commentList: CommentItem[] = [
    {
      id: 1,
      artifactName: '青花瓷瓶',
      content: '这件青花瓷瓶的纹饰非常精美，展现了明代瓷器工艺的高超水平。',
      imageUrl: $r('app.media.cultural_heritage_logo'),
      commentTime: '2024-03-20 15:30'
    },
    {
      id: 2,
      artifactName: '金缕玉衣',
      content: '金缕玉衣的制作工艺令人叹为观止，体现了汉代工匠的智慧。',
      commentTime: '2024-03-20 14:20'
    }
  ];
  @State currentTab: number = 0; // 0: 藏品, 1: 朋友圈

  @Builder
  TabBuilder(index: number, name: string, count: number) {
    Column() {
      Text(name + ` (${count})`)
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
      
      Text('暂无评论记录')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  CommentItemCard(item: CommentItem) {
    Column() {
      // 时间显示
      Text(item.commentTime)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      // 评论卡片
      Column() {
        // 文物名称
        Text(item.artifactName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 })
        
        // 评论内容
        Text(item.content)
          .fontSize(14)
          .fontColor('#333333')
          .margin({ bottom: 8 })
        
        // 评论图片（如果有）
        if (item.imageUrl) {
          Image(item.imageUrl)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .margin({ bottom: 8 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
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
          this.TabBuilder(0, '藏品', this.commentList.length)
        }
        .layoutWeight(1)
        
        Row() {
          this.TabBuilder(1, '朋友圈', 0)
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
        // 藏品评论列表
        if (this.commentList.length > 0) {
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